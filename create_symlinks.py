import subprocess
import platform
from pathlib import Path


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

    for source_file in source_path.rglob("*"):
        # Calculate the relative path from the source directory
        rel_path = source_file.relative_to(source_path)

        # Skip any directories or files within the .git or .vim directories
        if ".git" in rel_path.parts:
            continue

        # Create the corresponding target path
        # Replace .vim with vimfiles if on Windows
        if platform.system() == "Windows" and rel_path.parts[0] == ".vim":
            rel_path = Path("vimfiles").joinpath(*rel_path.parts[1:])

        target_file = target_path / rel_path

        if source_file.is_dir():
            target_file.mkdir(parents=True, exist_ok=True)
        else:
            create_symlink(source_file, target_file)


# Get the home directory
home_dir = Path.home()

# Define the source and target directories for dotfiles
source_dir = home_dir / "dotfiles"
target_dir = home_dir

# Create symbolic links for all files in the dotfiles directory
link_dotfiles(source_dir, target_dir)
