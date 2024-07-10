vim9script

# statusline
# ---------------
# Define all the functions that you need in your statusline and then build the statusline
set laststatus=2
set statusline=

# Get git branch name for statusline.
# OBS !It may need to be changed for other OS.

# Does not work
def Set_b_gitbranch()
    var branch_name = trim(system($'git -C {expand("%:h")} rev-parse --abbrev-ref HEAD 2>{g:null_device}'))
    if v:shell_error != 0
        branch_name = '(no repo)'
    else
        branch_name = substitute(branch_name, '\n', '', '')
    endif
    setbufvar(bufnr('%'), 'gitbranch', branch_name)
enddef

augroup Gitget
    autocmd!
    autocmd BufEnter,BufWinEnter * Set_b_gitbranch()
augroup END

def Set_b_current_function()
    var n_max = 20 # max chars to be displayed.
    var filetypes = ['c', 'cpp', 'python']
    var text = "" # displayed text

    if index(filetypes, &filetype) != -1
        # If the filetype is recognized, then search the function line
        var line = 0
        if index(['c', 'cpp'], &filetype) != -1
            line = search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bWn')
        elseif &filetype ==# 'python'
            line = search("^ \\{0,}def \\+.*", 'bWn')
        endif
        var n = match(getline(line), '\zs)') # Number of chars until ')'
        if n < n_max
            text = "|" .. trim(getline(line)[: n])
        else
            text = "|" .. trim(getline(line)[: n_max]) .. "..."
        endif
    endif
    # return text
    setbufvar(bufnr('%'), 'current_function', text)
enddef

augroup show_funcname
    autocmd!
    autocmd BufEnter,BufWinEnter,CursorMoved * Set_b_current_function()
augroup end


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
    # autocmd VimEnter,BufEnter,BufWinEnter * Set_g_conda_env()
    autocmd VimEnter * Set_g_conda_env()
augroup END

# Anatomy of the statusline:
# Start of highlighting	- Dynamic content - End of highlighting
# %#IsModified#	- %{&mod?expand('%'):''} - %*

# Left side
set statusline+=%#StatusLineNC#\ (%{g:conda_env})\ %*
set statusline+=%#WildMenu#\ \ %{get(b:,'gitbranch','')}\ %*
# set statusline+=%#WildMenu#\ \ %{b:gitbranch}\ %*
set statusline+=%#StatusLine#\ %t(%n)%m%*
set statusline+=%#StatusLineNC#\%{get(b:,'current_function','')}\ %*
# Right side
set statusline+=%=
set statusline+=%#StatusLine#\ %y\ %*
set statusline+=%#StatusLineNC#\ col:%c\ %*
# Add some conditionals here bitch!
set statusline+=%#Visual#\ W:\ %{lsp#lsp#ErrorCount()['Warn']}\ %*
set statusline+=%#CurSearch#\ E:\ %{lsp#lsp#ErrorCount()['Error']}\ %*
# ----------- end statusline setup -------------------------
