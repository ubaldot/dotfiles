#!/bin/bash

# Define paths
if [ "$1" = "win" ];
    HOME_DIR=/mnt/c/Users/yt75534
    DOTVIM_DIR="$HOME_DIR/vimfiles"
else
    HOME_DIR=~
    DOTVIM_DIR="$HOME_DIR/.vim"
fi

DOTFILES_DIR="$HOME_DIR/dotfiles"

cd "$DOTFILES_DIR"
git pull

# Copy dotfiles
files=(".zshrc" ".zprofile" ".vimrc" ".gvimrc" "pull_dotfiles.sh" "push_dotfiles.sh")
for file in "${files[@]}"; do
    # Copy files from ~ to ~/dotfiles
        cp -v  "$HOME_DIR/$file" "$DOTFILES_DIR"
done

# Vim
cp -r "$DOTVIM_DIR/helpme_files/"* "$DOTFILES_DIR/vim/helpme_files"
cp -r "$DOTVIM_DIR/ftplugin/"* "$DOTFILES_DIR/vim/ftplugin"
cp -r "$DOTVIM_DIR/lib/"* "$DOTFILES_DIR/vim/lib"

# Manim
cp -r "$HOME/.manim/"* "$DOTFILES_DIR/manim"
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
