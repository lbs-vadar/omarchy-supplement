#!/bin/bash
echo "🟩 [Tmux] Replacing Config..."
sudo pacman -S --needed --noconfirm tmux
rm -f "$HOME/.tmux.conf"
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" tmux
