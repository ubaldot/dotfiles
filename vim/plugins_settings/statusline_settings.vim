vim9script

# statusline
# ---------------
# Define all the functions that you need in your statusline and then build the statusline
set laststatus=2
set statusline=

# Get git branch name for statusline.
# OBS !It may need to be changed for other OS.
def Get_gitbranch(): string
    var current_branch = trim(system("git -C " .. expand("%:h") .. " branch
                \ --show-current"))
    # strdix(A,B) >=0 check if B is in A.
    if stridx(current_branch, "not a git repository") >= 0
        current_branch = "(no repo)"
    endif
    return current_branch
enddef

augroup Gitget
    autocmd!
    autocmd BufEnter,BufWinEnter * b:gitbranch = Get_gitbranch()
augroup END

def ShowFuncName(): string
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
    return text
enddef

augroup show_funcname
    autocmd!
    autocmd BufEnter,BufWinEnter,CursorMoved * b:current_function = ShowFuncName()
augroup end


def Conda_env(): string
    var conda_env = "base"
    if has("gui_win32") || has("win32")
        conda_env = trim(system("echo %CONDA_DEFAULT_ENV%"))
    elseif exists("$CONDA_DEFAULT_ENV")
        conda_env = $CONDA_DEFAULT_ENV
    endif
    return conda_env
enddef

augroup CONDA_ENV
    autocmd!
    autocmd VimEnter,BufEnter,BufWinEnter * g:conda_env = Conda_env()
augroup END

augroup LSP_DIAG
    autocmd!
    autocmd BufEnter,BufWinEnter *  b:num_warnings = 0 | b:num_errors = 0
    autocmd User LspDiagsUpdated b:num_warnings = lsp#lsp#ErrorCount()['Warn']
                \ | b:num_errors = lsp#lsp#ErrorCount()['Error']
augroup END

# Anatomy of the statusline:
# Start of highlighting	- Dynamic content - End of highlighting
# %#IsModified#	- %{&mod?expand('%'):''} - %*

# Left side
set statusline+=%#StatusLineNC#\ (%{g:conda_env})\ %*
set statusline+=%#WildMenu#\ \ %{b:gitbranch}\ %*
set statusline+=%#StatusLine#\ %t(%n)%m%*
set statusline+=%#StatusLineNC#\%{b:current_function}\ %*
# Right side
set statusline+=%=
set statusline+=%#StatusLine#\ %y\ %*
set statusline+=%#StatusLineNC#\ col:%c\ %*
# Add some conditionals here bitch!
set statusline+=%#Visual#\ W:\ %{b:num_warnings}\ %*
set statusline+=%#CurSearch#\ E:\ %{b:num_errors}\ %*
# ----------- end statusline setup -------------------------
