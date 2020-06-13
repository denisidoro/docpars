#!/usr/bin/env bash

source "${DOCPARS_HOME}/scripts/core.sh"

_msg() {
   fixture::get "naval_fate"
}

_one_bench() {
   local -r msg="$1"
   local -r bin="$2"
   hyperfine "$bin -h \"$msg\" : ship new foo" --warmup 3
}

_benchmark() {
   local -r msg="$(_msg)"
   _one_bench "$msg" "$DOCOPT_BIN"
   _one_bench "$msg" "$DOCPARS_BIN"
}

test::set_suite "benchmark"
fn=test::skip
platform::command_exists hyperfine && fn=test::run
$fn "time" _benchmark
