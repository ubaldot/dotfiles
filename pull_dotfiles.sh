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

git pull
# Copy dotfiles
# files=("commands.md" ".zshrc" ".zprofile" ".bash_prompt" ".vimrc" ".gvimrc" "pull_dotfiles.sh" "push_dotfiles.sh" "my_css_style.css")
# for file in "${files[@]}"; do
#     # Copy files from ~/dotfiles to ~
#         rsync -av "$DOTFILES_DIR/$file" "$HOME_DIR"
# done

# # Vim
# rsync -a "$DOTFILES_DIR/vim/helpme_files/"* "$DOTVIM_DIR/helpme_files"
# rsync -a "$DOTFILES_DIR/vim/plugins_settings/"* "$DOTVIM_DIR/plugins_settings"
# rsync -a "$DOTFILES_DIR/vim/after/ftplugin/"* "$DOTVIM_DIR/after/ftplugin"
# rsync -a "$DOTFILES_DIR/vim/compiler"* "$DOTVIM_DIR/compiler"
# rsync -a "$DOTFILES_DIR/vim/lib/"* "$DOTVIM_DIR/lib"

# # Manim
# rsync -a "$DOTFILES_DIR/manim/"* "$HOME/.manim"

cd "$HOME_DIR"
