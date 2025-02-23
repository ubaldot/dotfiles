vim9script

# statusline
# ---------------
# Define all the functions that you need in your statusline and then build
# the statusline
set laststatus=2

if g:dev_setup

  def UpdateGitBranch(buf_enter: bool)
    g:git_branch = ''

    def GitBranchStdout(id: any, message: string)
      g:git_branch = $'{nr2char(0xE0A0)} {message}'
      redrawstatus
    enddef
    def GitBranchStderr(id: any, message: string)
      g:git_branch = nr2char(0xE0A0) .. ' No repo'
      redrawstatus
    enddef

    var last_cmd = histget('cmd', -1)
    var git_change_branch_regex = '\v(git co |git checkout|git switch)'
    if last_cmd =~ git_change_branch_regex || buf_enter
      job_start($'git -C {expand("%:p:h")} rev-parse --abbrev-ref HEAD ',
      {out_cb: GitBranchStdout, err_cb: GitBranchStderr}
      )
    endif
  enddef

  def g:GitBranch(): string
    return g:git_branch
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

  augroup CONDA_ENV
      autocmd!
      autocmd VimEnter * Set_g_conda_env()
  augroup END

  def g:LSPErrorCount(): dict<any>
    if exists('*lsp#lsp#ErrorCount')
      return lsp#lsp#ErrorCount()
    else
      return {Error: 0, Warn: 0}
    endif
  enddef
endif

augroup STATUSLINE
    autocmd!
    autocmd VimEnter,BufEnter * SetStatusLine()
augroup END

def CommonStatusLine()
  setlocal statusline=

  # Anatomy of the statusline:
  # Start of highlighting	- Dynamic content - End of highlighting
  # %#IsModified#	- %{&mod?expand('%'):''} - %*

  # Left side
  if g:dev_setup
    setlocal statusline+=%#StatusLineNC#\ (%{g:conda_env})\ %*
    setlocal statusline+=%#WildMenu#\ %{g:GitBranch()}\ %*
  else
    setlocal statusline+=%#WildMenu#\ \ No\ git\ %*
  endif
  setlocal statusline+=\ %{fnamemodify(getcwd(),':~')}\ %*
  # Current function
  # setlocal statusline+=%#StatusLineNC#\%{get(b:,'current_function','')}\ %*
  #
  # Right side
  setlocal statusline+=%=
  # Current file
  # setlocal statusline+=%#StatusLine#\ %t(%n)%m%*
  # filetype
  setlocal statusline+=%#StatusLine#\ %y%*
  # Fileformat
  setlocal statusline+=%#StatusLineNC#\ %{&fileformat}\ %*
  setlocal statusline+=%#StatusLine#\ %l,%c\ %*
  # ----------- end statusline setup -------------------------
 enddef

def SetStatusLine()
  CommonStatusLine()
  if g:dev_setup
    && index(g:lsp_filetypes, &filetype) != -1
    && exists('lsp#lsp#ErrorCount()') != 0
    setlocal statusline+=%#Visual#\ W:\ %{lsp#lsp#ErrorCount()['Warn']}\ %*
    setlocal statusline+=%#CurSearch#\ E:\ %{lsp#lsp#ErrorCount()['Error']}\ %*
  endif
enddef
