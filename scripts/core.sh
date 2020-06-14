#!/usr/bin/env bash

DOTFILES_COMMIT_HASH="bc74f8"

dot::clone() {
   git clone "https://github.com/denisidoro/dotfiles.git" "$DOTFILES"
   cd "$DOTFILES" && git checkout "$DOTFILES_COMMIT_HASH"
}

dot::install_if_necessary() {
   [ -n "${DOTFILES:-}" ] && return
   export DOTFILES="${DOCPARS_HOME}/dotfiles"
   export PATH="${DOTFILES}/bin:${PATH}"
   $(dot::clone 2>/dev/null || true)
}

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

dot::install_if_necessary
source "${DOTFILES}/scripts/core/main.sh"

export DOCOPT_BIN="${DOTFILES}/scripts/core/docopts"
export DOCPARS_BIN="${DOCPARS_HOME}/target/release/docpars"
[ -f "$DOCPARS_BIN" ] || export DOCPARS_BIN="${DOCPARS_HOME}/target/debug/docpars"
[ -f "$DOCPARS_BIN" ] || export DOCPARS_BIN="${DOCPARS_HOME}/scripts/run"