# dotfiles
Repo to keep track of my configs files.

# Usage
Download the `clone_*` scripts with the following commands:

```
curl -o /tmp/clone_dotfiles.sh https://raw.githubusercontent.com/ubaldot/dotfiles/main/clone_dotfiles.sh
```

```
# For windows
curl -o /tmp/clone_dotfiles_win.sh https://raw.githubusercontent.com/ubaldot/dotfiles/main/clone_dotfiles_win.sh
```

and run `/tmp/clone_dotfiles.sh` (or `/tmp/clone_dotfiles_win.sh` if you plan to use Windows). 

**If you are using Windows you must use WSL and your C: drive must be mounted in /mnt/c.**

The scripts will clone this repo and copy the various files in the correct
place. 

Once done you can use the `sync_*` scripts to keep your files updated. 

