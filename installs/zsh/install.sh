#!/bin/bash
# File: installs/zsh/install.sh - Zsh Shell and Core Tools

DOTFILES_CONFIGS="$HOME/supplement/configs"

echo "📦 [Zsh] Installing Zsh, Core Tools, and direnv..."
# Install Zsh, essential shell utilities (including direnv for flake handling)
sudo pacman -S --needed --noconfirm zsh sheldon zoxide fzf bat eza stow ripgrep direnv neovim

echo "🔗 [Stow] Creating symbolic links for zsh configuration..."
rm -f "$HOME/.zshrc" "$HOME/.bashrc"
rm -rf "$HOME/.config/sheldon"

if [ -d "$DOTFILES_CONFIGS/zsh" ]; then
    stow -d "$DOTFILES_CONFIGS" -t "$HOME" zsh
fi

echo "🔌 [Sheldon] Installing Zsh plugins..."
sheldon lock

echo "✅ Zsh and Core Tools setup complete."
