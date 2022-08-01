#!/usr/bin/env bash

export PROJ_HOME="$DOCPARS_HOME"
export PROJ_NAME="docpars"
export CARGO_PATH="${DOCPARS_HOME}/core/Cargo.toml"

# TODO: bump dotfiles + remove this fn
log::note() { log::info "$@"; }
export -f log::note

dot::clone() {
  git clone 'https://github.com/denisidoro/dotfiles' "$DOTFILES"
  cd "$DOTFILES"
  git checkout 'v2022.07.16'
}

dot::clone_if_necessary() {
  [ -n "${DOTFILES:-}" ] && [ -x "${DOTFILES}/bin/dot" ] && return
  export DOTFILES="${DOCPARS_HOME}/target/dotfiles"
  dot::clone
}

dot::clone_if_necessary
parse::python() {
   local -r msg="$1"
   shift
   "$DOCOPT_BIN" -h "$msg" : "$@"
}

parse::docpars() {
   local -r msg="$1"
   shift
   "$DOCPARS_BIN" -h "$msg" : "$@"
}

parse::compare() {
   local -r docopt_output="$(parse::python "$@" | sort)"
   local -r docpars_output="$(parse::docpars "$@" | sort)"
   echo "$docpars_output" | test::equals "$docopt_output"
}

fixture::get() {
   cat "${DOCPARS_HOME}/tests/docs/${1}.txt"
}

export DOCPARS_HOME="${DOCPARS_HOME:-$(cd "$(dirname "$0")/.." && pwd)}"
export PYTHONDONTWRITEBYTECODE=x

dot::clone_if_necessary
source "${DOTFILES}/scripts/core/main.sh"

export DOCOPT_BIN="${DOTFILES}/scripts/core/docopts"
export DOCPARS_BIN="${DOCPARS_HOME}/target/release/docpars"
[ -f "$DOCPARS_BIN" ] || export DOCPARS_BIN="${DOCPARS_HOME}/target/debug/docpars"
[ -f "$DOCPARS_BIN" ] || export DOCPARS_BIN="${DOCPARS_HOME}/scripts/run"