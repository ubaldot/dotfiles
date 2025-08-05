
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
# export PATH="/usr/local/texlive/2024/bin/universal-darwin/:$PATH"
#
pixi-activate() {
  local name="$1"
  local base="$HOME/pixi-envs"
  local env="$base/$name"
  if [[ -d "$env" && -f "$env/pixi.toml" ]]; then
    pixi shell --manifest-path "$env"
  else
    echo "No pixi environment named '$name' found in $base"
    return 1
  fi
}


pixi-list() {
  local base="$HOME/pixi-envs"
  find "$base" -maxdepth 1 -mindepth 1 -type d -exec test -f '{}/pixi.toml' \; -print | xargs -n1 basename 2>/dev/null
}


pixi-install() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: pixi-install <package> [more packages...]"
    return 1
  fi

  if [[ -z "$PIXI_PROJECT_ROOT" ]]; then
    echo "❌ Not inside a pixi shell — cannot determine project root"
    return 1
  fi

  echo "📦 Installing into environment: ${PIXI_PROJECT_NAME:-$PIXI_PROJECT_ROOT}"
  pixi add --manifest-path "$PIXI_PROJECT_ROOT" "$@"
}

pixi-remove() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: pixi-remove <package> [more packages...]"
    return 1
  fi

  if [[ -z "$PIXI_PROJECT_ROOT" ]]; then
    echo "❌ Not inside a pixi shell — cannot determine project root"
    return 1
  fi

  echo "🗑️ Removing from environment: ${PIXI_PROJECT_NAME:-$PIXI_PROJECT_ROOT}"
  pixi remove --manifest-path "$PIXI_PROJECT_ROOT" "$@"
}


pixi-create() {
  local name="$1"; shift
  local base="$HOME/pixi-envs"
  local env_path="$base/$name"

  if [[ -z "$name" ]]; then
    echo "Usage: pixi-create <env-name> [packages...]"
    return 1
  fi

  if [[ -e "$env_path" ]]; then
    echo "❌ Environment '$name' already exists at $env_path"
    return 1
  fi

  echo "📁 Creating Pixi environment: $env_path"
  mkdir -p "$env_path"
  cd "$env_path" || return 1

  pixi init

  if [[ $# -gt 0 ]]; then
    pixi add "$@"
  fi

  echo "✅ Environment '$name' created at $env_path"
}

pixi-switch() {
  local name="$1"
  local base="$HOME/pixi-envs"
  local env="$base/$name"

  if [[ -z "$name" ]]; then
    echo "Usage: pixi-switch <env-name>"
    return 1
  fi

  if [[ ! -d "$env" || ! -f "$env/pixi.toml" ]]; then
    echo "❌ Environment '$name' not found in $base"
    return 1
  fi

  echo "🔄 Switching to Pixi environment: $name"
  pixi shell --manifest-path "$env"
}

pixi-remove-env() {
  local name="$1"
  local base="$HOME/pixi-envs"
  local env_path="$base/$name"

  if [[ -z "$name" ]]; then
    echo "Usage: pixi-remove-env <env-name>"
    return 1
  fi

  if [[ ! -d "$env_path" ]]; then
    echo "❌ No such Pixi environment: $env_path"
    return 1
  fi

  # Ask for confirmation
  read -p "⚠️ Are you sure you want to delete '$env_path'? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$env_path"
    echo "🗑️ Removed Pixi environment: $env_path"
  else
    echo "❎ Aborted"
  fi
}


# pixi-activate py314
