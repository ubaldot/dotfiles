# dotfiles

Repo to keep track of my dot files.

# Usage

- Clone this repo in your home folder.
- Run `python -m create_symlinks` from `~/dotfiles`

To install all Vim plugins you need [minpac][1]. You can install it as it
follows:

### Windows

```cmd
git clone https://github.com/k-takata/minpac.git %USERPROFILE%\vimfiles\pack\minpac\opt\minpac
```

### Linux, macOS

```sh
git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
```

Once done, open Vim and run :`PackUpdate`.

### Add new dotfiles

When you create a new dotfile, manually move it to `~\dotfiles` folder and add
it to the repo. Then, create a symlink from `~` to the moved file.

<!-- DO NOT REMOVE vim-markdown-extras references DO NOT REMOVE-->

[1]: https://github.com/k-takata/minpac
