vim9script
#=====================
# OBS! If using Python, you first need to
# activate a virtual environment and then you
# can open gvim from the shell of that virtual environment.
# If you open gvim and then you activate an environment,
# then things won't work!
# ==========================
#
#
# For auto-completion, jumps to definitions, etc
# you can either use ctags or LSP.
# gutentags automatically creates ctags as you open files
# so you don't need to create them manually.
# You need to activate vim omnicomplete though, which is disables
# by default and you should disable LSP
# Uncomment set omnifunc=... few lines below#
#
# :h user-manual is king.
#
# To activate myenv conda environment for MacVim
if has("mac")
    system("source ~/.zshrc")
endif

# Set python stuff
&pythonthreehome = fnamemodify(trim(system("which python")), ":h:h")
&pythonthreedll = trim(system("which python"))


augroup ReloadVimScripts
    autocmd!
    # autocmd BufWritePost $MYVIMRC source $MYVIMRC | echo ".vimrc reloaded"
    autocmd BufWritePost *.vim,*.vimrc,*.gvimrc exe "source %" # | echo
                \ expand('%:t') .. " reloaded."
augroup END
# Internal vim variables aka 'options'
set encoding=utf-8
set autoread
set number
# set relativenumber
set nowrap
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nobackup
set backspace=indent,eol,start
set nocompatible              # required
set clipboard=unnamed
set splitright
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
# set autoshelldir

if has("gui_win32") || has("win32")
    g:dotvim = $HOME .. "\\vimfiles"
    g:conda_env = trim(system("echo %CONDA_DEFAULT_ENV%"))
# The following is very slow
#set shell="C:\\\\link\\\\to\\\\Anaconda\\\\powershell.exe"
#set shellcmdflag=-command
else
    g:dotvim = $HOME .. "/.vim"
    g:conda_env = trim(system("echo $CONDA_DEFAULT_ENV"))
endif


# =====================================================
# Some key bindings
# =====================================================
# noremap <Up> <Nop>
# noremap <Down> <Nop>
# noremap <Left> <Nop>
# noremap <Right> <Nop>
# Remap <leader> key
g:mapleader = ","
map <leader>vr :source $MYVIMRC<CR> \| :echo ".vimrc reloaded."
map <leader>vv :e $MYVIMRC<CR>
# nnoremap d "_d
nnoremap <leader>w :bp<cr>:bw! #<cr>
nnoremap <leader>b :ls!<CR>:b
nnoremap <S-Tab> <Plug>Bufselect_Toggle
nnoremap <C-Tab> <Plug>(FileselectToggle)
# nnoremap <S-C-Tab> :bprevious<CR>
# nnoremap <leader>x :bnext<cr>
# nnoremap <leader>z :bprev<cr>
# nnoremap <leader>d :bp<cr>:bd #<cr>
nnoremap <leader>c :close<cr>
noremap <c-PageDown> :bprev<CR>
noremap <c-PageUp> :bnext<CR>
# Switch window
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j
# Switch window with arrows
nnoremap <c-Left> :wincmd h<cr>
nnoremap <c-Right> :wincmd l<cr>

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
# xnoremap " <ESC>`>a"<ESC>`<i"<ESC>
# Indent without leaving the cursor position
nnoremap g= :vim9cmd b:temp = winsaveview()<CR>gg=G
            \ :vim9cmd winrestview(b:temp)<cr>
            \ :vim9cmd unlet b:temp<cr>
            \ :echo "file indented"<CR>

# Format text
# nnoremap g- :execute 'g/^.\{' .. &textwidth ..'\}/normal gqq'<cr>:echo "file
#             \ formatted, textwidth: " .. &textwidth .. " cols."<cr>
nnoremap g- :vim9cmd b:temp = winsaveview()<CR>gggqG
            \ :vim9cmd winrestview(b:temp)<cr>
            \ :vim9cmd unlet b:temp<cr>
            \ :echo "file formatted, textwidth: "
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
# tnoremap <c-PageUp> <c-w>:bnext<CR>

# Open terminal below all windows
exe "cabbrev bter bo terminal " .. &shell
exe "cabbrev vter vert botright terminal " .. &shell

# ============================
# PLUGIN STUFF
# ============================
# Select which plugin to not load
# g:replica_loaded = 1


# Stuff to be run before loading plugins
# Use the internal autocompletion (no deoplete, no asyncomplete plugins)
g:ale_completion_enabled = 1
g:ale_completion_autoimport = 1
# Omnifunc is kinda disabled so I don't have to hit <c-x><c-o> for getting
# suggestions
# set omnifunc=ale#completion#OmniFunc
# set omnifunc=syntaxcomplete#Complete
# let g:ale_disable_lsp = 1


# ============================================
# Plugins  manager
# ============================================
plug#begin(g:dotvim .. "/plugins/")
Plug 'junegunn/vim-plug' # For getting the help, :h plug-options
Plug 'sainnhe/everforest'
Plug 'dense-analysis/ale'
Plug 'preservim/nerdtree'
Plug 'machakann/vim-highlightedyank'
Plug 'yegappan/bufselect'
Plug 'yegappan/fileselect'
# Plug 'ludovicchabant/vim-gutentags'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-scriptease'
Plug 'ubaldot/vim-helpme'
Plug 'ubaldot/vim-outline'
Plug 'ubaldot/vim-replica'
Plug 'vim-airline/vim-airline'
# Plug 'ryanoasis/vim-devicons'
plug#end()
# filetype plugin indent on
autocmd FileType nerdtree setlocal nolist
# ============================================
# Plugins settings
# ============================================

# everforest colorscheme
var hour = str2nr(strftime("%H"))
if hour < 6 || 21 < hour
    set background=dark
    # g:airline_theme = 'dark'
endif
colorscheme everforest
g:airline_theme = 'everforest'

nnoremap <F1> :NERDTreeToggle<cr>
augroup DIRCHANGE
    autocmd!
    autocmd DirChanged global NERDTreeCWD
    autocmd DirChanged global ChangeTerminalDir()
augroup END
# Close NERDTree when opening a file
g:NERDTreeQuitOnOpen = 1


# Vista!
# g:vista_close_on_jump = 1
# g:vista_default_executive = 'ale'
# def! g:NearestMethodOrFunction(): string
#     return get(b:, 'vista_nearest_method_or_def', '')
# enddef

# augroup FuncNameGet
#     autocmd!
#     autocmd VimEnter *  vista#RunForNearestMethodOrFunction()
# augroup END

# TODO: the following won't work
# import autoload g:dotvim .. "/plugins/vim-outline/lib/outline.vim"
# augroup OUTLINE
#     autocmd!
#     autocmd VimEnter * :call outline.RefreshWindow()
# augroup END
# # # import g:dotvim .. "/plugins/vim-outline/lib/outline.vim"
# # echo outline.RefreshWindow()
# call airline#parts#define_function('outl', 'RefreshWindow')

# vim-airline show buffers
g:airline#extensions#tabline#enabled = 1
g:airline#extensions#tabline#formatter = 'unique_tail'
g:airline#extensions#tabline#ignore_bufadd_pat =
    'defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'
# If mode()==t then change the statusline
au User AirlineAfterInit g:airline_section_a = airline#section#create(['
            \ %{b:git_branch}'])
au User AirlineAfterInit g:airline_section_b = airline#section#create(['%f'])
# au User AirlineAfterInit g:airline_section_c =
# airline#section#create(['f:%{NearestMethodOrFunction()}'])
# au User AirlineAfterInit g:airline_section_c =
# airline#section#create(['outl'])
au User AirlineAfterInit g:airline_section_z = airline#section#create(['col:
            \ %v'])
au User AirlineAfterInit g:airline_section_x =
            \ airline#section#create([g:conda_env])
g:airline_extensions = ['ale', 'tabline']


# ALE
# If you want clangd as LSP add it to the linter list.
g:ale_completion_max_suggestions = 1000
g:ale_floating_preview = 1
nnoremap <silent> <leader>p <Plug>(ale_previous_wrap)
nnoremap <silent> <leader>n <Plug>(ale_next_wrap)
nnoremap <silent> <leader>k <Plug>(ale_hover)
nnoremap <silent> <leader>r :ALEFindReferences<cr>
nnoremap <silent> <leader>g :ALEGoToDefinition<cr>


g:ale_linters = {
    'c': ['clangd', 'cppcheck', 'gcc'],
    'python': ['flake8', 'pylsp', 'mypy'],
    'tex': ['texlab', 'writegood'],
    'text': ['writegood']}
# You must change the following line if you change LaTeX project folder
g:ale_lsp_root = {'texlab': '~'}

g:ale_echo_msg_error_str = 'E'
g:ale_echo_msg_warning_str = 'W'
g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
g:ale_c_clangtidy_checks = ['*']
g:ale_python_flake8_options = '--ignore=E501,W503'
# g:ale_python_pyright_config = {
#             .. 'pyright': {
#             ..   "extraPaths": "C:/VAS/github/dymoval",
#             .. },
#             .. }

# I don't remember how to set the following
g:ale_python_pylsp_config = {
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


# ALE Fixers
g:ale_fixers = {
    'c': ['clang-format', 'remove_trailing_lines',
        'trim_whitespace'],
    'cpp': ['clang-format'],
    'python': ['remove_trailing_lines', 'trim_whitespace',
        'autoflake', 'black']}

g:ale_python_autoflake_options = '--in-place --remove-unused-variables
            \ --remove-all-unused-imports'
g:ale_python_black_options = '--line-length=80'
g:ale_fix_on_save = 1


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

# Utils commands

# This command definition includes -bar, so that it is possible to "chain" Vim commands.
# Side effect: double quotes can't be used in external commands
command! -nargs=1 -complete=command -bar -range Redir silent call Redir(<q-args>, <range>, <line1>, <line2>)

# This command definition doesn't include -bar, so that it is possible to use double quotes in external commands.
# Side effect: Vim commands can't be "chained".
command! -nargs=1 -complete=command -range Redir silent call Redir(<q-args>, <range>, <line1>, <line2>)

# Source additional files
# source $HOME/PE.vim
# source $HOME/VAS.vim
# source $HOME/dymoval.vim

# sci-vim-repl stuff
# g:replica_console_position = "R"
# g:replica_console_width = 30
# g:outline_autoclose = false

syntax on


# ============================================
# Self-defined functions
# ============================================

augroup remove_trailing_whitespaces
    autocmd!
    autocmd BufWritePre * if !&binary
                \ | :call myfunctions#TrimWhitespace() |
                \ endif
augroup END


# Get git branch name for airline. OBS !It may need to be changed for other
# OS.
def Get_gitbranch(): string
    var current_branch = trim(system("git -C " .. expand("%:h") .. " branch
                \ --show-current"))
    # strdix(A,B) >=0 check if B is in A.
    if stridx(current_branch, "not a git repository") >= 0
        current_branch = "(no repo)"
    endif
    return current_branch
enddef

# TODO: test with two files on different repo on different branches
augroup Gitget
    autocmd!
    autocmd BufEnter,BufWinEnter * b:git_branch = Get_gitbranch()
augroup END

# git add -u && git commit -m "."
command! GitCommitDot :call myfunctions#CommitDot()
command! GitPushDot :call myfunctions#PushDot()
# Merge and diff
command! -nargs=? Diff :call myfunctions#Diff(<q-args>)
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
