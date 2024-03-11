#!/bin/bash

cp ~/.zshrc ~/dotfiles
cp ~/.zprofile ~/dotfiles
cp ~/.vimrc ~/dotfiles
cp ~/.gvimrc ~/dotfiles
cp ~/.vim/helpme_files/* ~/dotfiles/vim/helpme_files
cp ~/.vim/ftplugin/* ~/dotfiles/vim/ftplugin
cp ~/.vim/lib/* ~/dotfiles/vim/lib
cp ~/.manim/* ~/dotfiles/manim
cp ~/read_dotfiles.sh ~/dotfiles
cp ~/write_dotfiles.sh ~/dotfiles

cd ~/dotfiles
git add -u
git cim
git push
