#!/bin/bash
# Define the root manually to avoid errors
SUPPLEMENT_ROOT="$HOME/supplement"

echo "📦 [Zsh] Installing packages..."
sudo pacman -S --needed --noconfirm zsh zsh-completions sheldon starship zoxide fzf bat eza stow

echo "🔗 [Zsh] Stowing dotfiles..."
# Clean up potential conflicts first
rm -f "$HOME/.zshrc" "$HOME/.zprofile"
rm -rf "$HOME/.config/sheldon"

# Run stow pointing to the correct folder
if [ -d "$SUPPLEMENT_ROOT/configs" ]; then
    stow -d "$SUPPLEMENT_ROOT/configs" -t "$HOME" zsh
else
    echo "❌ ERROR: Could not find configs at $SUPPLEMENT_ROOT/configs"
    exit 1
fi

echo "🔌 [Zsh] Linking to Bash..."
BASHRC="$HOME/.bashrc"
SWITCH='if [[ $- == *i* && -x $(command -v zsh) ]]; then export SHELL=$(which zsh); exec zsh -l; fi'
grep -q "exec zsh -l" "$BASHRC" || echo "$SWITCH" >> "$BASHRC"

echo "✅ Zsh install complete!"
