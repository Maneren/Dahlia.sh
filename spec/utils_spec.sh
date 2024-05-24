# shell: bash altsh=shellspec
# shellcheck shell=bash disable=SC1003,SC2034,SC2287,SC2288

Include lib/utils.sh

Describe 'dh_error'
	It 'prints the error message'
		When call __dh_error "Invalid argument provided"
		The stderr should equal "DahliaError: Invalid argument provided"
		The status should be success
	End
End

Describe 'dh_escape'
	Parameters
		'a' 'a'
		'b' 'b'
		'1' '1'
		'.' '\.'
		'*' '\*'
		'+' '\+'
		'?' '\?'
		'^' '\^'
		'$' '\$'
		'(' '\('
		')' '\)'
		'[' '\['
		']' ']'
		'{' '\{'
		'}' '}'
		'|' '\|'
		'\' '\\'
		'/' '\/'
	End

	It "escapes $1"
		When call __dh_escape "$1"
		The output should equal "$2"
	End
End

Describe 'dh_get_input'
	It 'returns the input'
		Data 'bar'
		When call __dh_get_input "foo"
		The output should equal "foo"
		The status should be success
	End

	It 'reads from stdin with no args'
		Data 'bar'
		When call __dh_get_input
		The output should equal "bar"
		The status should be success
	End

	It 'reads from stdin with "-"'
		Data 'bar'
		When call __dh_get_input "-"
		The output should equal "bar"
		The status should be success
	End
End

Context 'dh_infer_depth'
	declare -A __DH_DEPTHS=([HIGH]="24" [3]="3")

	Describe 'should infer depth for'
		Parameters
			'AUTO' '' '' '4'
			'0' 'xterm' '' '4'
			'0' 'xterm' 'truecolor' '24'
			'0' 'xterm-24-bit' '' '24'
			'0' 'xterm-24-bit' 'truecolor' '24'
			'0' 'xterm-256color' '' '8'
			'0' 'xterm-256color' '24bit' '24'
			'AUTO' 'xterm-256color' '' '8'

			'AUTO' 'dumb' '24bit' '24'
			'AUTO' 'dumb' '' '0'

			'HIGH' 'dumb' '24bit' '24'
			'HIGH' 'xterm' 'truecolor' '24'
			'3' 'screen' '' '3'
		End

		Example "DAHLIA_DEPTH=$1, TERM=$2, COLORTERM=$3"
			DAHLIA_DEPTH="$1"
			TERM="$2"
			COLORTERM="$3"
			When call __dh_infer_depth
			The output should equal "$4"
		End
	End

	Describe 'errors on invalid depth'
		Parameters
			'-1'
			'1'
			'16'
			'best'
			'worst'
		End

		Example "'$1'"
			DAHLIA_DEPTH="$1"
			When call __dh_infer_depth
			The status should equal 1
		End
	End
End
