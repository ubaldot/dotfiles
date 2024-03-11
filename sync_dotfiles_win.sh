#!/bin/bash
#
# Run from WSL

# Define paths
HOME_DIR=/mnt/c/Users/yt75534/
DOTFILES_DIR="$HOME_DIR/dotfiles"
DOTVIM_DIR ="$HOME_DIR/vimfiles"

cd "$DOTFILES_DIR"
git pull

# Copy dotfiles
files=(".zshrc" ".zprofile" ".vimrc" ".gvimrc" "sync_dotfiles.sh" "sync_dotfiles_win.sh")
for file in "${files[@]}"; do
    # Check if the file exists in $HOME_DIR
    if [ -f "$HOME_DIR/$file" ]; then
        # File exists, use rsync
        rsync -a "$HOME_DIR/$file" "$DOTFILES_DIR"
    else
        # File doesn't exist, use cp
        cp -v "$HOME_DIR/$file" "$DOTFILES_DIR"
        git add "$DOTFILES_DIR/$file"
    fi
done

# Copy vim files
rsync -a "$HOME_DIR/$DOTVIM_DIR/helpme_files/"* "$DOTFILES_DIR/vim/helpme_files"
rsync -a "$HOME_DIR/$DOTVIM_DIR/ftplugin/"* "$DOTFILES_DIR/vim/ftplugin"
rsync -a "$HOME_DIR/$DOTVIM_DIR/lib/"* "$DOTFILES_DIR/vim/lib"

# Copy manim files
rsync -a --exclude="__manim__" "$HOME_DIR/.manim/" "$DOTFILES_DIR/manim"

# Add all changes to Git
git add -u

# Check if there are changes to commit
if git diff-index --quiet HEAD --; then
    echo "No changes to commit. Exiting."
    exit 0
fi

# Commit changes
git commit -m "Update dotfiles: $(date)"

# Push changes to remote repository
git push
cd "$HOME_DIR"
