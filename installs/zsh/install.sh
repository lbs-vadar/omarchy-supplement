#!/bin/bash
# File: installs/zsh/install.sh

# Define the root manually to avoid errors
SUPPLEMENT_ROOT="$HOME/supplement"
DOTFILES_CONFIGS="$SUPPLEMENT_ROOT/configs"

echo "📦 [Zsh] Installing core packages (Zsh, Tools, Managers)..."
# Added direnv and removed zsh-completions (often redundant if compinit is run)
sudo pacman -S --needed --noconfirm zsh sheldon starship zoxide fzf bat eza stow ripgrep direnv

# --- CONFLICT RESOLUTION ---
echo "🔗 [Zsh] Cleaning up potential conflicts..."
# Use a more explicit cleanup for safety before stowing
rm -f "$HOME/.zshrc" "$HOME/.bashrc" # Only remove the file that will be linked
rm -rf "$HOME/.config/sheldon" # Remove directory that will be linked
rm -f "$HOME/.config/starship.toml" # Remove static config that will be linked

# --- STOW OPERATIONS ---
echo "🔗 [Zsh] Stowing Zsh and Starship dotfiles..."

if [ -d "$DOTFILES_CONFIGS" ]; then
    # 1. Stow the main Zsh configuration (.zshrc, .config/sheldon)
    stow -d "$DOTFILES_CONFIGS" -t "$HOME" zsh

    # 2. Stow the Starship configuration (.config/starship.toml)
    stow -d "$DOTFILES_CONFIGS" -t "$HOME" starship

    # 3. Stow the NIX TEMPLATE (Links to ~/.config/nix/templates/default)
    stow -d "$DOTFILES_CONFIGS" -t "$HOME" nix  # <--- ADD THIS LINE

    # 4. Stow Direnv configuration (if you have one, e.g., in configs/direnv)
    # stow -d "$DOTFILES_CONFIGS" -t "$HOME" direnv 

else
    echo "❌ ERROR: Could not find configs at $DOTFILES_CONFIGS"
    exit 1
fi

# --- PLUGIN & INIT OPERATIONS ---
echo "🔌 [Zsh] Installing Zsh plugins via Sheldon (Creates the lock file)..."
# This downloads and caches the actual plugins defined in plugins.toml
sheldon lock

# --- SHELL SWITCH ---
echo "⚙️ [Zsh] Setting Zsh as the default shell..."
# Standard, reliable method
chsh -s "$(which zsh)"

echo "✅ Zsh installation complete!"
echo "NOTE: You must now log out and log back in, or reboot, for Zsh to become active."
