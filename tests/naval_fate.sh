#!/usr/bin/env bash

source "${DOCPARS_HOME}/scripts/core.sh"

_t() {
   local -r msg="$1"
   shift
   test::run "$*" parse::compare "$msg" "$@"
}

_msg() {
   fixture::get "naval_fate"
}

_run_compare() {
   local -r msg="$(_msg)"
   _t "$msg"
   _t "$msg" ship
   _t "$msg" ship new foo
   _t "$msg" ship new foo bar
   _t "$msg" ship foo move 10 20
   _t "$msg" ship foo move 10 20 --speed 30
   _t "$msg" ship foo move 10 20 -s 30
   _t "$msg" ship shoot 30 50
   _t "$msg" mine set 2 4
   _t "$msg" mine set 2 4 --moored
   _t "$msg" mine remove 2 4 --moored
   test::skip "--version" parse::compare "$msg" "--version"
}

_run_help() {
   local -r msg="$(_msg)"
   local -r output="$(parse::docpars "$msg" --help)"
   parse::docpars "$msg" -h | test::equals "$output"
   eval "$output" | test::equals "$msg"
}

test::set_suite "naval_fate - compare"
test::lazy_run _run_compare

test::set_suite "naval_fate - help"
test::lazy_run _run_help