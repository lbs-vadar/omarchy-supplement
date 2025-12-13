#!/bin/bash
echo "📝 [Nvim] Unstowing..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" nvim
