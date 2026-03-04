#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OH_MY_ZSH_DIR="${HOME}/.oh-my-zsh"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${OH_MY_ZSH_DIR}/custom}"

log() {
  echo "[dotfiles-install] $*"
}

warn() {
  echo "[dotfiles-install][warn] $*" >&2
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "$target_dir/.git" ]]; then
    git -C "$target_dir" pull --ff-only >/dev/null 2>&1 || warn "Could not update $target_dir"
    return 0
  fi

  rm -rf "$target_dir"
  git clone --depth=1 "$repo_url" "$target_dir" >/dev/null
}

ensure_oh_my_zsh() {
  if [[ -d "$OH_MY_ZSH_DIR" ]]; then
    return 0
  fi

  require_cmd curl
  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_zsh_plugins() {
  mkdir -p "$ZSH_CUSTOM_DIR/plugins"
  clone_or_update "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
  clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
  clone_or_update "https://github.com/zsh-users/zsh-completions.git" "$ZSH_CUSTOM_DIR/plugins/zsh-completions"
  clone_or_update "https://github.com/Aloxaf/fzf-tab.git" "$ZSH_CUSTOM_DIR/plugins/fzf-tab"
}

apply_files() {
  mkdir -p "${HOME}/.config"
  if command -v stow >/dev/null 2>&1; then
    log "Applying dotfiles with stow"
    stow --target="${HOME}" --dir="$DOTFILES_DIR" home
  else
    warn "stow not found; linking ~/.zshrc directly"
    ln -snf "$DOTFILES_DIR/home/.zshrc" "${HOME}/.zshrc"
  fi

  cp -f "$DOTFILES_DIR/config/starship/starship.toml" "${HOME}/.config/starship.toml"
}

main() {
  require_cmd git
  ensure_oh_my_zsh
  install_zsh_plugins
  apply_files
  log "Dotfiles installed successfully."
}

main "$@"
