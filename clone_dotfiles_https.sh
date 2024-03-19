#!/bin/bash

# Define paths

if [ "$1" = "win" ]; then
    HOME_DIR=/mnt/c/Users/yt75534
else
    HOME_DIR=~
fi

cd "$HOME_DIR"
git clone https://github.com/ubaldot/dotfiles.git

./dotfiles/pull_dotfiles.sh "$1"
