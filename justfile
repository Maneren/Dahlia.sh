[private]
default:
    @just --list

fmt:
    shfmt -s -w -kp ./lib dahlia
    altshfmt -s -w spec

coverage:
    shellspec --kcov

check:
    shellcheck ./lib/* dahlia
    shellspec
    shfmt -d ./lib dahlia
    altshfmt -d spec
