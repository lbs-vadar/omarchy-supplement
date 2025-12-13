#!/bin/bash
echo "❄️ [Nix] Removing..."
sudo pacman -Rns --noconfirm nix direnv
sed -i '/direnv hook zsh/d' "$HOME/.zshrc"
