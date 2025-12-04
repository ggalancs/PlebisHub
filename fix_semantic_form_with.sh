#!/bin/bash

# Find all .erb files containing semantic_form_with and replace with semantic_form_for
# This script converts form_with syntax to form_for syntax

echo "Finding all files with semantic_form_with..."

# Find all .erb files with semantic_form_with
files=$(grep -r "semantic_form_with" --include="*.erb" . | cut -d: -f1 | sort -u)

echo "Found $(echo "$files" | wc -l) files with semantic_form_with"
echo ""

for file in $files; do
    echo "Processing: $file"

    # Create backup
    cp "$file" "$file.bak"

    # Replace semantic_form_with with semantic_form_for
    # and convert model: to first arg, scope: to as:, and method: inside html:
    sed -i.tmp 's/semantic_form_with model: \([^,]*\), scope: \([^,]*\), url: \([^,]*\), method: :\([^ ]*\)/semantic_form_for \1, as: \2, url: \3, html: { method: :\4 }/g' "$file"
    sed -i.tmp 's/semantic_form_with model: \([^,]*\), scope: \([^,]*\), url: \([^ )]*\)/semantic_form_for \1, as: \2, url: \3/g' "$file"

    # Remove .tmp files
    rm -f "$file.tmp"

    echo "  Fixed!"
done

echo ""
echo "Done! Backup files saved with .bak extension"
echo ""
echo "To restore backups if needed:"
echo "  find . -name '*.bak' -exec bash -c 'mv \"\$0\" \"\${0%.bak}\"' {} \;"
