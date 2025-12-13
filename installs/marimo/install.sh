#!/bin/bash
echo "📦 [Marimo] Installing..."
if ! command -v pipx &> /dev/null; then sudo pacman -S --needed --noconfirm python-pipx; fi
pipx install marimo
