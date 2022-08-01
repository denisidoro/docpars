#!/usr/bin/env bash

source "${DOCPARS_HOME}/scripts/core.sh"

_msg() {
   fixture::get "naval_fate"
}

_benchmark() {
   local -r bin="$1"
   local -r msg="$(_msg)"

   rm -rf "${DOTFILES}/scripts/__pycache__" 2>/dev/null | true
   local -r res="$(hyperfine --warmup 1 "$bin -h \"$msg\" : mine remove 2 4 --moored" | grep -E 'Time|Range')"
   echo "$res"

   [[ "$bin" = *docpars* ]] || return 0

   local -r millis="$(echo "$res" | grep -m1 -Eo '[0-9]+' | head -n1)"
   [[ "$millis" -gt 25 ]] && return 1 || true
}

test::set_suite "benchmark"
fn=test::skip
has hyperfine && fn=test::run

$fn "$DOCOPT_BIN" _benchmark "$DOCOPT_BIN"
$fn "$DOCPARS_BIN" _benchmark "$DOCPARS_BIN"
