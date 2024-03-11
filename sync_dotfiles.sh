#!/bin/bash

# Define paths
DOTFILES_DIR=~/dotfiles
HOME_DIR=~

cd "$DOTFILES_DIR"
git pull

# Copy dotfiles
files=(".zshrc" ".zprofile" ".vimrc" ".gvimrc" "sync_dotfiles.sh")
for file in "${files[@]}"; do
    rsync -a "$HOME_DIR/$file" "$DOTFILES_DIR"
done

# Copy vim files
rsync -a "$HOME_DIR/.vim/helpme_files/"* "$DOTFILES_DIR/vim/helpme_files"
rsync -a "$HOME_DIR/.vim/ftplugin/"* "$DOTFILES_DIR/vim/ftplugin"
rsync -a "$HOME_DIR/.vim/lib/"* "$DOTFILES_DIR/vim/lib"

# Copy manim files
rsync -a --exclude="__manim__" "$HOME_DIR/.manim/" "$DOTFILES_DIR/manim"

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
cd "$HOME_DIR"
