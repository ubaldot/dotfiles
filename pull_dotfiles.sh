#!/bin/bash

# Define paths
HOME_DIR=~
DOTFILES_DIR="$HOME_DIR/dotfiles"
DOTVIM_DIR="$HOME_DIR/.vim"

cd "$DOTFILES_DIR"
git pull

# Copy dotfiles
files=(".zshrc" ".zprofile" ".vimrc" ".gvimrc" "pull_dotfiles.sh" "push_dotfiles.sh")
for file in "${files[@]}"; do
    # Copy files from ~/dotfiles to ~
        rsync -av "$DOTFILES_DIR/$file" "$HOME_DIR"
done

# Vim
rsync -a "$DOTFILES_DIR/vim/helpme_files/"* "$DOTVIM_DIR/helpme_files"
rsync -a "$DOTFILES_DIR/vim/ftplugin/"* "$DOTVIM_DIR/ftplugin"
rsync -a "$DOTFILES_DIR/vim/lib/"* "$DOTVIM_DIR/lib"

# Manim
rsync -a "$DOTFILES_DIR/manim/"* "$HOME/.manim"

cd "$HOME_DIR"
