#!/usr/bin/env bash

parse::python() {
   local -r msg="$1"
   shift
   "${DOTFILES}/scripts/core/docopts" -h "$msg" : "$@"
}

parse::docpars() {
   local -r msg="$1"
   shift
   "${DOCPARS_HOME}/scripts/run" -h "$msg" : "$@"
}

parse::compare() {
   local -r docopt_output="$(parse::python "$@" | sort)"
   local -r docpars_output="$(parse::docpars "$@" | sort)"
   echo "$docpars_output" | test::equals "$docopt_output"
}

fixture::get() {
   cat "${DOCPARS_HOME}/tests/docs/${1}.txt"
}