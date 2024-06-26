# shell: sh altsh=shellspec
# shellcheck shell=bash disable=SC1003,SC2034,SC2286,SC2287,SC2288,SC2317
Include lib/lib.sh

Context 'dahlia_convert'
	DAHLIA_AUTO_RESET=0
	DAHLIA_DEPTH=4

	Describe 'handles marker'
		Parameters
			"&" $'\x1b[93me§ee§§_4x'
			"e" $'&\x1b[93m§\x1b[93m§§_4x'
			"§" $'&ee\x1b[93me§§4x'
			"_" $'&ee§ee§§\x1b[31mx'
			"4" $'&ee§ee§§_4x'
			"x" $'&ee§ee§§_4x'
		End

		Example "$1"
			DAHLIA_MARKER="$1"
			When call dahlia_convert "&ee§ee§§_4x"
			The output should equal "$2"
			The status should be success
		End
	End

	It 'errors on invalid marker'
		DAHLIA_MARKER='&&'
		When call dahlia_convert ""
		The error should include 'Invalid marker'
		The status should equal 1
	End

	Describe 'properly handles weird marker'
		Parameters
			"$"
			"^"
			"?"
			"("
			")"
			'\'
			"/"
			"["
			"]"
			"*"
			"+"
			"."
		End

		Example "$1"
			DAHLIA_MARKER="$1"
			When call dahlia_convert "${1}4foo${1}_2bar"
			The output should equal $'\x1b[31mfoo'"$1"'2bar'
			The status should be success
		End
	End

	Describe 'handles auto reset'
		Parameters
			"1" $'a\x1b[0m'
			"0" $'a'
		End

		Example "$1"
			DAHLIA_AUTO_RESET="$1"
			When call dahlia_convert "a"
			The output should equal "$2"
			The status should be success
		End
	End

	It 'reads from stdin'
		Data '&2green'
		When call dahlia_convert
		The output should equal $'\x1b[32mgreen'
		The status should be success
	End

	Describe 'handles valid depths'
		ExampleGroup 'as uppercase'
			Parameters
				HIGH "foo" $'foo'
				LOW "&e&nunderlined&rn yellow" $'\x1b[93m\x1b[4munderlined\x1b[24m yellow'
				MEDIUM "&7ball" $'\x1b[38;5;248mball'
				HIGH "&7ball" $'\x1b[38;2;170;170;170mball'
				TTY "&kcarcinogen" $'\x1b[5mcarcinogen'
				LOW "&lhyperextension" $'\x1b[1mhyperextension'
				LOW "&asupremacism" $'\x1b[92msupremacism'
				HIGH "&mlymphocyte" $'\x1b[9mlymphocyte'
				TTY "&alingualumina" $'\x1b[32mlingualumina'
				TTY "&3filariidae" $'\x1b[36mfilariidae'
				LOW "&4aura" $'\x1b[31maura'
				TTY "&r&R" $'&r\x1b[0m'
			End

			Example "$1"
				DAHLIA_DEPTH="$1"
				When call dahlia_convert "$2"
				The output should equal "$3"
				The status should be success
			End
		End

		ExampleGroup 'as lowercase'
			Parameters
				high "foo" $'foo'
				medium "&7ball" $'\x1b[38;5;248mball'
				low "&e&nunderlined&rn yellow" $'\x1b[93m\x1b[4munderlined\x1b[24m yellow'
				tty "&3filariidae" $'\x1b[36mfilariidae'
			End

			Example "$1"
				DAHLIA_DEPTH="$1"
				When call dahlia_convert "$2"
				The output should equal "$3"
				The status should be success
			End
		End

		ExampleGroup 'as integer'
			Parameters
				24 "&9aspergillaceae" $'\x1b[38;2;85;85;255maspergillaceae'
				8 "&hgammopathy" $'\x1b[8mgammopathy'
				4 "&edemigod" $'\x1b[93mdemigod'
				3 "&9miller" $'\x1b[34mmiller'
			End

			Example "$1"
				DAHLIA_DEPTH="$1"
				When call dahlia_convert "$2"
				The output should equal "$3"
				The status should be success
			End
		End
	End

	Describe 'handles invalid depths'
		Parameters
			'-1'
			'1'
			'16'
			'best'
			'worst'
		End

		Example "$1"
			DAHLIA_DEPTH="$1"
			When call dahlia_convert "foo"
			The error should include 'Invalid depth'
			The status should equal 1
		End
	End

	Describe 'handles hex codes'
		Parameters
			'&#aabbcc;foo' $'\x1b[38;2;170;187;204mfoo'
			'&#abc;foo' $'\x1b[38;2;160;176;192mfoo'

			'&~#aabbcc;foo' $'\x1b[48;2;170;187;204mfoo'
			'&~#abc;foo' $'\x1b[48;2;160;176;192mfoo'
		End

		Example "$1"
			When call dahlia_convert "$1"
			The output should equal "$2"
			The status should be success
		End
	End

	Describe 'handles NO_COLOR'
		Parameters
			'0' 'foo'
			'1' 'foo'
			'' $'\x1b[32mfoo'
		End

		Example "$1"
			NO_COLOR="$1"
			When call dahlia_convert "&2foo"
			The output should equal "$2"
			The status should be success
		End
	End

	It 'handles dumb TERM'
		DAHLIA_DEPTH=0
		TERM=dumb
		COLORTERM=
		When call dahlia_convert "&2foo"
		The output should equal 'foo'
		The status should be success
	End

	It 'propagates errors'
		__dh_get_ansi() {
			__dh_error "Invalid code"
			return 1
		}
		When call dahlia_convert "&2foo"
		The error should include 'Invalid code'
		The status should equal 1
	End
End

Context 'dahlia_clean'
	Describe 'handles input'
		Parameters
			"&e&nunderlined&rn yellow" "&" "underlined yellow"
			"&e&nunderlined&rn yellow" "!" "&e&nunderlined&rn yellow"
			"!e!nunderlined!rn yellow" "!" "underlined yellow"
			"§_4 gives §4red" "§" "§4 gives red"
		End

		It "'$1'"
			DAHLIA_MARKER="$2"
			When call dahlia_clean "$1"
			The output should equal "$3"
			The status should be success
		End
	End

	It 'errors on invalid marker'
		DAHLIA_MARKER="&&"
		When call dahlia_clean "$1"
		The error should include 'Invalid marker'
		The status should equal 1
	End

	Describe 'properly handles weird marker'
		Parameters
			"$"
			"^"
			"?"
			"("
			")"
			'\'
			"/"
			"["
			"]"
			"*"
			"+"
			"."
		End

		Example "$1"
			DAHLIA_MARKER="$1"
			When call dahlia_clean "${1}4foo${1}_2bar"
			The output should equal "foo${1}2bar"
			The status should be success
		End
	End
End

Describe 'dahlia_clean_ansi'
	Parameters
		'\x1b[93m\x1b[4munderlined\x1b[0m yellow' $'\x1b[93m\x1b[4munderlined\x1b[0m yellow' $'underlined yellow'
		'\x1b[38;2;255;255;85m\x1b[4munderlined\x1b[0m yellow' $'\x1b[38;2;255;255;85m\x1b[4munderlined\x1b[0m yellow' $'underlined yellow'
		'\x1bxxx' $'\x1bxxx' $'\x1bxxx'
		'\x1b[xm' $'\x1b[xm' $'\x1b[xm'
	End

	It "handles '$1'"
		When call dahlia_clean_ansi "$2"
		The output should equal "$3"
		The status should be success
	End
End

Describe 'dahlia_print'
	It 'converts'
		DAHLIA_MARKER='&'
		DAHLIA_AUTO_RESET=0
		DAHLIA_DEPTH=4
		When call dahlia_print "&e&nunderlined&rn yellow"
		The output should equal $'\x1b[93m\x1b[4munderlined\x1b[24m yellow'
		The status should be success
	End

	It 'propagates conversion errors'
		dahlia_convert() {
			__dh_error "Something went wrong"
			return 1
		}
		When call dahlia_print "&e&nunderlined&rn yellow"
		The error should include 'Something went wrong'
		The status should equal 1
	End
End

Describe 'dahlia_input'
	It 'converts and reads from stdin'
		DAHLIA_MARKER='&'
		DAHLIA_AUTO_RESET=0
		DAHLIA_DEPTH=4
		Data 'John'
		When call dahlia_input "&2Name: "
		The output should equal $'\x1b[32mName: John'
		The status should be success
	End

	It 'propagates conversion errors'
		dahlia_convert() {
			__dh_error "Something went wrong"
			return 1
		}
		Data 'John'
		When call dahlia_input "&2Name: "
		The error should include 'Something went wrong'
		The status should equal 1
	End
End

Describe 'dahlia_test'
	It 'prints a test string'
		When call dahlia_test
		The output should equal $'[38;2;0;0;0m0[39m[49m[38;2;0;0;170m1[39m[49m[38;2;0;170;0m2[39m[49m[38;2;0;170;170m3[39m[49m[38;2;170;0;0m4[39m[49m[38;2;170;0;170m5[39m[49m[38;2;255;170;0m6[39m[49m[38;2;170;170;170m7[39m[49m[38;2;85;85;85m8[39m[49m[38;2;85;85;255m9[39m[49m[38;2;85;255;85ma[39m[49m[38;2;85;255;255mb[39m[49m[38;2;255;85;85mc[39m[49m[38;2;255;85;255md[39m[49m[38;2;255;255;85me[39m[49m[38;2;255;255;255mf[39m[49m[8mh[28m[7mi[27m[2mj[22m[5mk[25m[1ml[22m[9mm[29m[4mn[24m[3mo[23m[0m'
		The status should be success
	End
End
