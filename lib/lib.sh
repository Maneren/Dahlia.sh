# shell: bash
# shellcheck shell=bash disable=2155

__DH_ROOT="$(dirname BASH_SOURCE)"
source "$__DH_ROOT"/lib/constants.sh
source "$__DH_ROOT"/lib/utils.sh

# Clean the input message by removing all Dahlia codes.
#
# Cleans all Dahlia codes and unescapes escaped markers in the input message.
#
# Environment Variables:
# - DAHLIA_MARKER: The marker to be used. Processed with `__dh_setup_marker`.
#
# Arguments:
#   $@: The input message to be cleaned. Read using `__dh_get_input`.
#
# Returns:
#   The cleaned message.
#
# Usage:
#   dahlia_clean "Hello, &RWorld!&r"        #-> "Hello, World!"
#   echo "Hello, &RWorld!&r" | dahlia_clean #-> "Hello, World!"
#
dahlia_clean() {
	local marker=${DAHLIA_MARKER:-'&'}

	if [ ${#marker} != 1 ]; then
		__dh_error "Invalid marker '$marker'"
		return 1
	fi

	local escaped_marker
	if ! escaped_marker=$(__dh_escape "$marker"); then
		return $?
	fi

	local msg="$(__dh_get_input "$@")"

	for regex in "${__DH_CODE_REGEXES[@]}"; do
		msg="$(echo -n "$msg" | sed -E "s/${escaped_marker}${regex}//g")"
	done

	# Unescape markers
	echo -n "${msg//"${marker}_"/"$marker"}"
}

# Cleans the input message by removing all ANSI codes.
#
# Arguments:
#   $@: The input message to be cleaned.
#
# Returns:
#   The cleaned message with all ANSI codes removed.
#
# Usage:
#   dahlia_clean_ansi "Hello, \033[31mWorld!\033[0m"        #-> "Hello, World!"
#   echo "Hello, \033[31mWorld!\033[0m" | dahlia_clean_ansi #-> "Hello, World!"
#
dahlia_clean_ansi() {
	__dh_get_input "$@" | sed -E "s/${__DH_ANSI_REGEX}//g"
}

# Prints short testing string that showcases all possible formatting codes.
#
# Returns:
#   The exit status of the `dahlia_print` function. Should be always 0.
#
# Usage:
#   dahlia_test #-> "0123456789abcdefhijklmno" with formatting
#
dahlia_test() {
	local str=""

	for ch in 0 1 2 3 4 5 6 7 8 9 a b c d e f; do
		str+="&${ch}${ch}&rc"
	done

	for ch in h i j k l m n o; do
		str+="&${ch}${ch}&r${ch}"
	done

	DAHLIA_MARKER='&' dahlia_print "$str"
	return $?
}

# Prints the input message with Dahlia codes converted to ANSI.
#
# Internally it is the same as `dahlia_convert`, except that it appends trailing newline in same way
# as `echo`. Provided mostly for specification compliance.
#
# Arguments:
#   $@: The input to be converted and printed.
#
# Returns:
#   Prints the converted message and returns the exit status of the `dahlia_convert` function.
#
# Usage:
#   dahlia_print "&2Hello, &5World!" #-> "Hello, World!\n"
#
dahlia_print() {
	local msg
	if msg="$(dahlia_convert "$@")"; then
		echo "$msg"
	fi

	return $?
}

# Convert the input message into ANSI format.
#
# Handles the conversion of Dahlia codes to ANSI codes.
#
# Environment Variables:
# - NO_COLOR: If set, the function will clean the input and return.
# - DAHLIA_AUTO_RESET: If not set, the function will set it to 1 by default.
# - DAHLIA_DEPTH: If not set, the function will set it to AUTO by default.
# - DAHLIA_MARKER: If not set, the function will set it to & by default.
#
# Arguments:
#   $@: The input to be converted.
#
# Returns:
#   Prints the converted message to stdout (no trailing newline).
#   If no color mode is used, it returns the exit status of the `dahlia_clean` function.
#   If the marker is invalid, it prints the error message to stderr and returns 1.
#   If the depth or some code is invalid, it prints the error message to stderr and returns 1.
#
# Usage:
#   dahlia_convert "&2Hello, World!" #-> "Hello, World!"
#
dahlia_convert() {
	# Default values
	if [ "$NO_COLOR" != "" ]; then
		dahlia_clean "$@"
		return $?
	fi

	DAHLIA_DEPTH=${DAHLIA_DEPTH:-AUTO}

	# Try to infer depth from envars
	local parsed_depth
	if ! parsed_depth=$(__dahlia_infer_depth); then
		__dh_error "Invalid depth '$DAHLIA_DEPTH'"
		return 1
	fi

	# If depth is parsed as 0, treat it as NO_COLOR
	if [ "$parsed_depth" = 0 ]; then
		dahlia_clean "$@"
		return $?
	fi

	local marker=${DAHLIA_MARKER:-'&'}

	if [ ${#marker} != 1 ]; then
		__dh_error "Invalid marker '$marker'"
		return 1
	fi

	local escaped_marker
	if ! escaped_marker=$(__dh_escape "$marker"); then
		return $?
	fi

	# Load the message
	local msg="$(__dh_get_input "$@")"

	# Handle AUTO_RESET
	local reset="${marker}R"
	[[ "${DAHLIA_AUTO_RESET:-1}" != 0 && "$msg" != *"$reset" ]] && msg+="$reset"

	local ansi
	# For each code type
	for regex in "${__DH_CODE_REGEXES[@]}"; do
		regex="${escaped_marker}${regex}"

		# For each code
		while read -r code; do
			# Try to convert it to ANSI
			if ! ansi=$(__dh_get_ansi "${code/"$marker"/}" "$parsed_depth"); then
				__dh_error "Invalid code '$code'"
				return 1
			fi

			# Replace all occurences
			msg="${msg//$code/$ansi}"
		done < <(__dh_findall_regex "$msg" "$regex")
	done

	# Unescape markers
	echo -n "${msg//"${marker}_"/"$marker"}"
}

# Prints a prompt to the user and returns the user's input.
#
# The prompt is converted using the `dahlia_convert` function.
#
# Arguments:
#   $1: The prompt to be displayed to the user.
#
# Returns:
#   Prints the user's input. Or if the conversion fails, returns the exit status of the
#   `dahlia_convert` function.
#
# Usage:
#  echo "John" | dahlia_input "&2Enter your name: " #-> Enter your name: John
#
dahlia_input() {
	# Print the prompt
	if ! dahlia_convert "$1"; then
		return $?
	fi

	# Read from stdin
	local msg
	read -r msg

	echo -n "$msg"
}
