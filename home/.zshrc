# Personal Zsh config (dotfiles)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git fzf zsh-autosuggestions zsh-syntax-highlighting zsh-completions fzf-tab)

if [[ -s "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Configuração Automática de Identidade Git
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    git config --global init.defaultBranch main
fi
