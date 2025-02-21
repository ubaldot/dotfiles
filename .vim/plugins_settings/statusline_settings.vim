vim9script

# statusline
# ---------------
# Define all the functions that you need in your statusline and then build the statusline
set laststatus=2

if g:dev_setup
  g:last_git_branch = ''
  g:last_git_dir = ''

  def UpdateGitBranch()
    var git_cmd = 'git rev-parse --show-toplevel'
    var git_dir = system(git_cmd)
    if v:shell_error != 0
      g:last_git_branch = ''
      g:last_git_dir = ''
    elseif git_dir !=# g:last_git_dir
      # Only update if we've entered a new Git directory
      g:last_git_branch = system($'git rev-parse --abbrev-ref HEAD 2>{g:null_device}')
      g:last_git_branch = v:shell_error ? '' : ' ' .. substitute(g:last_git_branch, '\n', '', 'g')
      g:last_git_dir = git_dir
    endif
  enddef

  def g:GitBranch(): string
    return g:last_git_branch
  enddef

  # Update the Git branch only when changing buffers
  augroup UPDATE_GIT_BRANCH
  autocmd!
  autocmd BufEnter * UpdateGitBranch()
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
  endif
  setlocal statusline+=%#WildMenu#\ \ No\ git\ %*
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
  setlocal statusline+=%#StatusLine#\ (%l,%c)\ %*
  # ----------- end statusline setup -------------------------
 enddef

def SetStatusLine()
  CommonStatusLine()
  if g:dev_setup
    index(g:lsp_filetypes, &filetype) != -1 && exists('lsp#lsp#ErrorCount()') != 0
    setlocal statusline+=%#Visual#\ W:\ %{lsp#lsp#ErrorCount()['Warn']}\ %*
    setlocal statusline+=%#CurSearch#\ E:\ %{lsp#lsp#ErrorCount()['Error']}\ %*
  endif
enddef
