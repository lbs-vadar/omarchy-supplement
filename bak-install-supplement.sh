#!/bin/bash
export SUPPLEMENT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🚀 Starting Master Install..."
# Stow first
[ -f "$SUPPLEMENT_ROOT/installs/stow/install.sh" ] && bash "$SUPPLEMENT_ROOT/installs/stow/install.sh"

for script in "$SUPPLEMENT_ROOT"/installs/*/install.sh; do
    MODULE=$(basename $(dirname "$script"))
    if [ "$MODULE" != "stow" ]; then
        echo "▶️ Installing: $MODULE"
        bash "$script"
    fi
done
echo "🎉 Complete!"
