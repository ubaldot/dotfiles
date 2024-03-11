@echo off

REM Define paths
set "DOTFILES_DIR=%USERPROFILE%\dotfiles"
set "HOME_DIR=%USERPROFILE%"

cd /d "%DOTFILES_DIR%"
git pull

REM Copy dotfiles
set "files=.zshrc .zprofile .vimrc .gvimrc sync_dotfiles.sh sync_dotfiles.bat"
for %%f in (%files%) do (
    if exist "%HOME_DIR%\%%f" (
        REM File exists, use rsync
        rsync -a "%HOME_DIR%\%%f" "%DOTFILES_DIR%"
    ) else (
        REM File doesn't exist, use copy
        copy /Y "%HOME_DIR%\%%f" "%DOTFILES_DIR%"
    )
)

REM Copy vim files
rsync -a "%HOME_DIR%\.vim\helpme_files\*" "%DOTFILES_DIR%\vim\helpme_files"
rsync -a "%HOME_DIR%\.vim\ftplugin\*" "%DOTFILES_DIR%\vim\ftplugin"
rsync -a "%HOME_DIR%\.vim\lib\*" "%DOTFILES_DIR%\vim\lib"

REM Copy manim files
rsync -a --exclude="__manim__" "%HOME_DIR%\.manim\" "%DOTFILES_DIR%\manim"

REM Add all changes to Git
git add -u

REM Check if there are changes to commit
git diff-index --quiet HEAD --
if %errorlevel% equ 0 (
    echo No changes to commit. Exiting.
    exit /b 0
)

REM Commit changes
git commit -m "Update dotfiles: %date%"

REM Push changes to remote repository
git push

cd /d "%HOME_DIR%"
