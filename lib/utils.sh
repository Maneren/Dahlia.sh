# shell: bash
# shellcheck shell=bash disable=2059 disable=2155

# Print error messages to the stderr.
#
# Arguments:
#   $*: The error message to be printed.
#
# Usage:
#   __dh_error "Invalid argument provided"
#
__dh_error() {
	echo "DahliaError: $*" >&2
}

# Escapes the string to be safe to use in regexes.
#
# Arguments:
#   $1: The marker to be escaped.
#
# Returns:
#   Prints the escaped string to be used.
#
# Usage:
#   marker=$(__dh_escape "$")
#
__dh_escape() {
	echo -n "$1" | sed 's/\([()[{*+.$^\\|?\/]\)/\\\1/g'
}

# Reads the input message from `$1`.
#
# If the message is empty or "-", it reads from standard input.
#
# Arguments:
#   $1: The input message.
#
# Returns:
#   The input message with trailing newline.
#
# Usage:
#   __dh_get_input "Hello, World!"          #-> "Hello, World!"
#   echo "Hello, World!" | __dh_get_input   #-> "Hello, World!"
#   echo "Hello, World!" | __dh_get_input - #-> "Hello, World!"
#   echo "false" | __dh_get_input "Hello"   #-> "Hello"
#
__dh_get_input() {
	local msg="$1"
	[ "$msg" = "" ] || [ "$msg" = "-" ] && msg="$(</dev/stdin)"
	echo -n "$msg"
}

# Infer the color depth for the current terminal.
#
# Based on the DAHLIA_DEPTH, COLORTERM, and TERM environment variables in this order. If
# DAHLIA_DEPTH is not set, is set to AUTO, or is set to 0, it determines the color depth based on
# COLORTERM and TERM. If DAHLIA_DEPTH is set to something else, it checks if it's a valid depth.
#
# Follows the inferrence rules in Dahlia spec
# (https://github.com/dahlia-lib/spec/blob/v1.0.0/SPECIFICATION.md#term-and-colorterm)
#
# Environment Variables:
# - DAHLIA_DEPTH: The color depth to be used. If not set, the function will infer the color depth.
# - COLORTERM: Used to infer the color depth if DAHLIA_DEPTH is not set.
# - TERM: Used to infer the color depth if DAHLIA_DEPTH is not set.
#
# Returns:
#   Prints the color depth in bits to stdout. Or returns 1 if the depth is invalid.
#
# Usage:
#   __dahlia_infer_depth
#
__dahlia_infer_depth() {
	determine_color_depth() {
		case "$COLORTERM" in
		24bit | truecolor) return 24 ;;
		esac

		case "$TERM" in
		dumb) return 0 ;;
		*24*bit* | terminator | mosh) return 24 ;;
		*256*) return 8 ;;
		*) return 4 ;;
		esac
	}

	# Convert DAHLIA_DEPTH to uppercase
	local depth="${DAHLIA_DEPTH^^}"

	case $depth in
	'' | AUTO | '0')
		determine_color_depth
		echo -n "$?"
		return 0
		;;
	*)
		# If depth is not in __DH_DEPTHS, return an error
		local depth="${__DH_DEPTHS[$depth]}"
		if [ "$depth" != "" ]; then
			echo -n "$depth"
			return 0
		fi

		return 1
		;;
	esac

}

# Converts given Dahlia code to ANSI code.
#
# Environment Variables:
#   DAHLIA_MARKER: The marker to be used. Processed with `__dh_setup_marker`.
#
# Arguments:
#   $1: The Dahlia code to be converted without the marker.
#   $2: The color depth.
#
# Returns:
#   The ANSI code corresponding to the Dahlia code, or 1 if the Dahlia code is invalid.
#
# Usage:
#   __dh_get_ansi "&f" 8 #-> "\033[38;5;15m"
#
__dh_get_ansi() {
	local code="$1" depth=$2

	local bg=false code

	# `-n` sets the variable as indirect reference
	local -n formats

	# Check if the code is a background color code and remove the modifier
	if [[ $code == '~'* ]]; then
		formats=__DH_BG_TEMPLATES
		code=${code:1}
		bg=true
	else
		formats=__DH_TEMPLATES
	fi

	# Check if the code is in format `#aabbcc;`
	if [ ${#code} = 8 ]; then
		# If it is, convert the code to an ANSI 24-bit color code
		printf "${formats[24]}" 0x"${code:1:2}" 0x"${code:3:2}" 0x"${code:5:2}"
		return 0
	fi

	# Check if the code is in format `#abc;`
	if [ ${#code} = 5 ]; then
		# If it is, convert the code to an ANSI 24-bit color code
		printf "${formats[24]}" 0x"${code:1:1}0" 0x"${code:2:1}0" 0x"${code:3:1}0"
		return 0
	fi

	# Check if the code is a formatter code
	local formatter="${__DH_FORMATTERS[$code]}"
	if [ "$formatter" != "" ]; then
		# One code can produce multiple ANSI codes
		read -r -a values <<<"$formatter"

		local str=""

		# Convert all ANSI code numbers to codes
		for value in "${values[@]}"; do
			# `print -v var` prints the output to `$var`
			printf -v str "$str${formats[3]}" "$value"
		done

		echo -n "$str"
		return 0
	fi

	local template=${formats[$depth]}

	# If the depth is 24, the ANSI code has RGB values - 3 numbers
	if [ "$depth" = 24 ]; then
		local color_code="${__DH_COLORS_24BIT[$code]}"
		[ "$color_code" != "" ] || return 1

		read -r -a rgb <<<"$color_code"

		printf "$template" "${rgb[@]}"
		return 0
	fi

	# Otherwise it has just one number

	# Get the color map for the current depth
	local -n color_map="__DH_COLORS_${depth}BIT"

	local value="${color_map[$code]}"
	[ "$value" != "" ] || return 1

	# If the code is a background color code and the depth is LOW or TTY, the format string is the
	# same so we have to add 10 to the value instead
	[ "$bg" = "true" ] && [ "$depth" -le "${__DH_DEPTHS[LOW]}" ] && value=$((value + 10))

	printf "$template" "$value"
}

# Find all unique matches of the regular expression in the string.
#
# Arguments:
#   $1: The string to search in.
#   $2: The regular expression to match.
#
# Returns:
#   Print all matches on separate lines.
#
# Usage:
#   __dh_findall_regex "&2test&R" "${__DH_CODE_REGEXES[1]}" #-> "&2\n&R"
__dh_findall_regex() {
	echo -n "$1" | grep -ohE "$2" | sort | uniq
}
