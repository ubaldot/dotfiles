# dotfiles
Repo to keep track of my dot files.

# Usage
- Clone this repo in any folder (e.g. `~\dotfiles`).
- Create symbolic links. Examples:

```
ln -s /home/ubaldot/dotfiles/.zshrc /home/ubaldot/.zshrc
ln -s /home/ubaldot/dotfiles/vim/after/ftplugin/c.vim
/home/ubaldot/.vim/after/ftplugin/c.vim
```

For Windows, you can use `powershell`:

```
New-Item -ItemType SymbolicLink -Path "C:\Users\ubaldot\.zshrc" -Target "C:\Users\ubaldot\dotfiles\.zshrc"
New-Item -ItemType SymbolicLink -Path "C:\Users\ubaldot\.vim\after\ftplugin\c.vim" -Target "C:\Users\ubaldot\dotfiles\vim\after\ftplugin\c.vim"
```

To automatically push and pull you can use the scripts `push_dotfile.sh` and
`pull_dotfiles.sh`.
