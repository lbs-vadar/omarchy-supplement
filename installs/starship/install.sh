#!/bin/bash
# File: installs/starship/install.sh - Starship Prompt

DOTFILES_CONFIGS="$HOME/supplement/configs"

echo "🚀 [Starship] Installing Starship Prompt..."
sudo pacman -S --needed --noconfirm starship

echo "🔗 [Stow] Creating symbolic links for starship..."
rm -f "$HOME/.config/starship.toml"

if [ -d "$DOTFILES_CONFIGS/starship" ]; then
    stow -d "$DOTFILES_CONFIGS" -t "$HOME" starship
fi

echo "✅ Starship setup complete."
