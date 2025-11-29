# dotfiles

Repo to keep track of my dot files.

# Usage

#### Linux, Macos, WSL

- Clone this repo in your home folder.
- Run `python -m create_symlinks` from `~/dotfiles`

#### Windows

1. Clone this repo into WSL `~\dotfiles`,
2. Download the script `create_symlinks.py` in Windows,
3. Run `python -m create_symlinks` from Windows.

##### Notes

- To have common dotfiles between Windows and WSL, and to avoid `^M` mess, we
  create symlinks in Windows that points to the dotfiles stored in WSL,
- By doing that, you can jump back and forth between WSL and Windows without
  the need of updating the dotfiles in each environment,
- However, if you want to push/pull new or modified dotfiles, the easiest is
  to do it through WSL, as the actual dotfiles repo is stored there, or to go
  to `\\wsl.localhost\your-distro\home\your-name\dotfiles` and push from
  there,
- If you exclusively use Windows, you can easily update the
  `create_symlinks.py` script.

# Vim plugins

To install all Vim plugins you need [minpac][1] . You can install it as it
follows:

### Windows

```cmd
git clone https://github.com/k-takata/minpac.git %USERPROFILE%\vimfiles\pack\minpac\opt\minpac
```

### Linux, macOS, WSL

```sh
git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
```

Once done, open Vim and run :`PackUpdate`.

In Windows case, it is reasonable to install plugins in both Windows and WSL.

### Add new dotfiles

When you create a new dotfile, manually move it to `~\dotfiles` repo and start
tracking it.
Then, create a symlink from `~` to the moved file.

<!-- DO NOT REMOVE vim-markdown-extras references DO NOT REMOVE-->

[1]: https://github.com/k-takata/minpac
