# shell: sh altsh=shellspec
# shellcheck shell=bash disable=SC2034,SC2286
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

	It 'errors on multicharacter marker'
		DAHLIA_MARKER='&&'
		When call dahlia_convert ""
		The error should include 'Invalid marker'
		The status should equal 1
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
		The output should equal $'\e[32mgreen'
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
End

Describe 'dahlia_clean'
	Parameters
		"&e&nunderlined&rn yellow" "&" "underlined yellow"
		"&e&nunderlined&rn yellow" "!" "&e&nunderlined&rn yellow"
		"!e!nunderlined!rn yellow" "!" "underlined yellow"
		"§_4 gives §4red" "§" "§4 gives red"
	End

	It "handles '$1'"
		DAHLIA_MARKER="$2"
		When call dahlia_clean "$1"
		The output should equal "$3"
		The status should be success
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
End
