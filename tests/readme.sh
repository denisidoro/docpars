#!/usr/bin/env bash

source "${DOCPARS_HOME}/scripts/core.sh"

_cat() {
    cat "${DOCPARS_HOME}/README.md"
}

_code() {
    _cat \
        | grep '/usr/bin/env' -A999 \
        | grep -m1 '```' -B999 \
        | grep -v '```' \
        | sed "s|/path/to/docpars|${DOCPARS_BIN}|"
} 

_backticked_line() {
    _cat \
        | grep "$1" \
        | grep -Eo '`[^`]+' \
        | head -n1 \
        | tr -d '`'
}

_run() {
    local -r filename="${DOCPARS_HOME}/target/coffee"
    local -r code="$(_code)"
    local -r input=($(_backticked_line "If you run" | tr ' ' '\n' | tail -n +2))
    local -r output="$(_backticked_line "should be printed")"

    mkdir -p "$(dirname "$filename")" 2>/dev/null || true
    rm "$filename" 2>/dev/null || true
    echo "$code" > "$filename"
    chmod +x "$filename"

    "$filename" "${input[@]}" \
        | test::equals "$output"
} 

test::set_suite "README.md"
test::run "bash script works" _run