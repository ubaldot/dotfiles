#!/bin/bash

# Define paths
DOTFILES_DIR=~/dotfiles
HOME_DIR=~

# Copy dotfiles
files=(".zshrc" ".zprofile" ".vimrc" ".gvimrc")
for file in "${files[@]}"; do
    cp -v "$HOME_DIR/$file" "$DOTFILES_DIR"
done

# Copy vim files
cp -rv "$HOME_DIR/.vim/helpme_files/"* "$DOTFILES_DIR/vim/helpme_files"
cp -rv "$HOME_DIR/.vim/ftplugin/"* "$DOTFILES_DIR/vim/ftplugin"
cp -rv "$HOME_DIR/.vim/lib/"* "$DOTFILES_DIR/vim/lib"

# Copy manim files
cp -rv "$HOME_DIR/.manim/"* "$DOTFILES_DIR/manim"

# Copy script files
cp -v "$HOME_DIR/read_dotfiles.sh" "$HOME_DIR/write_dotfiles.sh" "$DOTFILES_DIR"

# Change directory to dotfiles
cd "$DOTFILES_DIR" || exit

# Add all changes to Git
git add -u

# Check if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo "No changes to commit. Exiting."
    exit 0
fi

# Commit changes
git commit -m "Update dotfiles: $(date)"

# Push changes to remote repository
git push
