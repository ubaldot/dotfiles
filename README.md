# dotfiles

Repo to keep track of my dot files.

# Usage

- Clone this repo in your home folder.
- Run `python -m create_symlinks` from `~/dotfiles`

The script `create_symlinks.py` create a 1-1 symlink in `~` for every file
contained in `~/dotfiles` folder. The script works for Windows/Linux/Macos.

When you create a new dotfile, manually move it to `~\dotfiles` folder and add
it to the repo. Then, create a symlink from `~` to the moved file.

> NOTE
>
> You must manually download `plug.vim` and all the vim plugins.
