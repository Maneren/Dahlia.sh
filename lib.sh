# shellcheck disable=2059
# shellcheck shell=bash

source ./constants.sh

dahlia_clean() {
	[ "$DAHLIA_MARKER" = "" ] && __error "Empty marker" && return 1

	local msg="$1"

	if [[ -z "$msg" || "$msg" = "-" ]]; then
		msg=""
		while read -r line; do
			msg+=$line
		done </dev/stdin
	fi

	for regex in "${__DH_CODE_REGEXES[@]}"; do
		local regex="${DAHLIA_MARKER}${regex}"

		local patterns
		readarray -t patterns < <(echo "$msg" | grep -ohE "$regex" | sort | uniq)

		for code in "${patterns[@]}"; do
			msg="${msg//"$code"/}"
		done
	done

	echo "$msg"
}

dahlia_clean_ansi() {
	[ "$DAHLIA_MARKER" = "" ] && __error "Empty marker" && return 1

	local msg="$1"

	if [[ -z "$msg" || "$msg" = "-" ]]; then
		msg=""
		while read -r line; do
			msg+=$line
		done </dev/stdin
	fi

	for regex in "${__DH_ANSI_REGEXES[@]}"; do
		local patterns
		readarray -t patterns < <(echo "$msg" | grep -ohE "$regex" | sort | uniq)

		for code in "${patterns[@]}"; do
			msg="${msg//"$code"/}"
		done
	done

	echo "$msg"
}

dahlia_test() {
	local marker="$DAHLIA_MARKER"
	local str=""

	for ch in 0 1 2 3 4 5 6 7 8 9 a b c d e f g; do
		str+="${marker}${ch}${ch}"
	done

	for ch in l m n o; do
		str+="${marker}r${marker}${ch}${ch}"
	done

	dahlia "$str"
}

__dh_get_ansi() {
	local code=$1
	local depth=$2

	local bg color
	local -n formats
	if [[ "$code" = *'~'* ]]; then
		formats=__DH_BG_TEMPLATES
		color=${code/$DAHLIA_MARKER~/}
		bg=1
	else
		formats=__DH_TEMPLATES
		color=${code/$DAHLIA_MARKER/}
		bg=0
	fi

	if [ ${#color} = 9 ]; then
		# color is in format `[#aabbcc]`
		printf "${formats[24]}" 0x"${color:2:2}" 0x"${color:4:2}" 0x"${color:6:2}"
		return 0
	fi

	if [[ "${__DH_FORMATTERS[$color]}" ]]; then
		printf "${formats[3]}" "${__DH_FORMATTERS[$color]}"
		return 0
	fi

	local template=${formats[$depth]}

	if [ "$depth" = "${__DH_DEPTHS[HIGH]}" ]; then
		[[ "${__DH_COLORS_24BIT[$color]}" ]] || return 1

		# convert from string to array
		read -r -a rgb < <(echo "${__DH_COLORS_24BIT[$color]}")

		printf "$template" "${rgb[@]}"
		return 0
	fi

	local -n color_map="__DH_COLORS_${depth}BIT"

	[[ "${color_map[$color]}" ]] || return 1

	local value="${color_map[$color]}"

	[[ $bg == "1" && "$depth" -le "${__DH_DEPTHS[LOW]}" ]] && value=$((value + 10))

	printf "$template" "$value"
}

dahlia() {
	__is_truthy() {
		[[ "$1" == "true" || "$1" == "1" ]]
		return $?
	}

	__is_falsy() {
		[[ "$1" != "true" && "$1" != "1" ]]
		return $?
	}

	__error() {
		echo "DahliaError: $*"
	}

	local msg="$*"

	if __is_truthy "$DAHLIA_NO_COLOR" || __is_truthy "$NO_COLOR"; then
		dahlia_clean "$msg"
		return $?
	fi

	[ "$DAHLIA_MARKER" = "" ] && __error "Empty marker" && return 1

	local depth
	depth=$(echo "$DAHLIA_DEPTH" | tr '[:lower:]' '[:upper:]')
	if ! [[ ${__DH_DEPTHS[$depth]} ]]; then
		__error "Invalid depth $depth"
		return 1
	fi
	depth="${__DH_DEPTHS[$depth]}"

	local reset="${DAHLIA_MARKER}r"

	if __is_falsy "$DAHLIA_NO_RESET" || [[ ! "$msg" =~ ${reset}$ ]]; then
		msg+="$reset"
	fi

	for regex in "${__DH_CODE_REGEXES[@]}"; do
		local regex="${DAHLIA_MARKER}${regex}"

		local patterns
		readarray -t patterns < <(echo "$msg" | grep -ohE "$regex" | sort | uniq)

		local ansi
		for code in "${patterns[@]}"; do
			if ! ansi=$(__dh_get_ansi "$code" "$depth"); then
				__error "Invalid code '$code'"
				return 1
			fi

			msg="${msg//"$code"/"$ansi"}"
		done
	done

	echo "$msg"
}
