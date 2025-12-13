#!/bin/bash
echo "📦 [Zsh] Installing packages..."
sudo pacman -S --needed --noconfirm zsh zsh-completions sheldon starship zoxide fzf bat eza stow

echo "🔗 [Zsh] Stowing dotfiles..."
# Clean up potential conflicts first
[ -f "$HOME/.zshrc" ] && rm "$HOME/.zshrc"
[ -d "$HOME/.config/sheldon" ] && rm -rf "$HOME/.config/sheldon"

# Run stow from the repo root
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" zsh

echo "🔌 [Zsh] Linking to Bash..."
BASHRC="$HOME/.bashrc"
SWITCH='if [[ $- == *i* && -x $(command -v zsh) ]]; then export SHELL=$(which zsh); exec zsh -l; fi'
grep -q "exec zsh -l" "$BASHRC" || echo "$SWITCH" >> "$BASHRC"
