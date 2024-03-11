# dotfiles
Repo to keep track of my configs files. The process could be optimized but so
far so good (it is still better than manually copy and paste).

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

and run `/tmp/clone_dotfiles_ssh.sh` (or `/tmp/clone_dotfiles_https.sh`).
The scripts will clone this repo and copy the various files in the correct
place.

Once done you can use the `push_/pull_` scripts to keep your files updated.

Note that you need to `chmod u+x /tmp/clone_dotfiles*` and you may need to `dos2unix
/tmp/clone_dotfiles*` to run the script.

# Windows

If you plan to use Windows natively (i.e. no WSL), then you must still use WSL for running the `clone_dotfiles_*.sh` script
and you must pass the argument `win`, e.g. `/tmp/clone_dotfiles_https.sh win` and your C: drive must be mounted in `/mnt/c`.
The same for the `push_/pull_` scripts, you shall use e.g. `pull_dotfiles.sh
win`.
