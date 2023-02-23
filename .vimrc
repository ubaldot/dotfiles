vim9script
# Some good VIM notes
# ======================
# #.# used for concatenating 
# au = autocmd. au! clean up the command list connected to an event
# def! override if a function name is already defined. 
# :h whatever is your friend
# Learn Vim the hard way is a great book
#
# Variables in namespace (i.e. starting with g:, b:, etc.)
# should not be declared (i.e. no var b:git_branch, but b:git_branch) 
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

if has("gui_win32")
    g:shell = "powershell"
    g:dotvim = $HOME."\\vimfiles"
    g:conda_env = trim(system("echo %CONDA_DEFAULT_ENV%"))
    # The following is very slow
    #set shell="C:\\\\link\\\\to\\\\Anaconda\\\\powershell.exe"
    #set shellcmdflag=-command
elseif has("mac")
    set shell=zsh # to be able to source ~/.zshrc (conda init)
    g:shell = "zsh"
    g:dotvim = $HOME .. "/.vim"
    g:conda_env = trim(system("echo $CONDA_DEFAULT_ENV"))
endif
#
# Terminal not in the buffer list
# autocmd TerminalOpen * if bufwinnr('') > 0 | setlocal nobuflisted | endif
#
# =====================================================
# Some key bindings
# =====================================================
# Remap <leader> key
g:mapleader = ","
nnoremap <leader>w :bp<cr>:bw! #<cr>
nnoremap <leader>b :ls!<CR>:b
# nnoremap <leader>d :bp<cr>:bd #<cr> 
nnoremap <leader>c :close<cr>
noremap <c-left> :bprev<CR>
noremap <c-right> :bnext<CR>
noremap <c-PageDown> :bprev<CR>
noremap <c-PageUp> :bnext<CR>
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j
# Enable folding with the spacebar
nnoremap <space> za

# Open and close brackets automatically. OBS! set paste must not be set.
#"inoremap ( ()h
#"inoremap [ []h
#"inoremap { {}h
#"inoremap {<CR> {<CR>}<ESC>O
#"inoremap {;<CR> {<CR>};<ESC>O
#"inoremap " ""h
#"inoremap ' ''h
# to be able to undo accidental c-w"
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
# Automatically surround highlighted selection
xnoremap ( <ESC>`>a)<ESC>`<i(<ESC>
xnoremap [ <ESC>`>a]<ESC>`<i[<ESC>
xnoremap { <ESC>`>a}<ESC>`<i{<ESC>
# xnoremap " <ESC>`>a"<ESC>`<i"<ESC>
# Indent without leaving the cursor position 
nnoremap g= :var b:PlugView=winsaveview()<CR>gg=G: winrestview(b:PlugView) <CR>:echo "file indented"<CR>

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


#Open terminal below all splits
exe "cabbrev bter bo terminal " .. g:shell
exe "cabbrev vter vert botright terminal " .. g:shell


# =====================================================
# netrw setting to be similar to NERDTree
# =====================================================
# " gh to toggle hidden files view
# var g:netrw_banner = 0
# var g:netrw_liststyle = 3
# var g:netrw_browse_split = 4
# var g:netrw_altv = 1
# var g:netrw_winsize = 25
# var g:netrw_hide = 1
# noremap <silent> <F2> :Lexplore<cr>
# 
# Stuff to be run before loading plugins
# Use the internal autocompletion (no deoplete, no asyncomplete plugins)
g:ale_completion_enabled = 1
g:ale_completion_autoimport = 1
#Omnifunc is kinda disabled so I don't have to hit <c-x><c-o> for getting
#suggestions
# set omnifunc=ale#completion#OmniFunc
#set omnifunc=syntaxcomplete#Complete
#let g:ale_disable_lsp = 1


# ============================================
# Plugins  manager
# ============================================
filetype off                  # required
# Vundle plugin manager
#set the runtime path to include Vundle and initialize
exe 'set rtp+=' .. g:dotvim .. "/bundle/Vundle.vim"
vundle#begin(g:dotvim .. "/bundle")
Plugin 'gmarik/Vundle.vim'
Plugin 'sainnhe/everforest'
Plugin 'dense-analysis/ale'
Plugin 'preservim/nerdtree'
Plugin 'machakann/vim-highlightedyank'
# Plugin 'ludovicchabant/vim-gutentags'
Plugin 'liuchengxu/vista.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'leftbones/helpme-vim'
vundle#end()            # required
filetype plugin indent on    # required for Vundle

# ============================================
# Plugins settings
# ============================================
# Helpme
source $HOME/.vim/helpme.vim 
source $HOME/.vim/redir.vim 

# everforest colorscheme
colorscheme everforest
var hour = str2nr(strftime("%H"))
if hour < 6 || 15 < hour 
    set background=dark
    g:airline_theme = 'dark'
endif 

nnoremap <F1> :NERDTreeToggle<cr>
augroup DIRCHANGE
    au!
    autocmd DirChanged global NERDTreeCWD
    autocmd DirChanged global ChangeTerminalDir()
augroup END
# Close NERDTree when opening a file#
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
au User AirlineAfterInit #:g:airline_section_x = airline#section#create(['(%{g:conda_env})
au User AirlineAfterInit g:airline_section_x = airline#section#create([g:conda_env])
g:airline_extensions = ['ale', 'tabline']


# ALE 
# If you want clangd as LSP add it to the linter list.
nnoremap <silent> <leader>k <Plug>(ale_previous_wrap)
nnoremap <silent> <leader>j <Plug>(ale_next_wrap)
nnoremap <silent> <leader>h <Plug>(ale_hover)
nnoremap <c-]> :ALEGoToDefinition<cr>
g:ale_linters = {
            'c': ['clangd', 'cppcheck', 'gcc'],
            'python': ['flake8', 'pylsp', 'mypy']} 
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

# Source additional files
# source $HOME/PE.vim
# source $HOME/VAS.vim
# source $HOME/dymoval.vim

syntax on


# Commenting blocks of code.
# augroup commenting_blocks_of_code
#     autocmd!
#     autocmd FileType c,cpp,java,scala var b:comment_leader = '// '
#     autocmd FileType sh,ruby,python   var b:comment_leader = '# '
#     autocmd FileType conf,fstab       var b:comment_leader = '# '
#     autocmd FileType tex              var b:comment_leader = '% '
#     autocmd FileType mail             var b:comment_leader = '> '
#     autocmd FileType vim              var b:comment_leader = '" '
# augroup END
# # To be modified
# noremap <silent> <c-1> :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
# nemap <silent> <c-2> :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>
#

# ============================================
# Self-defined functions
# ============================================
# Remove trailing white spaces
autocmd! BufWritePre * :%s/\s+$//e
# Get git branch name for airline. OBS !It may need to be changed for other OS.
def Gitbranch(): string
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
    autocmd BufEnter * b:git_branch = Gitbranch()
augroup END


# Some useful functions
# change all the terminal directories when you change vim directory 
def ChangeTerminalDir()
    for ii in term_list()
         term_sendkeys(ii, "cd " .. getcwd() .. "\n")
    endfor
enddef

# Commit dot message
def GitCommit()
    exe "silent !git add -u &&  git commit -m '.'"
enddef

# =====================================================
# My own REPL
# =====================================================
def g:Repl(repl_type: string, repl_name: string)
    echo repl_name
    if repl_type == "terminal"
        exe "botright terminal " .. g:shell
    else
         term_start(repl_type, {'term_name': repl_name, 'vertical': v:true} )
    endif
enddef
#
def g:SendCell(repl_type: string, repl_name: string, delim: string)
    if !bufexists(repl_name)
         g:Repl(repl_type, repl_name)
        wincmd h
    endif
    # var is the syntax for using a variable in a function
    # In Normal mode, go to the next line
    norm! j
    # echo delim
    # In search n is for don't move the cursor, b is backwards and W to don't wrap
    # around
    var line_in = search(delim, 'nbW')
    # We use -1 because we want right-open intervals, i.e. [a,b). 
    # Note that here we want the cursor to move to the next cell!
    norm! k
    var line_out = search(delim, 'W') - 1
    if line_out == - 1
        line_out = line("$")
    endif
    # For debugging
    # echo [line_in, line_out]
     delete(fnameescape(g:filename))
    # getline() returns a list of lines
    writefile(getline(line_in + 1, line_out), g:filename, "a")
    #call term_sendkeys(term_list()[0],"run -i ". g:filename . "\n")
    # At startup, it is always terminal 2 or the name is hard-coded IPYTHON
    call term_sendkeys(repl_name, "run -i " .. g:filename .. "\n")
enddef
#
# Defaults for the REPL
# To add another language define the following b: 
# variables in such a language file in the ftplugin
# folder
g:repl_type_default = 'terminal'
g:repl_name_default = "TERMINAL"
g:cell_delimiter_default = "None"

##
if has("gui_win32")
    g:filename = $TMP .. "\\my_cell.tmp"
elseif has("mac")
    g:filename = expand("~/my_cell.tmp")
endif

# Define my own command
command REPL g:Repl(get(b:, 'repl_type', g:repl_type_default), get(b:, 'repl_name', g:repl_name_default))

# Some key-bindings for the REPL
nnoremap <F9> yy \| :call term_sendkeys(get(b:, 'repl_name', g:repl_name_default),@")<cr>j0
vnoremap <F9> y \| :call term_sendkeys(get(b:, 'repl_name', g:repl_name_default),@")<cr>j0
nnoremap <c-enter> \| :call g:SendCell(get(b:, 'repl_type', g:repl_type_default),get(b:, 'repl_name', g:repl_name_default), get(b:, 'cell_delimiter', g:cell_delimiter_default))<cr><cr>
# Clear REPL
nnoremap <c-c> :call term_sendkeys(get(b:, 'repl_name', g:repl_name_default),"\<c-l>")<cr>

# manim render
def g:Manim(scene: string)
    exe "silent !manim " .. shellescape(expand("%:t")) .. " " .. scene .. " -pql"
enddef


def g:ManimTerminal(scene: string)
    var cmd = "manim " .. expand("%:t") .. " " .. scene .. " -pql --disable_caching"
    var terms_name = []
    for ii in term_list()
        add(terms_name, bufname(ii))
    endfor
    echo terms_name
    if term_list() == [] || index(terms_name, 'MANIM') == -1
        botright term_start(g:current_terminal, {'term_name':
        'MANIM', 'term_rows': 10})
    endif
    term_sendkeys('MANIM', "\n" .. cmd .. "\n")
enddef
    

#     term_list() ..  
#     exe "vert terminal manim " .. expand("%:t") .. " " .. scene .. " -pql --disable_caching"
# enddef

command! -nargs=1 -complete=command Manim silent call Manim(<f-args>)
# command! -nargs=1 -complete=command ManimVerbose silent call ManimVerbose(<f-args>)
command! -nargs=1 -complete=command ManimTerminal silent call ManimTerminal(<f-args>)

# The following was a nice exercise but it may not be needed as we for the statusline we are
# just using trim(system("echo \%CONDA_DEFAULT_ENV\%").  
# Get conda virtual environment
# def Condaenv(env)
#    " You use 'call' in MS-DOS to delay a bit
#    return trim(system("conda activate ". env. " &&  echo %CONDA_DEFAULT_ENV%"))
# enddef
# 
# " Someone said that this def is called very often. 
# augroup Condaenvget
#     autocmd!
#     autocmd VimEnter * g:conda_env = Condaenv(g:conda_activate)
# augroup END
