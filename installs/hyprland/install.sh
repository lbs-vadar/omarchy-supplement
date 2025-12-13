#!/bin/bash
echo "🔗 [Hyprland] Stowing Additive Configs..."
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" hyprland

# ADDITIVE LOGIC:
# We check if the main file imports our files. If not, we append the import.
CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$CONF" ]; then
    grep -q "user_settings.conf" "$CONF" || echo "source = ~/.config/hypr/user_settings.conf" >> "$CONF"
    grep -q "user_binds.conf" "$CONF" || echo "source = ~/.config/hypr/user_binds.conf" >> "$CONF"
fi
