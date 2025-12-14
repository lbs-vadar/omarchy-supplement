#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration Variables ---
FONT_PACKAGE="otf-monaspace-nerdfonts"
FONT_NAME="Monaspace Neon Nerd Font" # Change this to Krypton, Xenon, etc., if preferred

GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
GTK_CONFIG_FILE="$HOME/.config/gtk-3.0/settings.ini"

echo "### Starting Monaspace Nerd Font Installation ###"
echo "Targeting font: $FONT_NAME"

# ==================================
# Step 1: Install Fonts (Requires sudo)
# ==================================
echo "--- 1. Installing $FONT_PACKAGE via pacman ---"

# Use sudo to run the installation
if ! sudo pacman -S --noconfirm "$FONT_PACKAGE"; then
    echo "ERROR: Failed to install $FONT_PACKAGE." >&2
    echo "Please ensure pacman repositories are configured correctly and try again." >&2
    exit 1
fi
echo "Package installed successfully (cache updated automatically)."


# ==================================
# Step 2: Configure Ghostty Terminal
# ==================================
echo "--- 2. Configuring Ghostty ($GHOSTTY_CONFIG) ---"

mkdir -p "$(dirname "$GHOSTTY_CONFIG")" # Ensure the directory exists

# Logic to find and replace the font-family line, or add it if it doesn't exist
if grep -q '^font-family =' "$GHOSTTY_CONFIG"; then
    # Line exists, replace it
    sed -i 's/^font-family = .*/font-family = "'"$FONT_NAME"'"/' "$GHOSTTY_CONFIG"
    echo "Updated 'font-family' in Ghostty config."
else
    # Line does not exist, append it
    echo "font-family = \"$FONT_NAME\"" >> "$GHOSTTY_CONFIG"
    echo "Added 'font-family' to Ghostty config."
fi


# ==================================
# Step 3: Configure GTK/System Font (Replicating nwg-look)
# ==================================
echo "--- 3. Configuring GTK Monospace Font (Replicating nwg-look) ---"

mkdir -p "$(dirname "$GTK_CONFIG_FILE")" # Ensure the directory exists

# Use sed to set the GTK monospace font in settings.ini (GTK3 standard)
# This handles the font setting for many applications like Firefox, GTK apps, etc.
LINE="gtk-monospace-font-name=$FONT_NAME 10" # Example font size 10

# Check if the line exists
if grep -q '^gtk-monospace-font-name=' "$GTK_CONFIG_FILE"; then
    # Line exists, replace it
    sed -i "s/^gtk-monospace-font-name=.*/$LINE/" "$GTK_CONFIG_FILE"
    echo "Updated 'gtk-monospace-font-name' in GTK settings."
else
    # Line does not exist, append it to the [Settings] block or the end of the file
    if grep -q '\[Settings\]' "$GTK_CONFIG_FILE"; then
        # Insert after [Settings]
        sed -i "/^\[Settings\]/a $LINE" "$GTK_CONFIG_FILE"
    else
        # Add [Settings] block and the line
        echo -e "\n[Settings]\n$LINE" >> "$GTK_CONFIG_FILE"
    fi
    echo "Added 'gtk-monospace-font-name' to GTK settings."
fi

# ==================================
# Final Steps
# ==================================
echo "### Installation Complete! ###"
echo "You may need to restart Ghostty (Ctrl+Shift+, by default) or log out and back in for all system changes to take effect."
