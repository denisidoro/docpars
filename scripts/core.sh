#!/usr/bin/env bash

dot::install_if_necessary() {
    [ -n "${DOTFILES:-}" ] && return
    export DOTFILES="${DOCPARS_HOME}/dotfiles"
    export PATH="${DOTFILES}/bin:${PATH}"
    git clone "https://github.com/denisidoro/dotfiles.git" "$DOTFILES"
    cd "$DOTFILES"
    git checkout "bc74f8"
}

dot::install_if_necessary