#!/bin/bash

cd ~/dotfiles
git pull
cp ./.zshrc ~
cp ./.zprofile ~
cp ./.vimrc ~
cp ./.gvimrc ~
cp ./vim/helpme_files/* ~/.vim/helpme_files
cp ./vim/ftplugin/* ~/.vim/ftplugin
cp ./vim/lib/* ~/.vim/lib
cp ./manim/* ~/.manim
cp ./read_dotfiles.sh ~
cp ./write_dotfiles.sh ~
