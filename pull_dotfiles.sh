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
    # Copy files from ~/dotfiles to ~
        cp -v "$DOTFILES_DIR/$file" "$HOME_DIR"
done

# Vim
cp -r "$DOTFILES_DIR/vim/helpme_files/"* "$DOTVIM_DIR/helpme_files"
cp -r "$DOTFILES_DIR/vim/ftplugin/"* "$DOTVIM_DIR/ftplugin"
cp -r "$DOTFILES_DIR/vim/lib/"* "$DOTVIM_DIR/lib"

# Manim
cp -r "$DOTFILES_DIR/manim/"* "$HOME/.manim"

cd "$HOME_DIR"
