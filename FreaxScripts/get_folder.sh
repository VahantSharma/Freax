#!/bin/bash

# Get the directory where the script is located (the cloned repo location)
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create an environment variable to store the repo's path
echo "Setting up environment variable FOCUS_REPO_DIR to $REPO_DIR"

# Add the environment variable to the appropriate shell configuration file (.bashrc or .zshrc)
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    echo "Unsupported shell. Please use bash or zsh."
    exit 1
fi

# Add the export command to the shell configuration file
echo "export FOCUS_REPO_DIR=\"$REPO_DIR\"" >> "$SHELL_CONFIG"

# Check if the export command was added successfully
if [ $? -ne 0 ]; then
    echo "Failed to write to $SHELL_CONFIG."
    exit 1
fi

# Add aliases to the shell configuration file
echo "Adding aliases to $SHELL_CONFIG..."

{
    echo "# Aliases for focus.sh using FOCUS_REPO_DIR"
    echo "alias focuson='\$FOCUS_REPO_DIR/focus.sh start'"
    echo "alias focusoff='\$FOCUS_REPO_DIR/focus.sh stop'"
    echo "alias focuspause='\$FOCUS_REPO_DIR/focus.sh pause'"
    echo "alias focusresume='\$FOCUS_REPO_DIR/focus.sh resume'"
    echo "alias focusreset='\$FOCUS_REPO_DIR/focus.sh reset'"
    echo "alias focusweeklyreset='\$FOCUS_REPO_DIR/focus.sh reset_weekly'"
    echo "alias daily_summary='\$FOCUS_REPO_DIR/focus.sh daily_summary'"
    echo "alias weekly_summary='\$FOCUS_REPO_DIR/focus.sh weekly_summary'"
    echo "alias focusfilereset='\$FOCUS_REPO_DIR/focus.sh reset_log'"
} >> "$SHELL_CONFIG"

# Check if the aliases were added successfully
if [ $? -ne 0 ]; then
    echo "Failed to add aliases to $SHELL_CONFIG."
    exit 1
fi

# Inform the user
echo "Environment variable FOCUS_REPO_DIR and aliases have been added to $SHELL_CONFIG."
echo "Please run 'source $SHELL_CONFIG' to apply the changes immediately."

echo "Setup complete! FOCUS_REPO_DIR and the aliases are now available for use."

