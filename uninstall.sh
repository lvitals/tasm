#!/bin/sh

# Directories to be removed
TASM_DIR="$HOME/.tasm"

# Remove the binary and tables
echo "Removing files..."
rm -rf "$TASM_DIR"

# Remove the environment variables from the shell configuration files
echo "Removing configuration from shell files..."

for shell_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$shell_file" ]; then
        # Remove TASMTABS and PATH related to .tasm using sed
        sed -i '' '/export TASMTABS="\$HOME\/.tasm\/tables"/d' "$shell_file"
        sed -i '' '/export PATH="\$PATH:\$HOME\/.tasm\/bin"/d' "$shell_file"
        echo "Configuration removed from $shell_file"
    fi
done

# Inform the user that the uninstallation is complete
echo "Uninstallation complete."
