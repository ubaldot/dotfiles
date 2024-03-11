#!/bin/bash

# Define paths
HOME_DIR=~

cd "$HOME_DIR"
git clone git@github.com:ubaldot/dotfiles.git

./dotfiles/pull_dotfiles.sh
