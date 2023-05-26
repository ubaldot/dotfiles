vim9script
#=====================
# For auto-completion, jumps to definitions, etc
# you can either use ctags or LSP.
# gutentags automatically creates ctags as you open files
# so you don't need to create them manually.
#

import "./.vim/lib/myfunctions.vim"

if has("gui_win32") || has("win32")
    g:dotvim = $HOME .. "\\vimfiles"
    set pythonthreehome=$HOME .. "\\Miniconda3"
    set pythonthreedll=$HOME.. "\\Miniconda3\\python39.dll"
elseif has("mac")
    g:dotvim = $HOME .. "/.vim"
    &pythonthreehome = fnamemodify(trim(system("which python")), ":h:h")
    &pythonthreedll = trim(system("which python"))
endif

augroup ReloadVimScripts
    autocmd!
    autocmd BufWritePost *.vim,*.vimrc,*.gvimrc exe "source %" # | echo
                \ expand('%:t') .. " reloaded."
augroup END

# augroup CommandWindowOpen
#     autocmd!
#     autocmd CmdwinEnter * map <buffer> <CR> <CR>q:
# augroup END


# Open help pages in vertical split
augroup vimrc_help
    autocmd!
    autocmd BufEnter *.txt if &buftype == 'help' | wincmd H | endif
augroup END

# Internal vim variables aka 'options'
set encoding=utf-8
# Set terminal with 256 colors
set termguicolors
set autoread
set number
set nowrap
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nobackup
set backspace=indent,eol,start
set nocompatible              # required
set clipboard=unnamed
set splitbelow
set laststatus=2
set incsearch # for displaying while searching
set smartcase
set hidden
set noswapfile
set spell spelllang=en_us
set nofoldenable
set foldmethod=syntax
set foldlevelstart=20
set wildmenu wildoptions=pum
set completeopt-=preview
set textwidth=78
set iskeyword+="-"
set formatoptions+=w,n,p
set diffopt+=vertical

# Some key bindings
# ----------------------
g:mapleader = ","
map <leader>vr <Cmd>source $MYVIMRC<CR> \| <Cmd>echo ".vimrc reloaded."
map <leader>vv <Cmd>e $MYVIMRC<CR>
nnoremap x "_x
nnoremap <leader>w <Cmd>bp<cr><Cmd>bw! #<cr>
nnoremap <leader>b <Cmd>ls!<CR>:b
nnoremap <C-Tab> <Plug>Bufselect_Toggle
# nnoremap <C-Tab> <Plug>(FileselectToggle)
nnoremap <S-Tab> <Cmd>bnext<CR>
nnoremap <leader>c <C-w>c<cr>
noremap <c-PageDown> <Cmd>bprev<CR>
noremap <c-PageUp> <Cmd>bnext<CR>
# Switch window
# nnoremap <C-w>w :bp<cr>:bw! #<cr>
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j
# Switch window with arrows
# nnoremap <c-Left> <C-w>h<cr>
# nnoremap <c-Right> <C-w>l<cr>

# super quick search and replace:
nnoremap <Space><Space> :%s/\<<C-r>=expand("<cword>")<CR>\>/
# to be able to undo accidental c-w"
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
# Automatically surround highlighted selection
xnoremap ( <ESC>`>a)<ESC>`<i(<ESC>
xnoremap ) <ESC>`>a)<ESC>`<i(<ESC>
xnoremap [ <ESC>`>a]<ESC>`<i[<ESC>
xnoremap ] <ESC>`>a]<ESC>`<i[<ESC>
xnoremap { <ESC>`>a}<ESC>`<i{<ESC>
xnoremap } <ESC>`>a}<ESC>`<i{<ESC>
# Don't use the following otherwise you lose registers function!
# Indent without leaving the cursor position
nnoremap g= <Cmd>vim9cmd b:temp = winsaveview()<CR>gg=G
            \ <Cmd>vim9cmd winrestview(b:temp)<cr>
            \ <Cmd>vim9cmd unlet b:temp<cr>
            \ <Cmd>echo "file indented"<CR>

# Format text
nnoremap g- <Cmd>vim9cmd b:temp = winsaveview()<CR>gggqG
            \ <Cmd>vim9cmd winrestview(b:temp)<cr>
            \ <Cmd>vim9cmd unlet b:temp<cr>
            \ <Cmd>echo "file formatted, textwidth: "
            \ .. &textwidth .. " cols."<cr>

# Some terminal remapping
# When using iPython to avoid that shift space gives 32;2u
tnoremap <S-space> <space>
tnoremap <ESC> <c-w>N
tnoremap <c-h> <c-w>h
tnoremap <c-l> <c-w>l
tnoremap <c-k> <c-w>k
tnoremap <c-j> <c-w>j
# tnoremap <c-PageDown> <c-w>:bprev<CR>
tnoremap <S-tab> <c-w>:bnext<CR>
tnoremap <C-Tab> <Plug>Bufselect_Toggle

# Open terminal below all windows
exe "cabbrev bter bo terminal " .. &shell
exe "cabbrev vter vert botright terminal " .. &shell


# vim-plug
# ----------------
plug#begin(g:dotvim .. "/plugins/")
Plug 'junegunn/vim-plug' # For getting the help, :h plug-options
Plug 'sainnhe/everforest'
Plug 'preservim/nerdtree'
Plug 'machakann/vim-highlightedyank'
# Plug 'cjrh/vim-conda'
Plug 'yegappan/bufselect'
Plug 'yegappan/lsp'
# # Plug 'ludovicchabant/vim-gutentags'
Plug 'tpope/vim-commentary'
# # Plug 'tpope/vim-scriptease'
Plug 'ubaldot/vim-conda-activate'
Plug 'ubaldot/vim-helpme'
Plug 'ubaldot/vim-outline'
Plug 'ubaldot/vim-replica'
Plug 'ubaldot/vim-writegood'
plug#end()
# filetype plugin indent on
syntax on


# Plugins settings
# -----------------
# everforest colorscheme
var hour = str2nr(strftime("%H"))
if hour < 7 || 19 < hour
    set background=dark
else
    set background=light
endif
colorscheme everforest
g:airline_theme = 'everforest'

# statusline
# ---------------
# var palette = everforest#get_palette(&background, {})
# echom palette

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


def Conda_env(): string
    var conda_env = "base"
    if has("gui_win32") || has("win32")
        conda_env = trim(system("echo %CONDA_DEFAULT_ENV%"))
    elseif has("mac") && exists("$CONDA_DEFAULT_ENV")
        conda_env = $CONDA_DEFAULT_ENV
        # system() open a new shell and by default is 'base'.
        # conda_env = trim(system("echo $CONDA_DEFAULT_ENV"))
    endif
    return conda_env
enddef

augroup CONDA_ENV
    autocmd!
    autocmd BufEnter,BufWinEnter * g:conda_env = Conda_env()
augroup END

augroup LSP_DIAG
    autocmd!
    autocmd BufEnter *  b:num_warnings = 0 | b:num_errors = 0
    autocmd User LspDiagsUpdated b:num_warnings = lsp#lsp#ErrorCount()['Warn']
                \ | b:num_errors = lsp#lsp#ErrorCount()['Error']
augroup END

# Anatomy of the statusline:
# Start of highlighting	- Dynamic content - End of highlighting
# %#IsModified#	- %{&mod?expand('%'):''} - %*

# Left side
set statusline+=%#StatusLineNC#\ (%{g:conda_env})\ %*
set statusline+=%#WildMenu#\ \ %{b:gitbranch}\ %*
set statusline+=%#StatusLine#\ %t(%n)%m\ %*
# Right side
set statusline+=%=
set statusline+=%#StatusLine#\ %y\ %*
set statusline+=%#StatusLineNC#\ col:%c\ %*
# Add some conditionals here bitch!
set statusline+=%#Visual#\ W:\ %{b:num_warnings}\ %*
set statusline+=%#CurSearch#\ E:\ %{b:num_errors}\ %*


# NERDTree
# ----------------
autocmd FileType nerdtree setlocal nolist
nnoremap <F1> :NERDTreeToggle<cr>
augroup DIRCHANGE
    autocmd!
    autocmd DirChanged global NERDTreeCWD
    autocmd DirChanged global ChangeTerminalDir()
augroup END
# Close NERDTree when opening a file
g:NERDTreeQuitOnOpen = 1



# This json-like style to encode configs like
# pylsp.plugins.pycodestyle.enabled = true
var pylsp_config = {
    'pylsp': {
        'plugins': {
            'pycodestyle': {
                'enabled': v:false},
            'pyflakes': {
                'enabled': v:false},
            'pydocstyle': {
                'enabled': v:false},
            'autopep8': {
                'enabled': v:false}, }, }, }


var lspServers = [
    {
        name: 'pylsp',
        filetype: ['python'],
        path: trim(system('where pylsp')),
        workspaceConfig: pylsp_config,
    },
]
autocmd VimEnter * g:LspAddServer(lspServers)

var lspOpts = {'showDiagOnStatusLine': v:true}
autocmd VimEnter * g:LspOptionsSet(lspOpts)
highlight link LspDiagLine NONE

nnoremap <silent> <buffer> <leader>N <Cmd>LspDiagPrev<cr>
nnoremap <silent> <buffer> <leader>n <Cmd>LspDiagNext<cr>
nnoremap <silent> <buffer> <leader>i <Cmd>LspGotoImpl<cr>
nnoremap <silent> <buffer> <leader>g <Cmd>LspGotoDefinition<cr>
nnoremap <silent> <buffer> <leader>d <Cmd>LspDiagCurrent<cr>
nnoremap <silent> <buffer> <leader>k <Cmd>LspHover<cr>
nnoremap <silent> <buffer> <leader>r <Cmd>LspPeekReferences<cr>


# HelpMe files for my poor memory
command! VimHelpBasic :HelpMe ~/.vim/helpme_files/vim_basic.txt
command! VimHelpScript :HelpMe ~/.vim/helpme_files/vim_scripting.txt
command! VimHelpCoding :HelpMe ~/.vim/helpme_files/vim_coding.txt
command! VimHelpGlobal :HelpMe ~/.vim/helpme_files/vim_global.txt
command! VimHelpExCommands :HelpMe ~/.vim/helpme_files/vim_excommands.txt
command! VimHelpSubstitute :HelpMe ~/.vim/helpme_files/vim_substitute.txt
command! VimHelpAdvanced :HelpMe ~/.vim/helpme_files/vim_advanced.txt
command! VimHelpNERDTree :HelpMe ~/.vim/helpme_files/vim_nerdtree.txt
command! VimHelpMerge :HelpMe ~/.vim/helpme_files/vim_merge.txt

command! ColorToggle myfunctions.ColorsToggle()

# Utils commands
command! -nargs=1 -complete=command -range Redir
            \ silent myfunctions.Redir(<q-args>, <range>, <line1>, <line2>)

# Source additional files
# source $HOME/PE.vim
# source $HOME/VAS.vim
# source $HOME/dymoval.vim

# vim-replica stuff
g:replica_console_position = "J"
g:replica_console_height = 10
g:replica_python_options = "-Xfrozen_modules=off"
g:replica_jupyter_console_options = {"python":
            \ " --config ~/.jupyter/jupyter_console_config.py"}



# Self-defined functions
# -----------------------
augroup remove_trailing_whitespaces
    autocmd!
    autocmd BufWritePre * if !&binary
                \ | myfunctions.TrimWhitespace() |
                \ endif
augroup END



# git add -u && git commit -m "."
command! GitCommitDot myfunctions.CommitDot()
command! GitPushDot myfunctions.PushDot()
# Merge and diff
command! -nargs=? Diff myfunctions.Diff(<q-args>)
nnoremap dn ]c
nnoremap dN [c


# Change all the terminal directories when you change vim directory
def ChangeTerminalDir()
    for ii in term_list()
        if bufname(ii) == "JULIA"
            term_sendkeys(ii, 'cd("' .. getcwd() .. '")' .. "\n")
        else
            term_sendkeys(ii, "cd " .. getcwd() .. "\n")
        endif
    endfor
enddef


# Manim commands
command ManimDocs silent :!open -a safari.app
            \ ~/Documents/github/manim/docs/build/html/index.html
command ManimNew :enew | :0read ~/.manim/new_manim.txt
command ManimHelpVMobjs :HelpMe ~/.vim/helpme_files/manim_vmobjects.txt
command ManimHelpTex :HelpMe ~/.vim/helpme_files/manim_tex.txt
command ManimHelpUpdaters :HelpMe ~/.vim/helpme_files/manim_updaters.txt
command ManimHelpTransform :HelpMe ~/.vim/helpme_files/manim_transform.txt
