#!/usr/bin/env bash
#
# Dotfiles and install helper
#

# Helper variables, override with ENVs like `VERBOSE=1 helpers.sh help`
: ${VERBOSE:=0}
: ${CP:=/bin/cp}
: ${LN:=/bin/ln}
: ${MKDIR:=/bin/mkdir}
: ${RM:=/bin/rm}
: ${DIRNAME:=/usr/bin/dirname}

case "$1" in
  install)
    echo "install stuff"
    case "$2" in
      *)
        echo "-> $0 install [brew]"
    esac
    ;;
  brew)
    echo "brew commands"
    ;;
  dotfiles)
    echo "dotfiles manager"
    ;;
  other)
    echo "Other commands"
    ;;
  *)
    echo $"Usage: $0 [install | brew | dotfiles | other]"
    echo $" All commands have their own subcommands."
    echo $" When in doubt run the subcommand to show list."
    echo ""
    exit 1
    ;;
esac
