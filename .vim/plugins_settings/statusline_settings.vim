vim9script

# statusline
# ---------------
# Define all the functions that you need in your statusline and then build the statusline
set laststatus=2

g:last_git_branch = ''
g:last_git_dir = ''

def UpdateGitBranch()
  var git_dir = system('git rev-parse --show-toplevel')
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


augroup CONDA_ENV
    autocmd!
    autocmd FileType c,cpp,python,tex SetStatusLine()
augroup END

def CommonStatusLine()
  set statusline=

  # Anatomy of the statusline:
  # Start of highlighting	- Dynamic content - End of highlighting
  # %#IsModified#	- %{&mod?expand('%'):''} - %*

  # Left side
  set statusline+=%#StatusLineNC#\ (%{g:conda_env})\ %*
  set statusline+=%#WildMenu#\ %{g:GitBranch()}\ %*
  set statusline+=\ %{fnamemodify(getcwd(),':~')}\ %*
  # Current function
  # set statusline+=%#StatusLineNC#\%{get(b:,'current_function','')}\ %*
  #
  # Right side
  set statusline+=%=
  # Current file
  # set statusline+=%#StatusLine#\ %t(%n)%m%*
  # filetype
  set statusline+=%#StatusLine#\ %y%*
  # Fileformat
  set statusline+=%#StatusLineNC#\ %{&fileformat}\ %*
  set statusline+=%#StatusLine#\ (%l, %c)\ %*
  # Add some conditionals here bitch!
  # set statusline+=%#Visual#\ W:\ %{LSPErrorCount()['Warn']}\ %*
  # set statusline+=%#CurSearch#\ E:\ %{LSPErrorCount()['Error']}\ %*
  set statusline+=%#Visual#\ W:\ %{lsp#lsp#ErrorCount()['Warn']}\ %*
  set statusline+=%#CurSearch#\ E:\ %{lsp#lsp#ErrorCount()['Error']}\ %*
  # ----------- end statusline setup -------------------------
 enddef

def SetStatusLine()
  CommonStatusLine()
  if index(g:lsp_filetypes, &filetype) != 0 && exists(lsp#lsp#ErrorCount()) != 0
    set statusline+=%#Visual#\ W:\ %{lsp#lsp#ErrorCount()['Warn']}\ %*
    set statusline+=%#CurSearch#\ E:\ %{lsp#lsp#ErrorCount()['Error']}\ %*
  endif
enddef

CommonStatusLine()
