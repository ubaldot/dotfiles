#!/bin/bash

# Define paths
HOME_DIR=~
DOTFILES_DIR="$HOME_DIR/dotfiles"
DOTVIM_DIR="$HOME_DIR/.vim"

cd "$HOME_DIR"
git clone https://github.com/ubaldot/dotfiles.git

# Copy dotfiles
files=(".zshrc" ".zprofile" ".vimrc" ".gvimrc" "sync_dotfiles.sh" "clone_dotfiles.sh")
for file in "${files[@]}"; do
    # Copy files from ~/dotfiles to ~
        cp -v "$DOTFILES_DIR/$file" "$HOME_DIR"
    fi
done

# Vim
cp -r "$HOME_DIR/$DOTFILES_DIR/vim/helpme_files/"* "$DOTVIM_DIR/helpme_files"
cp -r "$HOME_DIR/$DOTFILES_DIR/vim/ftplugin/"* "$DOTVIM_DIR/ftplugin"
cp -r "$HOME_DIR/$DOTFILES_DIR/vim/lib/"* "$DOTVIM_DIR/lib"

# Manim
cp -r "$HOME_DIR/$DOTFILES_DIR/manim/"* "$HOME/.manim"
