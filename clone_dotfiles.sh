#!/bin/bash

# Define paths
HOME_DIR=~
DOTFILES_DIR="$HOME_DIR/dotfiles"
DOTVIM_DIR="$HOME_DIR/.vim"

cd "$HOME_DIR"
git clone https://github.com/ubaldot/dotfiles.git

./pull_dotfiles.sh
