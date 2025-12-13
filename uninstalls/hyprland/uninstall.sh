#!/bin/bash
echo "🔗 [Hyprland] Cleaning up..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" hyprland
# Remove the import lines
sed -i '/user_settings.conf/d' "$HOME/.config/hypr/hyprland.conf"
sed -i '/user_binds.conf/d' "$HOME/.config/hypr/hyprland.conf"
