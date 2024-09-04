#!/bin/bash

# Define paths
if [ "$1" = "win" ]; then
    HOME_DIR=/mnt/c/Users/yt75534
    DOTVIM_DIR="$HOME_DIR/vimfiles"
else
    HOME_DIR=~
    DOTVIM_DIR="$HOME_DIR/.vim"
fi

DOTFILES_DIR="$HOME_DIR/dotfiles"

cd "$DOTFILES_DIR"

# Copy dotfiles
files=(".zshrc" ".zprofile" ".bash_prompt" ".vimrc" ".gvimrc" "pull_dotfiles.sh" "push_dotfiles.sh" "my_css_style.css")
for file in "${files[@]}"; do
    # Copy files from ~ to ~/dotfiles
        rsync -av  "$HOME_DIR/$file" "$DOTFILES_DIR"
done

# Vim
rsync -a "$DOTVIM_DIR/helpme_files/"* "$DOTFILES_DIR/vim/helpme_files"
rsync -a "$DOTVIM_DIR/plugins_settings/"* "$DOTFILES_DIR/vim/plugins_settings"
rsync -a "$DOTVIM_DIR/after/ftplugin/"* "$DOTFILES_DIR/vim/after/ftplugin"
rsync -a "$DOTVIM_DIR/compiler"* "$DOTFILES_DIR/vim/compiler"
rsync -a "$DOTVIM_DIR/lib/"* "$DOTFILES_DIR/vim/lib"

# Manim
rsync -a --exclude="__pycache__" "$HOME/.manim" "$DOTFILES_DIR/manim"

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
