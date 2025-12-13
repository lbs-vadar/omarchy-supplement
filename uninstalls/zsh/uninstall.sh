#!/bin/bash
echo "🐚 [Zsh] Removing..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" zsh 2>/dev/null
sed -i '/exec zsh -l/d' "$HOME/.bashrc"
sudo pacman -Rns --noconfirm zsh zsh-completions sheldon zoxide
