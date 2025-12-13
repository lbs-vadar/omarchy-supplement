#!/bin/bash
export SUPPLEMENT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🗑️ Starting Master Uninstall..."
for script in "$SUPPLEMENT_ROOT"/uninstalls/*/uninstall.sh; do
    MODULE=$(basename $(dirname "$script"))
    echo "▶️ Removing: $MODULE"
    bash "$script"
done
echo "✅ Complete."
