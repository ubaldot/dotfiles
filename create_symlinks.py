#!/usr/bin/env python3
"""
It reads the content of 'home_dir/dotfiles' and create symlinks in
'~/dotfiles'.
In Windows, the source is always on WSL

Run this script directly from home_dir/dotfiles.
"""

import subprocess
import platform
from pathlib import Path, PureWindowsPath


def is_wsl():
    return "WSL" in platform.release()


def create_symlink(source, target):
    """Create a symbolic link at target pointing to source."""
    if platform.system() == "Windows":
        subprocess.run(
            ["cmd", "/c", "mklink", str(target), str(source)], shell=True
        )
    else:
        subprocess.run(["ln", "-s", str(source), str(target)])


def link_dotfiles(source_dir, target_dir):
    """Recursively create symbolic links for all files in source_dir."""
    source_path = Path(source_dir)
    target_path = Path(target_dir)

    print("source_path: ", source_path)
    print("target_path: ", target_path)

    for source_file in source_path.rglob("*"):
        # Calculate the relative path from the source directory
        rel_path = source_file.relative_to(source_path)

        # Skip any directories or files within the .git or .vim directories
        if ".git" in rel_path.parts:
            continue

        # Create the corresponding target path
        # Replace .vim with vimfiles if on Windows or WSL
        if platform.system() == "Windows" and rel_path.parts[0] == ".vim":
            rel_path = Path("vimfiles").joinpath(*rel_path.parts[1:])

        target_file = target_path / rel_path

        print("source_file: ", source_file)
        print("target_file: ", target_file)

        if source_file.is_dir():
            target_file.mkdir(parents=True, exist_ok=True)
        else:
            create_symlink(source_file, target_file)


# Define the source and target directories for dotfiles
# To avoid ^M mess on WSL and macos, original dotfiles are stored in Ubuntu. Windows just symlink to Ubuntu.
source_dir = (
    Path("//wsl.localhost/Ubuntu-22.04.2-PEES-0.0.7/home/yt75534/dotfiles")
    if platform.system() == "Windows"
    else Path.home() / "dotfiles"
)
target_dir = Path.home()

# Create symbolic links for all files in the dotfiles directory
link_dotfiles(source_dir, target_dir)
