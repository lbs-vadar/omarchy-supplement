#!/bin/bash
echo "👻 [Ghostty] Replacing Config..."
mkdir -p "$HOME/.config/ghostty"
# SCORCHED EARTH: Delete existing config
rm -f "$HOME/.config/ghostty/config"
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" ghostty
