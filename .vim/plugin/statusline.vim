vim9script

# statusline
# ---------------
# The statusline is set ONCE, globally. Every dynamic part is a %{} expression
# which Vim evaluates at redraw time in the context of the window being drawn,
# so there is nothing to recompute per buffer and no autocmd is needed.
#
# This also means the statusline is never written with :setlocal, so any window
# that sets its own window-local 'statusline' (plugin scratch buffers, mail
# composers, file explorers, ...) keeps it instead of having it overwritten.

set showtabline=2
set laststatus=2

const DEV_FILETYPES = ['c', 'python', 'cpp', 'latex']

# --- git branch -------------------------------------------------------------

def UpdateGitBranch(buf_enter: bool)
  g:git_branch = ''

  def GitBranchStdout(id: any, msg: string)
    g:git_branch = nr2char(0xE0A0) .. ' ' .. msg->trim()
  enddef

  def GitBranchStderr(id: any, msg: string)
    g:git_branch = nr2char(0xE0A0) .. ' No repo'
  enddef

  # Recompute git branch only upon switch or checkout
  var last_cmd = histget('cmd', -1)
  var git_change_branch_regex = '\v(git co |git checkout|git switch)'
  if last_cmd =~ git_change_branch_regex || buf_enter
    var dir = expand("%:p:h")
    job_start($'git -C {shellescape(dir)} rev-parse --abbrev-ref HEAD ',
      {out_cb: GitBranchStdout, err_cb: GitBranchStderr}
    )
  endif
enddef

def g:GitBranch(): string
  return get(g:, 'git_branch', '')
enddef

# Update the Git branch only when changing buffers
augroup UPDATE_GIT_BRANCH
  autocmd!
  autocmd ShellCmdPost * UpdateGitBranch(false)
  autocmd BufEnter * UpdateGitBranch(true)
augroup END

# --- conda environment ------------------------------------------------------

def Set_g_conda_env()
  var conda_env = "base"
  if g:os ==# "Windows"
    conda_env = trim(system("echo %CONDA_DEFAULT_ENV%"))
  elseif exists("$CONDA_DEFAULT_ENV")
    conda_env = $CONDA_DEFAULT_ENV
  endif
  g:conda_env = conda_env
enddef

# Resolved on the first redraw rather than at startup, so the system() call
# does not slow Vim down before anything is on screen.
def g:StatuslineConda(): string
  if !exists('g:conda_env')
    Set_g_conda_env()
  endif
  return g:conda_env
enddef

# --- lsp diagnostics --------------------------------------------------------

# Returns statusline items (used with %{%...%}) so that the highlight groups
# are emitted only when there is something to show.
def g:StatuslineLsp(): string
  if !exists('*lsp#lsp#ErrorCount')
      || index(DEV_FILETYPES, &filetype) == -1
    return ''
  endif
  var counts = lsp#lsp#ErrorCount()
  return $'%#Visual# W: {counts["Warn"]} %*%#CurSearch# E: {counts["Error"]} %*'
enddef

# --- the statusline itself --------------------------------------------------

# Left side
# var statusline_left = '%#StatusLineNC# (%{g:StatuslineConda()}) %*'
#   .. '%#WildMenu# %{g:GitBranch()} %*'
#   .. ' %{fnamemodify(getcwd(), ":~")} %*'

# Right side
# var statusline_right = '%#StatusLine# %y%*'
#   .. ' %#StatusLineNC# %{&fileformat}%*'
#   .. ' %#StatusLine# %l,%c(%{charcol(".")})%*'
#   .. '%{%g:StatuslineLsp()%} -'
#   .. ' %{strftime("%a, %d %B %Y - w%V")} '

# Left side
var statusline_left = '%#WildMenu# %{g:GitBranch()} %*' .. " %f %m %r"
# Right side
var statusline_right = '%#StatusLine# %y %*'
  .. '%#StatusLineNC# %{&fileformat} %*'
  .. '%#StatusLine# %l,%c(%{charcol(".")}) %*'
  .. '%{%g:StatuslineLsp()%}'

&g:statusline = statusline_left .. '%=' .. statusline_right

# --- the tabline itself --------------------------------------------------
# Left side
var tabline_left = ' %#StatusLineNC# (%{g:StatuslineConda()}) %*'
  .. ' %{fnamemodify(getcwd(), ":~")} %*'

# Right side
# g:current_datetime = strftime("%A, %d %B %Y, %H:%M, w%V")

# def UpdateCurrentDatetime()
#   g:current_datetime = strftime("%A, %d %B %Y, %H:%M, w%V")
#   redrawtabline
# enddef

def g:Strftime(): string
  return strftime("%A, %d %B %Y, %H:%M, w%V")
enddef

var tabline_right = ' %{g:Strftime()}'

timer_start(60000, (_) => execute('redrawtabline'), {'repeat': -1})

&g:tabline = tabline_left .. '%=' .. tabline_right
