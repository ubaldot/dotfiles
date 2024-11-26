import os
import subprocess
import platform


def create_symlink(source, target):
    """Create a symbolic link at target pointing to source."""
    if platform.system() == "Windows":
        subprocess.run(["cmd", "/c", "mklink", target, source], shell=True)
    else:
        subprocess.run(["ln", "-s", source, target])


def link_vimfiles(source_dir, target_dir):
    """Recursively create symbolic links for all files in source_dir."""
    for root, dirs, files in os.walk(source_dir):
        # Calculate the relative path from the source directory
        rel_path = os.path.relpath(root, source_dir)

        # Create the corresponding target directory
        target_root = os.path.join(target_dir, rel_path)
        if not os.path.exists(target_root):
            os.makedirs(target_root)

        # Create symbolic links for files
        for file in files:
            source_file = os.path.join(root, file)
            target_file = os.path.join(target_root, file)
            create_symlink(source_file, target_file)


def link_dotfiles(source_dir, target_dir):
    """Recursively create symbolic links for all files in source_dir."""
    for root, dirs, files in os.walk(source_dir):
        # Calculate the relative path from the source directory
        rel_path = os.path.relpath(root, source_dir)

        # Skip any directories or files within the .git or .vim directories
        if ".git" in rel_path.split(os.sep) or ".vim" in rel_path.split(
            os.sep
        ):
            continue

        # Create the corresponding target directory
        target_root = os.path.join(target_dir, rel_path)
        if not os.path.exists(target_root):
            os.makedirs(target_root)

        # Create symbolic links for files
        for file in files:
            source_file = os.path.join(root, file)
            target_file = os.path.join(target_root, file)
            create_symlink(source_file, target_file)


#  -------- Get the home directory -------------
home_dir = os.path.expanduser("~")

# ---------- Create symbolic links for all files in
#  the dotfiles/.vim directory ----------------------
# Define the source and target directories for vim
source_dir = os.path.join(home_dir, "dotfiles", ".vim")
target_dir = (
    os.path.join(home_dir, "vimfiles")
    if platform.system() == "Windows"
    else os.path.join(home_dir, ".vim")
)
link_vimfiles(source_dir, target_dir)

# ---------- Create symbolic links for all files in
#  the dotfiles directory (no vim) ----------------------

# Define the source and target directories for vim
source_dir = os.path.join(home_dir, "dotfiles")
target_dir = home_dir

# Create symbolic links for all files in the dotfiles directory
link_dotfiles(source_dir, target_dir)
