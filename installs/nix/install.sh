#!/bin/bash
# File: installs/nix/install.sh - Nix Flake Template Setup

DOTFILES_CONFIGS="$HOME/supplement/configs"

echo "⚛️ [Nix] Setting up Nix configuration and Flake templates..."

# --- TEMPLATE CLEANUP AND STOW ---
echo "🔗 [Stow] Creating symbolic links for nix templates..."

# Clean up any potential conflicts before stowing
rm -f "$HOME/.config/nix/templates/default/flake.nix"
rm -f "$HOME/.config/nix/templates/default/flake.lock"
rm -rf "$HOME/.config/nix/templates" # Remove directory link

# Ensure the parent target directory exists for stow
mkdir -p "$HOME/.config/nix/templates/default"

if [ -d "$DOTFILES_CONFIGS/nix" ]; then
    stow -d "$DOTFILES_CONFIGS" -t "$HOME" nix
fi

echo "✅ Nix setup complete (Templates linked)."
