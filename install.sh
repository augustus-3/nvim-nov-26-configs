#!/usr/bin/env bash
# install.sh — set this Neovim config up on a new machine.
#
#   git clone <repo> ~/.config/nvim && ~/.config/nvim/install.sh
#
# Steps, in order: install system packages (Arch only), back up any existing
# Neovim state, link the helper scripts, create the org directories, and
# restore plugins at the exact commits in lazy-lock.json.
#
# Safe to re-run: every step is idempotent apart from the backup, which only
# moves state that this repo did not put there.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="${HOME}/.local/bin"
org_dir="${HOME}/orgfiles"
stamp="$(date +%Y%m%d%H%M%S)"

say() { printf '\n==> %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------- packages --

# Everything the config actually reaches for. Grouped so a machine that does
# not need, say, LaTeX can drop a line rather than untangle one long list.
pacman_packages=(
  # editor + the tools LazyVim shells out to
  neovim git curl unzip
  ripgrep fd lazygit
  base-devel tree-sitter-cli # treesitter compiles its parsers locally
  nodejs npm                 # mason installs most LSP servers through npm
  wl-clipboard               # swap for xclip on X11

  # lua/plugins/latex.lua — vimtex drives latexmk, texide drives tmux
  tmux
  texlive-basic texlive-latex texlive-latexextra
  texlive-binextra texlive-fontsrecommended biber

  # lua/plugins/R-nvim.lua
  r

  # lua/plugins/jupynium.lua — Selenium drives Firefox through geckodriver,
  # and bin/jupynium-venv builds the notebook venv with uv
  firefox geckodriver uv

  # the dashboard and statusline use Nerd Font glyphs
  ttf-jetbrains-mono-nerd
)

# Not in the official repos, so these go through an AUR helper. tdf is the
# terminal PDF viewer texide opens in its tmux pane.
aur_packages=(tdf)
aur_helper=""

install_packages() {
  if ! have pacman; then
    say "Not an Arch system — skipping packages."
    printf 'Install these by hand: %s %s\n' \
      "${pacman_packages[*]}" "${aur_packages[*]}"
    return
  fi

  say "Installing system packages"
  sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"

  install_aur_packages
}

# yay is not in the official repos, so it has to be bootstrapped the manual
# way: clone the package, build it, install it. yay-bin ships a prebuilt
# binary, which saves pulling in Go just to compile the thing that installs
# everything else. makepkg refuses to run as root, so there is no sudo here —
# it asks for the password itself at the install step.
ensure_aur_helper() {
  local helper
  for helper in paru yay; do
    if have "$helper"; then
      aur_helper="$helper"
      return
    fi
  done

  say "Bootstrapping yay from the AUR"
  local build_dir
  build_dir="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
  (cd "$build_dir/yay-bin" && makepkg -si --needed --noconfirm)
  rm -rf "$build_dir"
  aur_helper=yay
}

install_aur_packages() {
  say "Installing AUR packages"
  ensure_aur_helper
  "$aur_helper" -S --needed --noconfirm "${aur_packages[@]}"
}

# ------------------------------------------------------------------ backup --

# lazy.nvim, mason and treesitter all keep compiled state outside this repo.
# Stale state from an older install breaks in confusing ways, so move it aside.
backup_existing_state() {
  local moved=0 dir
  for dir in "${XDG_DATA_HOME:-$HOME/.local/share}/nvim" \
             "${XDG_STATE_HOME:-$HOME/.local/state}/nvim" \
             "${XDG_CACHE_HOME:-$HOME/.cache}/nvim"; do
    [ -e "$dir" ] || continue
    say "Moving $dir aside to $dir.bak.$stamp"
    mv "$dir" "$dir.bak.$stamp"
    moved=1
  done
  [ "$moved" -eq 0 ] && say "No previous Neovim state to back up."
  return 0
}

# ------------------------------------------------------------------- links --

link_helpers() {
  say "Linking helper scripts into $bin_dir"
  mkdir -p "$bin_dir"
  local script
  for script in "$repo"/bin/*; do
    ln -sfn "$script" "$bin_dir/$(basename "$script")"
  done

  case ":$PATH:" in
    *":$bin_dir:"*) ;;
    *) printf 'Note: %s is not on your PATH — add it to your shell rc.\n' "$bin_dir" ;;
  esac
}

# --------------------------------------------------------------- org files --

# org_agenda_files and org-roam's directory are absolute paths in the config;
# orgmode errors on a missing directory rather than creating one.
create_org_dirs() {
  say "Creating $org_dir and $org_dir/roam"
  mkdir -p "$org_dir/roam"
  [ -e "$org_dir/refile.org" ] || : >"$org_dir/refile.org"
}

# ----------------------------------------------------------------- plugins --

# `Lazy! restore` installs the exact commits in lazy-lock.json, rather than
# whatever is at HEAD today — the point of committing the lockfile.
install_plugins() {
  # jupynium.nvim's build step runs bin/jupynium-venv, which needs uv.
  have uv || say "Warning: uv is not installed — jupynium's build step will fail."

  say "Installing plugins from lazy-lock.json (this takes a few minutes)"
  nvim --headless "+Lazy! restore" +qa
  say "Installing LSP servers and formatters"
  nvim --headless "+MasonUpdate" +qa || true
}

# -------------------------------------------------------------------- main --

if [ "$repo" != "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" ]; then
  printf 'This repo is at %s, but Neovim reads ~/.config/nvim.\n' "$repo" >&2
  printf 'Clone it there, or symlink it:  ln -s %s ~/.config/nvim\n' "$repo" >&2
  exit 1
fi

install_packages
backup_existing_state
link_helpers
create_org_dirs
install_plugins

say "Done. Start Neovim with: nvim"
