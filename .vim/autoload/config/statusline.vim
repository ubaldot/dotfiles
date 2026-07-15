vim9script

# statusline
# ---------------
# Define all the functions that you need in your statusline and then build
# the statusline
set laststatus=2

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
  if exists('g:git_branch')
    return g:git_branch
  else
    return ''
  endif
enddef

# Update the Git branch only when changing buffers
augroup UPDATE_GIT_BRANCH
  autocmd!
  autocmd ShellCmdPost * UpdateGitBranch(false)
  autocmd BufEnter * UpdateGitBranch(true)
augroup END

def Set_g_conda_env()
    var conda_env = "base"
    if g:os ==# "Windows"
        conda_env = trim(system("echo %CONDA_DEFAULT_ENV%"))
    elseif exists("$CONDA_DEFAULT_ENV")
        conda_env = $CONDA_DEFAULT_ENV
    endif
    g:conda_env = conda_env
enddef

def CommonStatusLine()
  setlocal statusline=

  # Anatomy of the statusline:
  # Start of highlighting	- Dynamic content - End of highlighting
  # %#IsModified#	- %{&mod?expand('%'):''} - %*

  # Left side
  if exists('g:conda_env') == 0
    Set_g_conda_env()
  endif

  setlocal statusline+=%#StatusLineNC#\ (%{g:conda_env})\ %*
  setlocal statusline+=%#WildMenu#\ %{g:GitBranch()}\ %*
  setlocal statusline+=\ %{fnamemodify(getcwd(),':~')}\ %*
  # Current function
  # setlocal statusline+=%#StatusLineNC#\%{get(b:,'current_function','')}\ %*
  #
  # Right side
  setlocal statusline+=%=
  # Current file
  # setlocal statusline+=%#StatusLine#\ %t(%n)%m%*
  # filetype
  setlocal statusline+=%#StatusLine#\ %y\ %*
  # Fileformat
  setlocal statusline+=%#StatusLineNC#\ %{&fileformat}\ %*
  setlocal statusline+=%#StatusLine#\ %l,%c(%{charcol('.')})\ %*
  # ----------- end statusline setup -------------------------
 enddef

export def Init(is_dev: bool = false)
  CommonStatusLine()
  if is_dev && exists('*lsp#lsp#ErrorCount')
    setlocal statusline+=%#Visual#\ W:\ %{lsp#lsp#ErrorCount()['Warn']}\ %*
    setlocal statusline+=%#CurSearch#\ E:\ %{lsp#lsp#ErrorCount()['Error']}\ %*
  endif
enddef
