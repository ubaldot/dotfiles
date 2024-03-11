#!/bin/bash

# Define paths
DOTFILES_DIR=~/dotfiles
HOME_DIR=~

# Change directory to dotfiles
cd "$DOTFILES_DIR" || exit

# Pull changes from Git
if git pull; then
    # Copy dotfiles
    files=(.zshrc .zprofile .vimrc .gvimrc)
    for file in "${files[@]}"; do
        cp -v "$file" "$HOME_DIR"
    done

    # Copy vim files
    cp -v ./vim/helpme_files/* ~/.vim/helpme_files
    cp -v ./vim/ftplugin/* ~/.vim/ftplugin
    cp -v ./vim/lib/* ~/.vim/lib

    # Copy manim files
    cp -v ./manim/* ~/.manim

    # Copy script files
    cp -v ./read_dotfiles.sh ./write_dotfiles.sh "$HOME_DIR"
else
    echo "Failed to pull changes from Git. Exiting."
    exit 1
fi
