#!/usr/bin/env python3
"""
It reads the content of 'home_dir/dotfiles' and create symlinks in
'~/dotfiles'.
In Windows, the source is always on WSL

Run this script directly from home_dir/dotfiles.

The script is idempotent: re-run it at any time to create links for newly
added dotfiles without disturbing the ones that are already correct.
"""

import os
import subprocess
import platform
from pathlib import Path, PureWindowsPath

# Never link these; they are not configuration.
SKIP_DIRS = {".git", "__pycache__"}
SKIP_NAMES = {".DS_Store"}


def is_wsl():
    return "WSL" in platform.release()


def create_symlink(source, target):
    """Create a symbolic link at target pointing to source.

    Existing correct links are left alone, wrong or dangling links are
    replaced, and real files are never overwritten.
    """
    target = Path(target)

    if target.is_symlink():
        try:
            if Path(os.readlink(str(target))) == Path(source):
                return "ok"
        except OSError:
            pass
        target.unlink()
    elif target.exists():
        print(f"  SKIP (real file in the way): {target}")
        return "blocked"

    if platform.system() == "Windows":
        subprocess.run(
            ["cmd", "/c", "mklink", str(target), str(source)], shell=True
        )
    else:
        subprocess.run(["ln", "-s", str(source), str(target)])
    return "created"


def link_dotfiles(source_dir, target_dir):
    """Recursively create symbolic links for all files in source_dir."""
    source_path = Path(source_dir)
    target_path = Path(target_dir)

    print("source_path: ", source_path)
    print("target_path: ", target_path)

    created = existing = blocked = 0

    for source_file in source_path.rglob("*"):
        rel_path = source_file.relative_to(source_path)

        if SKIP_DIRS.intersection(rel_path.parts):
            continue
        if source_file.name in SKIP_NAMES:
            continue

        # Replace .vim with vimfiles if on Windows
        if platform.system() == "Windows" and rel_path.parts[0] == ".vim":
            rel_path = Path("vimfiles").joinpath(*rel_path.parts[1:])

        target_file = target_path / rel_path

        if source_file.is_dir():
            target_file.mkdir(parents=True, exist_ok=True)
            continue

        # A new file may live in a directory that does not exist yet.
        target_file.parent.mkdir(parents=True, exist_ok=True)

        result = create_symlink(source_file, target_file)
        if result == "created":
            print(f"  linked: {target_file}")
            created += 1
        elif result == "ok":
            existing += 1
        else:
            blocked += 1

    print(f"\ndone: {created} created, {existing} already correct, "
          f"{blocked} blocked")


# Define the source and target directories for dotfiles
# To avoid ^M mess on WSL and macos, original dotfiles are stored in Ubuntu.
# Windows just symlinks to Ubuntu.
source_dir = (
    Path("//wsl.localhost/Ubuntu-22.04.2-PEES-0.0.7/home/yt75534/dotfiles")
    if platform.system() == "Windows"
    else Path.home() / "dotfiles"
)
target_dir = Path.home()

# Create symbolic links for all files in the dotfiles directory
link_dotfiles(source_dir, target_dir)