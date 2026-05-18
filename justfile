format_paths := "Sources Tests Package.swift"
swift_test_flags := "-Xswiftc -strict-concurrency=complete -Xswiftc -warnings-as-errors"

default:
    just --list

format:
    swift format format --recursive --in-place {{format_paths}}

lint:
    swift format lint --recursive --strict {{format_paths}}

build:
    swift build

test:
    swift test {{swift_test_flags}}

check: lint test
