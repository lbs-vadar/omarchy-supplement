#!/bin/bash
echo "📝 [Nvim] replacing Config..."
# SCORCHED EARTH: Delete Omarchy's Nvim config entirely
rm -rf "$HOME/.config/nvim"
rm -rf "$HOME/.local/share/nvim"

# Link ours
mkdir -p "$HOME/.config"
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" nvim
