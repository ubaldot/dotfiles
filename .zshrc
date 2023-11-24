
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


conda activate manim_ce

#
alias ctags="/opt/homebrew/bin/ctags"

export LIBGS=/opt/homebrew/Cellar/ghostscript/10.02.1/lib/libgs.10.02.dylib


# To have the git branch on the prompt plus nice colors
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

# use yellow for directories
export CLICOLOR=1
export LSCOLORS=dxfxcxdxbxegedabagacad

# Pretty print the PATH
alias path='echo; tr ":" "\n" <<< "$PATH"; echo;'

# PROMPT SETTINGS
COLOR_DEF=$'%f'
COLOR_USR=$'%F{243}'
COLOR_DIR=$'%F{197}'
COLOR_GIT=$'%F{39}'
NEWLINE=$'\n'
setopt PROMPT_SUBST
# export PROMPT='${COLOR_USR}($CONDA_DEFAULT_ENV) ${COLOR_USR}%n ${COLOR_DIR}%~ ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF} $ '
export PROMPT='${COLOR_USR}${COLOR_USR}%n ${COLOR_DIR}%~ ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}${NEWLINE}$ '

# Autocomplete based on history when using <up> and <down>
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
alias docker-om='docker run -it --rm -v "$HOME:$HOME" -e "HOME=$HOME" -w "$PWD" -e "DISPLAY=`ifconfig | grep -o "inet [0-9.]*" | grep -Eo "[0-9.]{7,}" | grep -Fv 127.0.0.1 | head -1`:0" --user $UID openmodelica/openmodelica:v1.21.0-gui'
