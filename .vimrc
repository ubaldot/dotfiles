vim9script

if has("win64") || has("win32") || has("win16")
    g:os = "Windows"
else
    g:os = substitute(system('uname'), '\n', '', '')
endif

if g:os == "Windows"
    g:tmp = "C:/temp"
    g:null_device = "NUL"
    g:dotvim = $HOME .. "/vimfiles"
else
    g:tmp = "/tmp"
    g:null_device = "/dev/null"
    g:dotvim = $HOME .. "/.vim"
    # &pythonthreehome = fnamemodify(trim(system("which python")), ":h:h")
    # &pythonthreedll = trim(system("which python"))
endif

# Linux/BSD
if executable('cmd.exe')
    g:start_cmd = "explorer.exe"
elseif executable("xdg-open")
    g:start_cmd = "xdg-open"
# MacOS
elseif executable("open")
    g:start_cmd = "open"
endif

import g:dotvim .. "/lib/myfunctions.vim"

# Set cursor
&t_SI = "\e[6 q"
&t_EI = "\e[2 q"

# augroup ReloadVimScripts
#     autocmd!
#     autocmd BufWritePost *.vim,*.vimrc,*.gvimrc {
#         exe "source %"
#         echo expand('%:t') .. " reloaded."
#     }
# augroup END

# For plugin writing
# augroup CommandWindowOpen
#     autocmd!
#     autocmd CmdwinEnter * map <buffer> <cr> <cr>q:
# augroup END

# Open help pages in vertical split
augroup vimrc_help
    autocmd!
    autocmd BufEnter *.txt if &buftype == 'help' | wincmd H | endif
augroup END

# Internal vim variables aka 'options'
# Set terminal with 256 colors
set encoding=utf-8
set belloff=all
if has("Linux")
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif
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
set wildcharm=<tab>
# TODO adjust path option. Move to after/ftplugin
# set path+=**
# set cursorline

# Some key bindings
# ----------------------
g:mapleader = ","
map <leader>vr <Cmd>source $MYVIMRC<cr> \| <Cmd>echo ".vimrc reloaded."
map <leader>vv <Cmd>e $MYVIMRC<cr>

# For using up and down in popup menu
# inoremap <expr><Down> pumvisible() ? "\<C-n>" : "\<Down>"
# inoremap <expr><Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <cr> pumvisible() ? "\<C-Y>" : "\<cr>"

# Remap command-line stuff
cnoremap <c-p> <up>
cnoremap <c-n> <down>

nnoremap <c-å> <c-]>
# Avoid polluting registers
nnoremap x "_x
# Opposite of J, i.e. split from current cursor position
nnoremap S i<cr><esc>
# <ScriptCmd> allows remapping to functions without the need of defining
# them as g:.
nnoremap <c-w>q <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <c-w><c-q> <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <leader>b <Cmd>ls!<cr>:b
nnoremap <s-tab> <cmd>bprev <cr>
nnoremap <c-tab> :b <tab>
nnoremap <tab> <Cmd>bnext<cr>
nnoremap Y y$
noremap <c-PageDown> <Cmd>bprev<cr>
noremap <c-PageUp> <Cmd>bnext<cr>
# Switch window
nnoremap <c-h> <c-w>h
nnoremap <c-down> <c-e>
nnoremap <c-up> <c-y>
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j

# super quick search and replace:
# nnoremap <Space><Space> :%s/\<<C-r>=expand("<cword>")<cr>\>/
# to be able to undo accidental c-w"
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

# Terminal stuff
# --------------
# Some terminal remapping when terminal is in buffer (no popup)
# When using iPython to avoid that shift space gives 32;2u
tnoremap <S-space> <space>
tnoremap <ESC> <c-w>N
tnoremap <c-h> <c-w>h
tnoremap <c-l> <c-w>l
tnoremap <c-k> <c-w>k
tnoremap <c-j> <c-w>j
# tnoremap <s-tab> <cmd>bnext<cr>
tnoremap <s-tab> <c-w>:b <tab>

tnoremap <c-w>q <ScriptCmd>myfunctions.Quit_term_popup(true)<cr>
tnoremap <c-w>c <ScriptCmd>myfunctions.Quit_term_popup(false)<cr>

nnoremap <c-t> <ScriptCmd>myfunctions.OpenMyTerminal()<cr>
tnoremap <c-t> <ScriptCmd>myfunctions.HideMyTerminal()<cr>

command! Terminal myfunctions.OpenMyTerminal()
# Open terminal below all windows
if g:os == "Windows"
    exe "cabbrev bter bo terminal powershell"
else
    exe "cabbrev vter vert botright terminal " .. &shell
endif

augroup DIRCHANGE
    autocmd!
    autocmd DirChanged global myfunctions.ChangeTerminalDir()
augroup END

augroup shoutoff_terminals
    autocmd QuitPre * call myfunctions.WipeoutTerminals()
augroup END

# vim-plug
# ----------------
plug#begin(g:dotvim .. "/plugins/")
Plug 'junegunn/vim-plug' # For getting the help, :h plug-options
Plug 'sainnhe/everforest'
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'yegappan/lsp'
# TODO enable plugin when matchbufline becomes available
Plug 'tpope/vim-commentary'
Plug 'ubaldot/vim-highlight-yanked'
Plug 'ubaldot/vim-helpme'
Plug 'ubaldot/vim-outline'
Plug 'ubaldot/vim-replica'
Plug 'ubaldot/vim-manim'
# Plug 'ubaldot/vim-conda-activate'
Plug 'girishji/easyjump.vim'
Plug 'Konfekt/vim-compilers'
Plug 'puremourning/vimspector'
plug#end()
# filetype plugin indent on
syntax on

# Conda activate at startup
# augroup CondaActivate
#     autocmd!
#     autocmd VimEnter * :CondaActivate myenv
# augroup END

# Plugins settings
# -----------------
# everforest colorscheme
var hour = str2nr(strftime("%H"))
if hour < 7 || 16 < hour
    set background=dark
else
    set background=light
endif
g:everforest_background = 'medium'
colorscheme everforest

 # Plugin settings
exe "source " .. g:dotvim .. "/plugins_settings/txtfmt_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/statusline_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/bufline_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/fern_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/lsp_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/termdebug_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/vimspector_settings.vim"

# Open plugin settings
nnoremap <leader>f <ScriptCmd>myfunctions.OpenFileSpecial('"')<cr>

# vim-manim setup
var manim_common_flags = '--fps 30 --disable_caching -v WARNING --save_sections'
g:manim_flags = {'low_quality': $"-pql {manim_common_flags}",
    'high_quality': $"-pqh -c ~/Documents/YouTube/ControlTheoryInPractice/github_ctip/ctip_manim.cfg {manim_common_flags}",
    'dry_run': $'--dry_run {manim_common_flags}',
    'transparent': $"-pqh -c ~/Documents/YouTube/ControlTheoryInPractice/github_ctip/ctip_manim.cfg {manim_common_flags} --transparent"}
g:manim_default_flag = keys(g:manim_flags)[-1]

if g:os == "Darwin"
    augroup CloseQuickTime
        autocmd!
        autocmd! User ManimPre exe "!osascript ~/QuickTimeClose.scpt"
    augroup END
endif

# Manim commands
# To make docs go to manim/docs and run make html. Be sure that all the sphinx
# extensions packages are installed.
# TODO Make it working with Windows

# command ManimDocs silent :!open -a safari.app
#             \ ~/Documents/manimce-latest/index.html

command ManimNew :enew | :0read ~/.manim/new_manim.txt
command ManimHelpVMobjs exe "HelpMe " .. g:dotvim ..  "/helpme_files/manim_vmobjects.txt"
command ManimHelpTex exe "HelpMe " .. g:dotvim ..  "/helpme_files/manim_tex.txt"
command ManimHelpUpdaters exe "HelpMe " .. g:dotvim ..  "/helpme_files/manim_updaters.txt"
command ManimHelpTransform exe "HelpMe " .. g:dotvim .. "/helpme_files/manim_transform.txt"


# HelpMe files for my poor memory
command! HelpmeBasic exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_basic.txt"
command! HelpmeScript exe "HelpMe ".. g:dotvim .. "/helpme_files/vim_scripting.txt"
command! HelpmeGlobal exe "HelpMe ".. g:dotvim .. "/helpme_files/vim_global.txt"
command! HelpmeExCommands exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_excommands.txt"
command! HelpmeSubstitute exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_substitute.txt"
command! HelpmeAdvanced exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_advanced.txt"
command! HelpmeDiffMerge exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_merge_diff.txt"
command! HelpmeCoding exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_coding.txt"
command! HelpmeClosures exe "HelpMe " .. g:dotvim .. "/helpme_files/python_closures.txt"
command! HelpmeDebug exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_debug.txt"
command! HelpmeVimspector exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_vimspector.txt"

# vim-replica stuff
# ----------------------------------
g:replica_console_position = "L"
g:replica_display_range  = false
# g:replica_python_options = "-Xfrozen_modules=off"
g:replica_jupyter_console_options = {"python":
            \ " --config ~/.jupyter/jupyter_console_config.py"}

# g:writegood_compiler = "vale"
# g:writegood_options = "--config=$HOME/vale.ini"

# Outline. <F8> is overriden by vimspector
nnoremap <silent> <F8> <Plug>OutlineToggle


# Bunch of commands
# -----------------------
augroup remove_trailing_whitespaces
    autocmd!
    autocmd BufWritePre * {
        if !&binary
            myfunctions.TrimWhitespace()
        endif
    }
augroup END

# git add -u && git commit -m "."
command! GitCommitDot myfunctions.CommitDot()
command! GitPushDot myfunctions.PushDot()
# Merge and diff
command! -nargs=? Diff myfunctions.Diff(<q-args>)
nnoremap dn ]c
nnoremap dN [c

command! ColorsToggle myfunctions.ColorsToggle()

# Utils commands
command! -nargs=1 -complete=command -range Redir
            \ silent myfunctions.Redir(<q-args>, <range>, <line1>, <line2>)

# Example: :HH 62, execute the 62 element of :history
command! -nargs=1 HH execute histget("cmd", <args>)
# vip = visual inside paragraph
# This is used for preparing a text file for the caption to be sent to
# YouTube.
command! JoinParagraphs v/^$/norm! vipJ
