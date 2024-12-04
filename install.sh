#!/bin/sh

# Check if the ~/.tasm directory exists, if not, create it
TASM_DIR="$HOME/.tasm"
BIN_DIR="$HOME/.tasm/bin"
TABLES_DIR="$HOME/.tasm/tables"

# Create the directories if they don't exist
echo "Checking directories..."

for dir in "$TASM_DIR" "$BIN_DIR" "$TABLES_DIR"; do
    if [ ! -d "$dir" ]; then
        echo "Creating directory $dir..."
        mkdir -p "$dir"
    fi
done

# Copy the binary and table files
echo "Copying files..."

# Copy the binary to $HOME/.tasm/bin/
cp "$PWD/tasm" "$BIN_DIR/tasm"

# Copy the tables to $HOME/.tasm/tables/
cp -r "$PWD/tables"/* "$TABLES_DIR/"

# Update shell configuration files
echo "Updating shell configuration files..."

for shell_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$shell_file" ]; then
        if ! grep -q "export TASMTABS=\"\$HOME/.tasm/tables\"" "$shell_file"; then
            echo "\nexport TASMTABS=\"\$HOME/.tasm/tables\"" >> "$shell_file"
            echo "export PATH=\"\$PATH:\$HOME/.tasm/bin\"" >> "$shell_file"
            echo "Configuration saved to $shell_file"
        fi
    fi
done

# Source the shell configuration files to apply changes
echo "Applying changes to the current shell session..."
export PATH="$PATH:$HOME/.tasm/bin"
export TASMTABS="$HOME/.tasm/tables"

# Inform the user that the installation is complete
echo "Installation complete."
