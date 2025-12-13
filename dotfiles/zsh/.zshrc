# --- Omarchy Compatibility ---
export PATH="$HOME/.local/share/omarchy/bin:$PATH"

# --- Plugin Manager ---
eval "$(sheldon source)"

# --- Bindings ---
# Ctrl+Space to accept autosuggestions
bindkey '^@' autosuggest-accept

# --- Navigation ---
eval "$(zoxide init zsh)"
setopt autocd

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory

# --- History Search (Up/Down Arrow) ---
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Fallback for terminfo
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" up-line-or-beginning-search 2>/dev/null
bindkey "$terminfo[kcud1]" down-line-or-beginning-search 2>/dev/null

# --- Completion System ---
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# --- Aliases ---
alias ..='cd ..'
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias g='git'
alias d='docker'
alias cd='z'
eval "$(direnv hook zsh)"
