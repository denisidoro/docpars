# docpars [![Actions Status](https://github.com/denisidoro/docpars/workflows/CI/badge.svg)](https://github.com/denisidoro/docpars/actions) ![GitHub release](https://img.shields.io/github/v/release/denisidoro/docpars?include_prereleases)

An ultra-fast parser for declarative command-line options for your shell scripts.

It implements the [Docopt syntax](http://docopt.org/) and is written in Rust.

Table of contents
-----------------

   * [Usage](#usage)
   * [Motivation](#motivation)
   * [Installation](#installation)
      * [Using Homebrew or Linuxbrew](#using-homebrew-or-linuxbrew)
      * [Using cargo](#using-cargo)
      * [Downloading pre-compiled binaries](#downloading-pre-compiled-binaries)
      * [Building from source](#building-from-source)
   * [Credits](#credits)

Usage
------------

If you run `coffee make --dark` for the following script...
```bash
#!/usr/bin/env bash

##? Coffee tool
##?
##? Usage:
##?     coffee make [--dark]
##?     coffee drink

# This function could be included in a helper bash file 
# and imported by all your scripts
args::parse() {
   eval "$(/path/to/docpars -h "$(grep "^##?" "$0" | cut -c 5-)" : "$@")"
}

args::parse "$@"

if $drink; then
   echo "Drinking coffee..."
elif $make; then
   $dark && echo "Making dark coffee..." || echo "Making coffee..."
fi
```

...then `Making dark coffee...` should be printed.

Motivation
------------
The [default implementation](https://github.com/docopt/docopts) of docopt for shell scripts use Python under the hood. You may want to use *docpars* instead in the following scenarios

### You don't want to install Python

This may be the case of CI/CD instances, minimal docker containers or environments where you may want to run some scripts but aren't equipped with your whole dev arsenal, such as [Termux on Android](https://termux.com/) or [WSL on Windows](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

Instead of installing Python you can simply drop a ~1MB static binary.

### You want extreme performance

[Benchmarks](https://github.com/denisidoro/docpars/blob/master/docs/benchmark.md) show that *docpars* is up to 5.7 times faster than the Python equivalent.

This may not be noticible for most use-cases but it may make the difference if your script is called inside a for loop, for example.

Installation
------------

### Using [Homebrew](http://brew.sh/) or [Linuxbrew](http://linuxbrew.sh/)

```sh
brew install denisidoro/tools/docpars
```

### Using [cargo](https://github.com/rust-lang/cargo)

```bash
cargo install docpars
```

### Downloading pre-compiled binaries

You can download built binaries [here](https://github.com/denisidoro/docpars/releases/latest).

They are available for OSX, Android and Linux with ARM and x86_64 variants.

### Building from source

```bash
git clone https://github.com/denisidoro/docpars ~/.docpars
cd ~/.docpars
cargo install --path .
```

Credits
------------

Most work was done in [docopt.rs](https://github.com/docopt/docopt.rs) by [BurntSushi](https://github.com/BurntSushi), where the actual Docopt parsing is implemented.