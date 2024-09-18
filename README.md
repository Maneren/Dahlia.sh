[![Dahlia spec](https://img.shields.io/badge/Dahlia%20spec-v1.0-pink?style=flat)](https://github.com/dahlia-lib/spec)

# Dahlia.sh

Dahlia is a simple text formatting package, inspired by text formatting in
the game Minecraft.

Text is formatted similarly to the game. With Dahlia, it is formatted by typing
a special character & followed by a format code and finally the text to be formatted.

## Installation

Download the source and put the `dahlia` executable in your `$PATH`.

## Dependencies

The scripts are written for GNU Bash 5.0/ZSH 5.9 and newer.

Other dependencies are reasonably modern (if someone knows how to find the
minimal required version, please let me know).:

- GNU `grep` and `sed` (non GNU version probably work too but aren't officially supported)
- GNU coreutils - `dirname`, `sort`, `uniq`

_Note: It is expected that all those commands are available in the `$PATH`._

## Usage

See `dahlia --help`

```txt
Dahlia — a simple text formatting package, inspired by the game Minecraft.

Usage:
  dahlia [--] TEXT
    parse the TEXT and color it

  dahlia {clean|clean_ansi} TEXT
    remove Dahlia/ANSI codes from TEXT

  dahlia test
    print short test string

  dahlia {--help|help}
    print this help

Configuration via environment variables:
  DAHLIA_DEPTH - color depth
    either case insensitive string AUTO, TTY, LOW, MEDIUM or HIGH or number of bits 0, 3, 4, 8, 24
    (default or AUTO is tries to infer the best based on the terminal)

  DAHLIA_MARKER - specify what marker to use (default is &)

  DAHLIA_AUTO_RESET - if not 0 auto add reset (default is 1)

Respects NO_COLOR environment variable.
```

## Library

To use Dahlia in your project, source the `lib.sh` file in your script.

### API

The API follows [the specification](https://github.com/dahlia-lib/spec) version 1.0.
It exposes following public functions:

- `dahlia_convert`
  Format given string with Dahlia (no trailing newline).
- `dahlia_print`
  Format given string with Dahlia and echo it (adds newline as needed).
- `dahlia_input`
  Get user input with Dahlia formatted prompt and return it.
- `dahlia_clean`
  Remove Dahlia formatting codes from given string.
- `dahlia_clean_ansi`
  Remove all ANSI codes from given string.

For more details, see the documentation comments in [lib.sh](lib/lib.sh) and
the [specification](https://github.com/dahlia-lib/spec).

### Examples

![example usage of the executable](https://github.com/Maneren/Dahlia.sh/assets/49210777/04cf2c4f-2301-478e-9773-ba8186efbfb1)

## License

Dahlia is licensed under the MIT License.
