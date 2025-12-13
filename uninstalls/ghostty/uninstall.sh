#!/bin/bash
echo "👻 [Ghostty] Unstowing..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" ghostty
