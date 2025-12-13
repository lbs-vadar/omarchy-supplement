#!/bin/bash

# 1. CLEANUP (Start Fresh)
rm -rf installs uninstalls dotfiles

# 2. SETUP DIRECTORIES
APPS="nix cursor zed marimo tmux hyprland ghostty nvim"
for app in $APPS; do
    mkdir -p installs/$app
    mkdir -p uninstalls/$app
done
mkdir -p dotfiles/{tmux,ghostty/.config/ghostty,hyprland/.config/hypr,nvim/.config/nvim/lua/plugins}

# ==========================================
#  MODULE: NIX (Environment Manager)
# ==========================================
cat <<'EOF' > installs/nix/install.sh
#!/bin/bash
echo "❄️ [Nix] Installing..."
sudo pacman -S --needed --noconfirm nix direnv
sudo systemctl enable --now nix-daemon.service
sudo usermod -aG nix-users $USER

# Configure Flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Hook into Zsh
if ! grep -q "direnv hook zsh" "$HOME/.zshrc"; then
    echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"
fi
EOF

cat <<'EOF' > uninstalls/nix/uninstall.sh
#!/bin/bash
echo "❄️ [Nix] Uninstalling tools..."
sudo pacman -Rns --noconfirm nix direnv
sed -i '/direnv hook zsh/d' "$HOME/.zshrc"
# Note: /nix/store is left intact for safety
EOF

# ==========================================
#  MODULE: CURSOR (AI Editor)
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

# ==========================================
#  MODULE: ZED (Fast Editor)
# ==========================================
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

# ==========================================
#  MODULE: MARIMO (Notebooks)
# ==========================================
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
#  MODULE: TMUX
# ==========================================
cat <<CONF > dotfiles/tmux/.tmux.conf
set-option -sa terminal-overrides ",xterm*:Tc"
set -g mouse on
set -g base-index 1
set -g pane-base-index 1
bind -n M-H previous-window
bind -n M-L next-window
CONF

cat <<'EOF' > installs/tmux/install.sh
#!/bin/bash
echo "🟩 [Tmux] Installing..."
sudo pacman -S --needed --noconfirm tmux
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" tmux
EOF

cat <<'EOF' > uninstalls/tmux/uninstall.sh
#!/bin/bash
echo "🟩 [Tmux] Uninstalling..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" tmux
sudo pacman -Rns --noconfirm tmux
EOF

# ==========================================
#  MODULE: HYPRLAND (Keybindings)
# ==========================================
cat <<CONF > dotfiles/hyprland/.config/hypr/user_binds.conf
# --- SUPPLEMENT KEYBINDINGS ---
# Using Omarchy's native webapp launcher (uses Chromium)

# Super + G = Gemini
bind = SUPER, G, exec, omarchy-launch-webapp "https://gemini.google.com"

# Super + M = Gmail
bind = SUPER, M, exec, omarchy-launch-webapp "https://mail.google.com"

# Super + Z = Zed
bind = SUPER, Z, exec, zed
CONF

cat <<'EOF' > installs/hyprland/install.sh
#!/bin/bash
echo "🔗 [Hyprland] Linking Configs..."
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" hyprland

CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$CONF" ] && ! grep -q "user_binds.conf" "$CONF"; then
    echo -e "\n# Load Supplement Overrides\nsource = ~/.config/hypr/user_binds.conf" >> "$CONF"
fi
EOF

cat <<'EOF' > uninstalls/hyprland/uninstall.sh
#!/bin/bash
echo "🔗 [Hyprland] Unlinking..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" hyprland
# Clean up the include line
sed -i '/user_binds.conf/d' "$HOME/.config/hypr/hyprland.conf"
sed -i '/Load Supplement/d' "$HOME/.config/hypr/hyprland.conf"
EOF

# ==========================================
#  MODULE: GHOSTTY
# ==========================================
cat <<CONF > dotfiles/ghostty/.config/ghostty/config
theme = catppuccin-mocha
font-family = "JetBrainsMono Nerd Font"
font-size = 13
CONF

cat <<'EOF' > installs/ghostty/install.sh
#!/bin/bash
echo "👻 [Ghostty] Linking Config..."
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" ghostty
EOF

cat <<'EOF' > uninstalls/ghostty/uninstall.sh
#!/bin/bash
echo "👻 [Ghostty] Unlinking..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" ghostty
EOF

# ==========================================
#  MODULE: NVIM
# ==========================================
cat <<LUA > dotfiles/nvim/.config/nvim/lua/plugins/user-overrides.lua
return { 
  -- Add user plugins here
}
LUA

cat <<'EOF' > installs/nvim/install.sh
#!/bin/bash
echo "📝 [Nvim] Linking Config..."
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" nvim
EOF

cat <<'EOF' > uninstalls/nvim/uninstall.sh
#!/bin/bash
echo "📝 [Nvim] Unlinking..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" nvim
EOF

# ==========================================
#  MASTER INSTALLER
# ==========================================
cat <<'EOF' > install-supplement.sh
#!/bin/bash
export SUPPLEMENT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🚀 Starting Master Install..."

if ! command -v stow &> /dev/null; then sudo pacman -S --needed --noconfirm stow; fi

# Iterate through all 'install.sh' files found in subdirectories
for script in "$SUPPLEMENT_ROOT"/installs/*/install.sh; do
    if [ -f "$script" ]; then
        MODULE=$(basename $(dirname "$script"))
        echo "▶️ Installing: $MODULE"
        bash "$script"
    fi
done
echo "🎉 Complete!"
EOF

# ==========================================
#  MASTER UNINSTALLER
# ==========================================
cat <<'EOF' > uninstall-supplement.sh
#!/bin/bash
export SUPPLEMENT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🗑️ Starting Master Uninstall..."

for script in "$SUPPLEMENT_ROOT"/uninstalls/*/uninstall.sh; do
    if [ -f "$script" ]; then
        MODULE=$(basename $(dirname "$script"))
        echo "▶️ Removing: $MODULE"
        bash "$script"
    fi
done
echo "✅ Complete."
EOF

# FINISH
chmod +x installs/*/*.sh uninstalls/*/*.sh *.sh
echo "✅ Fully Modular Repo Structure Generated!"
