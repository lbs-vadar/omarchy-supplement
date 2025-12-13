#!/bin/bash
echo "❄️ [Nix] Installing..."
sudo pacman -S --needed --noconfirm nix direnv
sudo systemctl enable --now nix-daemon.service
sudo usermod -aG nix-users $USER
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
# Hook into Zsh
grep -q "direnv hook zsh" "$HOME/.zshrc" || echo 'eval "$(direnv hook zsh)"' >> "$HOME/.zshrc"
