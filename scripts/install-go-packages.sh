#!/usr/bin/env bash
# Install Go packages
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

! have go && msg "go hasn't been installed yet." && exit 0

packages=(
  # A shell parser, formatter, and interpreter with bash support; includes shfmt
  mvdan.cc/sh/v3/cmd/shfmt@latest
  # sysadmin/scripting utilities, distributed as a single binary
  github.com/skx/sysbox@latest
  # Git Profile allows you to switch between user profiles in git repos
  github.com/dotzero/git-profile@latest
  # An extensible command line tool or library to format yaml files.
  github.com/google/yamlfmt/cmd/yamlfmt@latest
  # Parsing HTML at the command line
  github.com/ericchiang/pup@latest
  # HTML to Markdown converter
  github.com/suntong/html2md@latest
  # cheat allows you to create and view interactive cheatsheets on the cli.
  github.com/cheat/cheat/cmd/cheat@latest
  # Render markdown on the CLI, with pizzazz! 💅
  github.com/charmbracelet/glow@latest
  # Static checker for GitHub Actions workflow files
  github.com/rhysd/actionlint/cmd/actionlint@latest
)

for pkg in "${packages[@]}"; do
  # Trim spaces
  pkg=${pkg// /}
  # Skip comments
  if [[ ${pkg:0:1} == "#" ]]; then continue; fi

  msg_run "Installing go package:" "$pkg"
  go install "$pkg"
  echo ""
done

msg "Installing completions for selected packages"

have git-profile && {
  git-profile completion zsh > "$ZSH_CUSTOM_COMPLETION_PATH/git-profile" \
    && msg_yay "Installed completions for git-profile"
}

msg_ok "Done"
