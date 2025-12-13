#!/bin/bash
echo "🟩 [Tmux] Removing..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" tmux
sudo pacman -Rns --noconfirm tmux
