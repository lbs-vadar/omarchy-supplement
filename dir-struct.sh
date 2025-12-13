#!/bin/bash

# 1. REMOVE OLD ARTIFACTS (Clean Slate)
rm -rf scripts install-zsh.sh uninstall-zsh.sh

# 2. CREATE TYPECRAFT-STYLE DIRECTORY STRUCTURE
mkdir -p dotfiles/zsh/.config/sheldon
mkdir -p installs/zsh
mkdir -p uninstalls/zsh

# 3. CREATE CONFIG FILES (The Data)

# Generate plugins.toml
cat <<TOML > dotfiles/zsh/.config/sheldon/plugins.toml
shell = "zsh"
[plugins.zsh-defer]
github = "romkatv/zsh-defer"
[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"
use = ["{{ name }}.zsh"]
[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"
[plugins.starship]
inline = 'eval "\$(starship init zsh)"'
TOML

# Generate .zshrc (With all Omarchy Aliases)
cat <<RC > dotfiles/zsh/.zshrc
# --- Omarchy Path ---
export PATH="\$HOME/.local/share/omarchy/bin:\$PATH"

# --- Plugin Manager ---
eval "\$(sheldon source)"

# --- Navigation Superpowers ---
eval "\$(zoxide init zsh)"
setopt autocd

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt incappendhistory

# --- Omarchy Aliases ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Eza (modern ls)
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'

# Git
alias g='git'
alias gcad='git commit -a --amend'
alias gcam='git commit -a -m'
alias gcm='git commit -m'

# Tools
alias d='docker'
alias decompress='tar -xzf'
alias r='rails'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# --- Zsh Overrides ---
alias cd='z'
RC

# 4. CREATE INSTALL SCRIPT (The Logic)
cat <<'EOF' > installs/zsh/install.sh
#!/bin/bash
echo "📦 [Zsh] Installing packages..."
sudo pacman -S --needed --noconfirm zsh zsh-completions sheldon starship zoxide fzf bat eza stow

echo "🔗 [Zsh] Stowing dotfiles..."
# Clean up potential conflicts first
[ -f "$HOME/.zshrc" ] && rm "$HOME/.zshrc"
[ -d "$HOME/.config/sheldon" ] && rm -rf "$HOME/.config/sheldon"

# Run stow from the repo root
stow -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" zsh

echo "🔌 [Zsh] Linking to Bash..."
BASHRC="$HOME/.bashrc"
SWITCH='if [[ $- == *i* && -x $(command -v zsh) ]]; then export SHELL=$(which zsh); exec zsh -l; fi'
grep -q "exec zsh -l" "$BASHRC" || echo "$SWITCH" >> "$BASHRC"
EOF

# 5. CREATE UNINSTALL SCRIPT
cat <<'EOF' > uninstalls/zsh/uninstall.sh
#!/bin/bash
echo "🔗 [Zsh] Unstowing dotfiles..."
stow -D -d "$SUPPLEMENT_ROOT/dotfiles" -t "$HOME" zsh 2>/dev/null

echo "🧹 [Zsh] Removing Bash switch..."
sed -i '/exec zsh -l/d' "$HOME/.bashrc"
sed -i '/Omarchy Zsh Layer/,+4d' "$HOME/.bashrc" 2>/dev/null

echo "📦 [Zsh] Removing packages..."
PACKAGES="zsh zsh-completions sheldon zoxide"
TO_REMOVE=""
for pkg in $PACKAGES; do
    if pacman -Qs $pkg > /dev/null; then TO_REMOVE="$TO_REMOVE $pkg"; fi
done

if [ ! -z "$TO_REMOVE" ]; then
    sudo pacman -Rns --noconfirm $TO_REMOVE
fi
EOF

# 6. CREATE MASTER INSTALLER
cat <<'EOF' > install-supplement.sh
#!/bin/bash
export SUPPLEMENT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🚀 Starting Supplement Install..."

# Install Stow if missing
if ! command -v stow &> /dev/null; then
    echo "📦 Installing GNU Stow..."
    sudo pacman -S --needed --noconfirm stow
fi

# Run all installers
for installer in "$SUPPLEMENT_ROOT"/installs/*/install.sh; do
    if [ -f "$installer" ]; then
        echo "▶️ Running $(basename $(dirname "$installer"))..."
        bash "$installer"
    fi
done
echo "🎉 Done!"
EOF

# 7. CREATE MASTER UNINSTALLER
cat <<'EOF' > uninstall-supplement.sh
#!/bin/bash
export SUPPLEMENT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🗑️ Starting Supplement Uninstall..."

for uninstaller in "$SUPPLEMENT_ROOT"/uninstalls/*/uninstall.sh; do
    if [ -f "$uninstaller" ]; then
        echo "▶️ Running $(basename $(dirname "$uninstaller"))..."
        bash "$uninstaller"
    fi
done
echo "✅ Done."
EOF

# 8. FINALIZE
chmod +x installs/zsh/*.sh uninstalls/zsh/*.sh *.sh
echo "✅ Converted to Typecraft/Stow architecture!"
