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

# To activate myenv conda environment for MacVim
if has("mac")
     system("source ~/.zshrc")
     g:current_terminal = 'zsh'
else
     g:current_terminal = 'powershell'
endif

# Internal vim variables
set encoding=utf-8
set autoread
set nu
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nobackup
set backspace=indent,eol,start
set nocompatible              # required
set clipboard=unnamed
set splitright
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
set textwidth=180

if has("gui_win32")
    g:dotvim = $HOME."\\vimfiles"
    g:conda_env = trim(system("echo %CONDA_DEFAULT_ENV%"))
    # The following is very slow
    #set shell="C:\\\\link\\\\to\\\\Anaconda\\\\powershell.exe"
    #set shellcmdflag=-command
elseif has("mac")
    set shell=zsh # to be able to source ~/.zshrc (conda init)
    g:dotvim = $HOME .. "/.vim"
    g:conda_env = trim(system("echo $CONDA_DEFAULT_ENV"))
endif


# =====================================================
# Some key bindings
# =====================================================
# Remap <leader> key
g:mapleader = ","
nnoremap <leader>w :bp<cr>:bw! #<cr>
nnoremap <leader>b :ls!<CR>:b
# nnoremap <leader>d :bp<cr>:bd #<cr>
nnoremap <leader>d :close<cr>
noremap <c-PageDown> :bprev<CR>
noremap <c-PageUp> :bnext<CR>
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j
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
nnoremap <leader>= :var b:PlugView=winsaveview()<CR>gg=G: winrestview(b:PlugView) <CR>:echo "file indented"<CR>

# Some terminal remapping
# When using iPython to avoid that shift space gives 32;2u
tnoremap <S-space> <space>
tnoremap <ESC> <c-w>N
tnoremap <c-h> <c-w>h
tnoremap <c-l> <c-w>l
tnoremap <c-k> <c-w>k
tnoremap <c-j> <c-w>j
tnoremap <c-PageDown> <c-w>:bprev<CR>
tnoremap <c-PageUp> <c-w>:bnext<CR>


# Open terminal below all windows
exe "cabbrev bter bo terminal " .. g:current_terminal
exe "cabbrev vter vert botright terminal " .. g:current_terminal


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
filetype off                  # required
# !Vundle plugin manager
# set the runtime path to include Vundle and initialize
exe 'set rtp+=' .. g:dotvim .. "/pack/bundle/start/Vundle.vim"
vundle#begin(g:dotvim .. "/pack/bundle/start")
Plugin 'gmarik/Vundle.vim'
Plugin 'sainnhe/everforest'
Plugin 'dense-analysis/ale'
Plugin 'preservim/nerdtree'
Plugin 'machakann/vim-highlightedyank'
# Plugin 'ludovicchabant/vim-gutentags'
Plugin 'liuchengxu/vista.vim'
Plugin 'tpope/vim-commentary'
Plugin 'ubaldot/helpme-vim'
Plugin 'ubaldot/ugly-vim-repl'
Plugin 'vim-airline/vim-airline'
vundle#end()            # required
filetype plugin indent on    # required for Vundle

# ============================================
# Plugins settings
# ============================================

# everforest colorscheme
colorscheme everforest
var hour = str2nr(strftime("%H"))
if hour < 6 || 18 < hour
    set background=dark
    g:airline_theme = 'dark'
endif

nnoremap <F1> :NERDTreeToggle<cr>
augroup DIRCHANGE
    au!
    autocmd DirChanged global NERDTreeCWD
    autocmd DirChanged global ChangeTerminalDir()
augroup END
# Close NERDTree when opening a file
g:NERDTreeQuitOnOpen = 1


# Vista!
g:vista_close_on_jump = 1
g:vista_default_executive = 'ale'
def! g:NearestMethodOrFunction(): string
    return get(b:, 'vista_nearest_method_or_def', '')
enddef

augroup FuncNameGet
    autocmd!
    autocmd VimEnter *  vista#RunForNearestMethodOrFunction()
augroup END

# Vista for showing outline
silent! map <F8> :Vista!!<CR>

# vim-airline show buffers
g:airline#extensions#tabline#enabled = 1
g:airline#extensions#tabline#formatter = 'unique_tail'
g:airline#extensions#tabline#ignore_bufadd_pat = 'defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'
# If mode()==t then change the statusline
au User AirlineAfterInit g:airline_section_a = airline#section#create([' %{b:git_branch}'])
au User AirlineAfterInit g:airline_section_b = airline#section#create(['%f'])
au User AirlineAfterInit g:airline_section_c = airline#section#create(['f:%{NearestMethodOrFunction()}'])
au User AirlineAfterInit g:airline_section_z = airline#section#create(['col: %v'])
au User AirlineAfterInit g:airline_section_x = airline#section#create([g:conda_env])
g:airline_extensions = ['ale', 'tabline']


# ALE
# If you want clangd as LSP add it to the linter list.
g:ale_completion_max_suggestions = 1000
g:ale_floating_preview = 1
nnoremap <silent> <leader>p <Plug>(ale_previous_wrap)
nnoremap <silent> <leader>n <Plug>(ale_next_wrap)
nnoremap <silent> <leader>h <Plug>(ale_hover)
nnoremap <c-]> :ALEGoToDefinition<cr>
nnoremap <leader>r :ALEFindReferences<cr>
g:ale_linters = {
            'c': ['clangd', 'cppcheck', 'gcc'],
            'python': ['flake8', 'pylsp', 'mypy'],
            'tex': ['texlab']}
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
             'c': ['clang-format', 'remove_trailing_lines', 'trim_whitespace'],
             'cpp': ['clang-format'],
             'python': ['remove_trailing_lines', 'trim_whitespace', 'autoflake', 'black']}

g:ale_python_autoflake_options = '--in-place --remove-unused-variables --remove-all-unused-imports'
g:ale_python_black_options = '--line-length=80'
g:ale_fix_on_save = 1

# Commentary
xmap <leader>c  <Plug>Commentary
nmap <leader>c  <Plug>Commentary
omap <leader>c  <Plug>Commentary
nmap <leader>cc <Plug>CommentaryLine
nmap <leader>cu <Plug>Commentary<Plug>Commentary

# HelpMe files for my poor memory
command! VimHelpBasic :HelpMe ~/.vim/helpme_files/vim_basic.txt
command! VimHelpCoding :HelpMe ~/.vim/helpme_files/vim_coding.txt
command! VimHelpVimGlobal :HelpMe ~/.vim/helpme_files/vim_global.txt
command! VimHelpExCommands :HelpMe ~/.vim/helpme_files/vim_excommands.txt
command! VimHelpSubstitute :HelpMe ~/.vim/helpme_files/vim_substitute.txt
command! VimHelpAdvanced :HelpMe ~/.vim/helpme_files/vim_advanced.txt

# Source additional files
# source $HOME/PE.vim
# source $HOME/VAS.vim
# source $HOME/dymoval.vim

syntax on

# ============================================
# Self-defined functions
# ============================================

augroup remove_trailing_whitespaces
    autocmd!
    autocmd BufWritePre * if !&binary | :call myfunctions#TrimWhitespace() | endif
augroup END


# Get git branch name for airline. OBS !It may need to be changed for other OS.
def Get_gitbranch(): string
    var current_branch = trim(system("git -C " .. expand("%:h") .. " branch --show-current"))
    # Not very robust though
    if current_branch =~ "not a git repository"
        return "(no repo)"
    else
        return current_branch
    endif
enddef

augroup Gitget
    autocmd!
    autocmd BufEnter * b:git_branch = Get_gitbranch()
augroup END

# git add -u && git commit -m "."
command! GitCommitDot :call myfunctions#CommitDot()

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


# HelpMe! basic
command! -nargs=? -complete=file HelpMe call <sid>HelpMePopup(<f-args>)

# Manim user-defined commands
command! -nargs=+ -complete=command Manim silent call myfunctions#Manim(<f-args>, false)
command! -nargs=+ -complete=command ManimDry silent call myfunctions#Manim(<f-args>, true)
command! -nargs=+ -complete=command ManimTerminal silent call myfunctions#ManimTerminal(<f-args>, false)
command! -nargs=+ -complete=command ManimTerminalDry silent call myfunctions#ManimTerminal(<f-args>, true)
command! ManimDocs silent :!open -a safari.app ~/Documents/github/manim/docs/build/html/index.html
command! ManimNew :enew | :0read ~/.manim/new_manim.txt
command! ManimHelpVMobjs :HelpMe ~/.vim/helpme_files/manim_vmobjects.txt
command! ManimHelpTex :HelpMe ~/.vim/helpme_files/manim_tex.txt
command! ManimHelpUpdaters :HelpMe ~/.vim/helpme_files/manim_updaters.txt
command! ManimHelpTransform :HelpMe ~/.vim/helpme_files/manim_transform.txt
