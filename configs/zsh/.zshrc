# ==========================================
#  LBS ZSH CONFIGURATION
# ==========================================

# --- Environment ---
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR="nvim"
export TERMINAL="ghostty"

# --- History Configuration ---
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# --- Plugin Manager (Sheldon) ---
if command -v sheldon &> /dev/null; then
    eval "$(sheldon source)"
fi

# --- Prompt & Navigation ---
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# --- Nix / Direnv Hook ---
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# --- Aliases ---

# Navigation
alias cd='z'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# File Listing (Eza)
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'

# Git shortcuts
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias gss='git status'
alias gp='git push'

# Tools & Utilities
alias cat='bat'
alias grep='rg'
alias d='docker'
alias r='rails'
alias p='python'
alias n='nvim'
alias decompress='tar -xzf'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# --- Key Bindings & Completion ---

# 1. Autosuggestion Accept (Ctrl + Space)
bindkey '^@' autosuggest-accept

# 2. History Search (Up/Down Arrow)
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
bindkey "$terminfo[kcud1]" down-line-or-beginning-search

# 3. Intelligent Tab Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# --- Custom Nix Template Function ---
# This function copies the Flake files from the stowed repository path
# to the current directory, enabling quick project initialization.
function nix-template-init() {
    local TEMPLATE_DIR="/home/lbs-vadar/supplement/configs/nix/.config/nix/templates/default"
    
    if [ ! -d "$TEMPLATE_DIR" ]; then
        echo "Error: Nix template source directory not found at $TEMPLATE_DIR"
        return 1
    fi

    echo "🧱 Initializing Nix Flake environment from custom template..."
    
    # Copy the Flake files directly
    cp "$TEMPLATE_DIR/flake.nix" .
    cp "$TEMPLATE_DIR/flake.lock" .
    
    # Create the direnv file for automatic loading
    echo 'use flake' > .envrc
    
    echo "✅ Flake initialization complete! Run 'direnv allow' to build the environment."
}
alias nix-init="nix-template-init"
