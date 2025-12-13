#!/bin/bash
echo "📦 [Zed] Installing..."
if command -v yay &> /dev/null; then H="yay"; else H="paru"; fi
$H -S --needed --noconfirm zed-preview-bin
