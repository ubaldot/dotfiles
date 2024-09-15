
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


conda activate dymoval_dev

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
# COLOR_DEF=$'%f'
# COLOR_USR=$'%F{243}'
# COLOR_DIR=$'%F{197}'
# COLOR_GIT=$'%F{39}'
# NEWLINE=$'\n'
# setopt PROMPT_SUBST
# # export PROMPT='${COLOR_USR}($CONDA_DEFAULT_ENV) ${COLOR_USR}%n ${COLOR_DIR}%~ ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF} $ '
# export PROMPT='${COLOR_USR}${COLOR_USR}%n ${COLOR_DIR}%~ ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}${NEWLINE}$ '

# Determines prompt modifier if and when a conda environment is active
precmd_conda_info() {
  if [[ -n $CONDA_PREFIX ]]; then
      if [[ $(basename $CONDA_PREFIX) == "anaconda3" ]]; then
        # Without this, it would display conda version. Change to miniconda3 if necessary
        CONDA_ENV="(base) "
      else
        # For all environments that aren't (base)
        CONDA_ENV="($(basename $CONDA_PREFIX)) "
      fi
  # When no conda environment is active, don't show anything
  else
    CONDA_ENV=""
  fi
}

# Display git branch
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

# Run the previously defined function before each prompt
precmd_functions+=(precmd_conda_info)

# Define colors
COLOR_CON=$'%F{141}'
COLOR_DEF=$'%f'
COLOR_USR=$'%F{247}'
COLOR_DIR=$'%F{197}'
COLOR_GIT=$'%F{215}'

# Allow substitutions and expansions in the prompt
setopt prompt_subst

# PROMPT='${COLOR_CON}$CONDA_ENV${COLOR_USR}%n ${COLOR_DIR}%1~ ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}$ '
PROMPT='${COLOR_CON}$CONDA_ENV${COLOR_USR}%n ${COLOR_DIR}%~ ${COLOR_GIT}$(parse_git_branch)'$'\n''${COLOR_DEF}$ '


# Autocomplete based on history when using <up> and <down>
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search
alias docker-om='docker run -it --rm -v "$HOME:$HOME" -e "HOME=$HOME" -w "$PWD" -e "DISPLAY=`ifconfig | grep -o "inet [0-9.]*" | grep -Eo "[0-9.]{7,}" | grep -Fv 127.0.0.1 | head -1`:0" --user $UID openmodelica/openmodelica:v1.21.0-gui'

# fzf stuff
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source ~/.fzf-git/fzf-git.sh
# export FZF_COMPLETION_TRIGGER=''

# LaTeX
export PATH="/usr/local/texlive/2024/bin/universal-darwin/:$PATH"
