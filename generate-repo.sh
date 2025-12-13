#!/bin/bash

# 1. CLEAN SLATE
rm -rf installs uninstalls dotfiles

# 2. DEFINE MODULES
MODULES="stow zsh nix cursor zed marimo tmux hyprland ghostty nvim"

# 3. SETUP DIRECTORIES
for mod in $MODULES; do
    mkdir -p installs/$mod
    mkdir -p uninstalls/$mod
done

# Create Data Directories
mkdir -p dotfiles/{zsh/.config/sheldon,tmux,ghostty/.config/ghostty,hyprland/.config/hypr,nvim/.config/nvim}

# ==========================================
#  MODULE: STOW
# ==========================================
cat <<'EOF' > installs/stow/install.sh
#!/bin/bash
echo "🔗 [Stow] Installing..."
sudo pacman -S --needed --noconfirm stow
EOF
cat <<'EOF' > uninstalls/stow/uninstall.sh
#!/bin/bash
echo "🔗 [Stow] Removing..."
sudo pacman -Rns --noconfirm stow
EOF

# ==========================================
#  MODULE: ZSH (Full Install + Completion Fix)
# ==========================================

# 1. Sheldon Config
cat <<TOML > dotfiles/zsh/.config/sheldon/plugins.toml
shell = "zsh"
[plugins.zsh-defer]
github = "romkatv/zsh-defer"
[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"
use = ["{{ name }}.zsh"]
[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"
[plugins.starship]
inline = 'eval "\$(starship init zsh)"'
TOML

# 2. .zshrc (Now with Tab Completion!)
cat <<RC > dotfiles/zsh/.zshrc
# --- Omarchy Compatibility ---
export PATH="\$HOME/.local/share/omarchy/bin:\$PATH"

# --- Plugin Manager ---
eval "\$(sheldon source)"

# --- Navigation ---
eval "\$(zoxide init zsh)"
setopt autocd

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory

# --- COMPLETION SYSTEM (The Fix) ---
autoload -Uz compinit
compinit
# Menu selection (arrow keys to pick)
zstyle ':completion:*' menu select
# Case insensitive (cd dow -> Downloads)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# --- Aliases ---
alias ..='cd ..'
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias g='git'
alias d='docker'
alias cd='z'
RC

# 3. Install Script (Matches your existing logic)
cat <<'EOF' > installs/zsh/install.sh
#!/bin/bash
echo "📦 [Zsh] Installing packages..."
sudo pacman -S --needed --noconfirm zsh zsh-completions sheldon starship zoxide fzf bat eza stow

echo "🔗 [Zsh] Stowing dotfiles..."
# Clean up potential conflicts first
[ -f "$HOME/.zshrc" ] && rm "$HOME/.zshrc"
[ -d "$HOME/.config/sheldon" ] && rm -rf "$HOME/.config/sheldon"

# Run stow from the repo root
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" zsh

echo "🔌 [Zsh] Linking to Bash..."
BASHRC="$HOME/.bashrc"
SWITCH='if [[ $- == *i* && -x $(command -v zsh) ]]; then export SHELL=$(which zsh); exec zsh -l; fi'
grep -q "exec zsh -l" "$BASHRC" || echo "$SWITCH" >> "$BASHRC"
EOF

cat <<'EOF' > uninstalls/zsh/uninstall.sh
#!/bin/bash
echo "🐚 [Zsh] Removing..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" zsh 2>/dev/null
sed -i '/exec zsh -l/d' "$HOME/.bashrc"
sudo pacman -Rns --noconfirm zsh zsh-completions sheldon zoxide
EOF

# ==========================================
#  MODULE: NVIM (Replacement Strategy)
# ==========================================
# Dummy config for Stow
cat <<LUA > dotfiles/nvim/.config/nvim/init.lua
print("Hello from your Custom Nvim Config!")
-- Replace this file with your actual dotfiles content later
LUA

cat <<'EOF' > installs/nvim/install.sh
#!/bin/bash
echo "📝 [Nvim] replacing Config..."
# SCORCHED EARTH: Delete Omarchy's Nvim config entirely
rm -rf "$HOME/.config/nvim"
rm -rf "$HOME/.local/share/nvim"

# Link ours
mkdir -p "$HOME/.config"
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" nvim
EOF

cat <<'EOF' > uninstalls/nvim/uninstall.sh
#!/bin/bash
echo "📝 [Nvim] Unstowing..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" nvim
EOF

# ==========================================
#  MODULE: GHOSTTY (Replacement Strategy)
# ==========================================
cat <<CONF > dotfiles/ghostty/.config/ghostty/config
theme = catppuccin-mocha
font-family = "JetBrainsMono Nerd Font"
font-size = 13
CONF

cat <<'EOF' > installs/ghostty/install.sh
#!/bin/bash
echo "👻 [Ghostty] Replacing Config..."
mkdir -p "$HOME/.config/ghostty"
# SCORCHED EARTH: Delete existing config
rm -f "$HOME/.config/ghostty/config"
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" ghostty
EOF

cat <<'EOF' > uninstalls/ghostty/uninstall.sh
#!/bin/bash
echo "👻 [Ghostty] Unstowing..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" ghostty
EOF

# ==========================================
#  MODULE: HYPRLAND (Additive Strategy)
# ==========================================
# 1. Natural Scroll
cat <<CONF > dotfiles/hyprland/.config/hypr/user_settings.conf
input {
    touchpad {
        natural_scroll = true
    }
}
CONF

# 2. Keybindings
cat <<CONF > dotfiles/hyprland/.config/hypr/user_binds.conf
bind = SUPER, G, exec, omarchy-launch-webapp "https://gemini.google.com"
bind = SUPER, M, exec, omarchy-launch-webapp "https://mail.google.com"
bind = SUPER, Z, exec, zed
CONF

cat <<'EOF' > installs/hyprland/install.sh
#!/bin/bash
echo "🔗 [Hyprland] Stowing Additive Configs..."
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" hyprland

# ADDITIVE LOGIC:
# We check if the main file imports our files. If not, we append the import.
CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$CONF" ]; then
    grep -q "user_settings.conf" "$CONF" || echo "source = ~/.config/hypr/user_settings.conf" >> "$CONF"
    grep -q "user_binds.conf" "$CONF" || echo "source = ~/.config/hypr/user_binds.conf" >> "$CONF"
fi
EOF

cat <<'EOF' > uninstalls/hyprland/uninstall.sh
#!/bin/bash
echo "🔗 [Hyprland] Cleaning up..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" hyprland
# Remove the import lines
sed -i '/user_settings.conf/d' "$HOME/.config/hypr/hyprland.conf"
sed -i '/user_binds.conf/d' "$HOME/.config/hypr/hyprland.conf"
EOF

# ==========================================
#  MODULE: NIX
# ==========================================
cat <<'EOF' > installs/nix/install.sh
#!/bin/bash
echo "❄️ [Nix] Installing..."
sudo pacman -S --needed --noconfirm nix direnv
sudo systemctl enable --now nix-daemon.service
sudo usermod -aG nix-users $USER
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
# Hook into Zsh
grep -q "direnv hook zsh" "$HOME/.zshrc" || echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"
EOF

cat <<'EOF' > uninstalls/nix/uninstall.sh
#!/bin/bash
echo "❄️ [Nix] Removing..."
sudo pacman -Rns --noconfirm nix direnv
sed -i '/direnv hook zsh/d' "$HOME/.zshrc"
EOF

# ==========================================
#  MODULE: APPS (Cursor, Zed, Marimo)
# ==========================================
cat <<'EOF' > installs/cursor/install.sh
#!/bin/bash
echo "📦 [Cursor] Installing..."
if command -v yay &> /dev/null; then H="yay"; else H="paru"; fi
$H -S --needed --noconfirm cursor-bin
EOF
cat <<'EOF' > uninstalls/cursor/uninstall.sh
#!/bin/bash
echo "📦 [Cursor] Removing..."
sudo pacman -Rns --noconfirm cursor-bin
EOF

cat <<'EOF' > installs/zed/install.sh
#!/bin/bash
echo "📦 [Zed] Installing..."
if command -v yay &> /dev/null; then H="yay"; else H="paru"; fi
$H -S --needed --noconfirm zed-preview-bin
EOF
cat <<'EOF' > uninstalls/zed/uninstall.sh
#!/bin/bash
echo "📦 [Zed] Removing..."
sudo pacman -Rns --noconfirm zed-preview-bin
EOF

cat <<'EOF' > installs/marimo/install.sh
#!/bin/bash
echo "📦 [Marimo] Installing..."
if ! command -v pipx &> /dev/null; then sudo pacman -S --needed --noconfirm python-pipx; fi
pipx install marimo
EOF
cat <<'EOF' > uninstalls/marimo/uninstall.sh
#!/bin/bash
echo "📦 [Marimo] Removing..."
pipx uninstall marimo
EOF

# ==========================================
#  MODULE: TMUX (Replacement)
# ==========================================
cat <<CONF > dotfiles/tmux/.tmux.conf
set-option -sa terminal-overrides ",xterm*:Tc"
set -g mouse on
set -g base-index 1
bind -n M-H previous-window
bind -n M-L next-window
CONF

cat <<'EOF' > installs/tmux/install.sh
#!/bin/bash
echo "🟩 [Tmux] Replacing Config..."
sudo pacman -S --needed --noconfirm tmux
rm -f "$HOME/.tmux.conf"
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" tmux
EOF

cat <<'EOF' > uninstalls/tmux/uninstall.sh
#!/bin/bash
echo "🟩 [Tmux] Removing..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" tmux
sudo pacman -Rns --noconfirm tmux
EOF

# ==========================================
#  MASTER SCRIPTS
# ==========================================
cat <<'EOF' > install-supplement.sh
#!/bin/bash
export SUPPLEMENT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🚀 Starting Master Install..."
# Stow first
[ -f "$SUPPLEMENT_ROOT/installs/stow/install.sh" ] && bash "$SUPPLEMENT_ROOT/installs/stow/install.sh"

for script in "$SUPPLEMENT_ROOT"/installs/*/install.sh; do
    MODULE=$(basename $(dirname "$script"))
    if [ "$MODULE" != "stow" ]; then
        echo "▶️ Installing: $MODULE"
        bash "$script"
    fi
done
echo "🎉 Complete!"
EOF

cat <<'EOF' > uninstall-supplement.sh
#!/bin/bash
export SUPPLEMENT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🗑️ Starting Master Uninstall..."
for script in "$SUPPLEMENT_ROOT"/uninstalls/*/uninstall.sh; do
    MODULE=$(basename $(dirname "$script"))
    echo "▶️ Removing: $MODULE"
    bash "$script"
done
echo "✅ Complete."
EOF

# FINISH
chmod +x installs/*/*.sh uninstalls/*/*.sh *.sh
echo "✅ Repository with Fixed Zsh Completion Generated."
