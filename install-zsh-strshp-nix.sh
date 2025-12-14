#!/bin/bash
# File: ~/supplement/install.sh - Master Provisioning Script

echo "Starting Modular Dotfiles Provisioning (Zsh, Starship, Nix)..."

# Exit on any error
set -e

# --- 1. Run Core Dependencies and Linking ---
# Order matters: Dependencies must be installed before their config is linked.
bash installs/starship/install.sh
bash installs/zsh/install.sh
bash installs/nix/install.sh

# --- 2. Final System Configuration ---

echo "⚙️ [System] Setting Zsh as the default shell..."
chsh -s "$(which zsh)"

echo "✅ ALL Installation Modules Complete! 🚀"
echo "---"
echo "Next Steps: 1. Log out and back in. 2. Start a new project with 'nix flake init'."
