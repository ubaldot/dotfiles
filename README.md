# dotfiles
Repo to keep track of my configs files.

# Usage
Download the `clone_*` scripts with the following commands:

```
# https
curl -o /tmp/clone_dotfiles_https.sh https://raw.githubusercontent.com/ubaldot/dotfiles/main/clone_dotfiles_https.sh
```

```
# ssh
curl -o /tmp/clone_dotfiles_ssh.sh https://raw.githubusercontent.com/ubaldot/dotfiles/main/clone_dotfiles_ssh.sh
```

```
# For windows
curl -o /tmp/clone_dotfiles_win.sh https://raw.githubusercontent.com/ubaldot/dotfiles/main/clone_dotfiles_win.sh
```

and run `/tmp/clone_dotfiles_ssh.sh` (or `/tmp/clone_dotfiles_https.sh`).

**If you are using Windows you must use WSL and your C: drive must be mounted in /mnt/c.**

The scripts will clone this repo and copy the various files in the correct
place.

Once done you can use the `push_/pull_` scripts to keep your files updated.
