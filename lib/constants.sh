# shellcheck shell=zsh

# Constants for the Dahlia text formatter

# Map from depth to number identifier of bits
declare -A __DH_DEPTHS=(
	[HIGH]="24"
	[MEDIUM]="8"
	[LOW]="4"
	[TTY]="3"
	[24]="24"
	[8]="8"
	[4]="4"
	[3]="3"
)

# Regexes for Dahlia codes
__DH_CODE_REGEXES=($'(_?)(~?)([0-9a-fh-oR]|r[a-o])' $'(_?)(~?)\[#([0-9a-fA-F]{6})\]')

# Regex for ANSI codes
# From Dahlia spec (https://github.com/dahlia-lib/spec/blob/v1.0.0/SPECIFICATION.md#clean_ansi)
# edited for use with GNU sed
__DH_ANSI_REGEX='[\x1B\x9B][][()#;?]*((((;[-[:alnum:]\/#&.:=?%@~_]+)*|[[:alnum:]]+(;[-[:alnum:]\/#&.:=?%@~_]*)*)?\x07)|(([0-9]{1,4}(;[0-9]{0,4})*)?[0-9A-PR-TZcf-nq-uy=><~]))'

declare -A __DH_FORMATTERS=(
	[h]="8"
	[i]="7"
	[j]="2"
	[k]="5"
	[l]="1"
	[m]="9"
	[n]="4"
	[o]="3"
	[R]="0"
	[rf]="39"
	[rb]="49"
	[rc]="39 49"
	[rh]="28"
	[ri]="27"
	[rj]="22"
	[rk]="25"
	[rl]="22"
	[rm]="29"
	[rn]="24"
	[ro]="23"
)

declare -A __DH_COLORS_3BIT=(
	[0]="30"
	[1]="34"
	[2]="32"
	[3]="36"
	[4]="31"
	[5]="35"
	[6]="33"
	[7]="37"
	[8]="30"
	[9]="34"
	[a]="32"
	[b]="34"
	[c]="31"
	[d]="35"
	[e]="33"
	[f]="37"
)

declare -A __DH_COLORS_4BIT=(
	[0]="30"
	[1]="34"
	[2]="32"
	[3]="36"
	[4]="31"
	[5]="35"
	[6]="33"
	[7]="37"
	[8]="90"
	[9]="94"
	[a]="92"
	[b]="96"
	[c]="91"
	[d]="95"
	[e]="93"
	[f]="97"
)

declare -A __DH_COLORS_8BIT=(
	[0]="0"
	[1]="19"
	[2]="34"
	[3]="37"
	[4]="124"
	[5]="127"
	[6]="214"
	[7]="248"
	[8]="240"
	[9]="147"
	[a]="83"
	[b]="87"
	[c]="203"
	[d]="207"
	[e]="227"
	[f]="15"
)

declare -A __DH_COLORS_24BIT=(
	[0]="0 0 0"
	[1]="0 0 170"
	[2]="0 170 0"
	[3]="0 170 170"
	[4]="170 0 0"
	[5]="170 0 170"
	[6]="255 170 0"
	[7]="170 170 170"
	[8]="85 85 85"
	[9]="85 85 255"
	[a]="85 255 85"
	[b]="85 255 255"
	[c]="255 85 85"
	[d]="255 85 255"
	[e]="255 255 85"
	[f]="255 255 255"
)

declare -A __DH_TEMPLATES=(
	[3]=$'\e[%dm'
	[4]=$'\e[%dm'
	[8]=$'\e[38;5;%dm'
	[24]=$'\e[38;2;%d;%d;%dm'
)

declare -A __DH_BG_TEMPLATES=(
	[3]=$'\e[%dm'
	[4]=$'\e[%dm'
	[8]=$'\e[48;5;%dm'
	[24]=$'\e[48;2;%d;%d;%dm'
)
