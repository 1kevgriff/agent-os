#!/bin/bash

# Agent OS Cursor Setup Script
# This script installs Agent OS commands for Cursor in the current project

set -e  # Exit on error

# Detect Windows environment and recommend PowerShell version
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || -n "$WINDIR" ]]; then
    echo "🪟 Windows detected!"
    echo ""
    echo "For the best Windows experience, we recommend using the PowerShell version:"
    echo "  .\setup-cursor.ps1"
    echo ""
    echo "You can also continue with this bash script if preferred."
    echo ""
    read -p "Continue with bash script? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Please run: .\setup-cursor.ps1"
        exit 0
    fi
    echo ""
fi

echo "🚀 Agent OS Cursor Setup"
echo "========================"
echo ""

# Check if Agent OS base installation is present
if [ ! -d "$HOME/.agent-os/instructions" ] || [ ! -d "$HOME/.agent-os/standards" ]; then
    echo "⚠️  Agent OS base installation not found!"
    echo ""
    echo "Please install the Agent OS base installation first:"
    echo ""
    echo "Option 1 - Automatic installation:"
    echo "  curl -sSL https://raw.githubusercontent.com/instrumental-products/agent-os/main/setup.sh | bash"
    echo ""
    echo "Option 2 - Manual installation:"
    echo "  Follow instructions at https://buildermethods.com/agent-os"
    echo ""
    exit 1
fi

echo ""
echo "📁 Creating .cursor/rules directory..."
mkdir -p .cursor/rules

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/instrumental-products/agent-os/main"

echo ""
echo "📥 Downloading and setting up Cursor command files..."

# Function to process a command file
process_command_file() {
    local cmd="$1"
    local temp_file="/tmp/${cmd}.md"
    local target_file=".cursor/rules/${cmd}.mdc"

    # Download the file
    if curl -s -o "$temp_file" "${BASE_URL}/commands/${cmd}.md"; then
        # Create the front-matter and append original content
        cat > "$target_file" << EOF
---
alwaysApply: false
---

EOF

        # Append the original content
        cat "$temp_file" >> "$target_file"

        # Clean up temp file
        rm "$temp_file"

        echo "  ✓ .cursor/rules/${cmd}.mdc"
    else
        echo "  ❌ Failed to download ${cmd}.md"
        return 1
    fi
}

# Process each command file
for cmd in plan-product create-spec execute-tasks analyze-product; do
    process_command_file "$cmd"
done

echo ""
echo "✅ Agent OS Cursor setup complete!"
echo ""
echo "📍 Files installed to:"
echo "   .cursor/rules/             - Cursor command rules"
echo ""
echo "Next steps:"
echo ""
echo "Use Agent OS commands in Cursor with @ prefix:"
echo "  @plan-product    - Initiate Agent OS in a new product's codebase"
echo "  @analyze-product - Initiate Agent OS in an existing product's codebase"
echo "  @create-spec     - Initiate a new feature (or simply ask 'what's next?')"
echo "  @execute-tasks    - Build and ship code"
echo ""
echo "Learn more at https://buildermethods.com/agent-os"
echo ""
