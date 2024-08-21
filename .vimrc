vim9script

if has("win64") || has("win32") || has("win16")
  g:os = "Windows"
else
  g:os = substitute(system('uname'), '\n', '', '')
endif

if g:os == "Windows" || g:os =~ "^MINGW64"
  g:tmp = "C:/temp"
  g:null_device = "NUL"
  g:dotvim = $HOME .. "\\vimfiles"
  # source $VIMRUNTIME/mswin.vim
  # For mingw64
  set runtimepath+=C:/Users/yt75534/vimfiles
else
  g:tmp = "/tmp"
  g:null_device = "/dev/null"
  g:dotvim = $HOME .. "/.vim"
  &pythonthreehome = fnamemodify(trim(system("which python")), ":h:h")
  if g:os == 'Linux'
    &pythonthreedll = $'{&pythonthreehome}/lib/libpython3.12.so'
  else
    &pythonthreedll = $'{&pythonthreehome}/lib/libpython3.11.dylib'
  endif
endif

# Windows
if executable('cmd.exe')
  g:start_cmd = "explorer.exe"
# Linux/BSD
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

augroup ReloadVimScripts
  autocmd!
  autocmd BufWritePost *.vim,*.vimrc,*.gvimrc {
    exe "source %"
    echo expand('%:t') .. " reloaded."
  }
augroup END

# ---- Activate the following autocmd only during plugin writing -----
# For plugin writing
# augroup CommandWindowOpen
#     autocmd!
#     autocmd CmdwinEnter * map <buffer> <cr> <cr>q:
# augroup END


# augroup Vim9AutoCmdLine
#     autocmd!
#     autocmd CmdlineEnter : setcmdline('vim9cmd ')
# augroup END
# -------------------------------------------

# Open help pages in vertical split
augroup vimrc_help
  autocmd!
  autocmd BufEnter *.txt if &buftype == 'help' | wincmd H | endif
augroup END

# Internal vim variables aka 'options'
# Set terminal with 256 colors
set scrolloff=8
set encoding=utf-8
set langmenu=en_US.UTF-8
# set langmap=ö[,ä]
set belloff=all
set clipboard^=unnamed,unnamedplus
set termguicolors
set autoread
set number
set nowrap
set tabstop=2 softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set nobackup
set backspace=indent,eol,start
set nocompatible              # required
set splitright
set splitbelow
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
set conceallevel=2
set concealcursor=nvc
# TODO adjust path option. Move to after/ftplugin
# set path+=**
# set cursorline

# Some key bindings
# ----------------------
map <f1> <cmd>helpclose<cr>
# map! <f1> <nop>
g:mapleader = ","
map <leader>vr <Cmd>source $MYVIMRC<cr> \| <Cmd>echo ".vimrc reloaded."
map <leader>vv <Cmd>e $MYVIMRC<cr>
inoremap å `


# For using up and down in popup menu
# inoremap <expr><Down> pumvisible() ? "\<C-n>" : "\<Down>"
# inoremap <expr><Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <cr> pumvisible() ? "\<C-Y>" : "\<cr>"
# inoremap kj <esc>

# Remap {['command-line']} stuff
cnoremap <c-p> <up>
cnoremap <c-n> <down>

xnoremap " <esc><ScriptCmd>myfunctions.Surround('"', '"')<cr>
xnoremap ' <esc><ScriptCmd>myfunctions.Surround("'", "'")<cr>
xnoremap ( <esc><ScriptCmd>myfunctions.Surround('(', ')')<cr>
xnoremap [ <esc><ScriptCmd>myfunctions.Surround('[', ']')<cr>
xnoremap { <esc><ScriptCmd>myfunctions.Surround('{', '}')<cr>

# TODO: does not work with macos
# adjustment for Swedish keyboard
nmap <c-ö> <c-[>
nmap <c-ä> <c-]>
# Avoid polluting registers
nnoremap x "_x
noremap cd <cmd>exe "cd %:p:h"<cr>
# Opposite of J, i.e. split from current cursor position
nnoremap S i<cr><esc>
# <ScriptCmd> allows remapping to functions without the need of defining
# them as g:.
nnoremap <c-w>q <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <c-w><c-q> <ScriptCmd>myfunctions.QuitWindow()<cr>
# nnoremap <leader>b <Cmd>ls!<cr>:b
nnoremap <s-tab> <cmd>bprev <cr>
nnoremap <c-tab> :b <tab>
nnoremap <leader>b :b <tab>
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

# Wipe buffer
nnoremap <c-b><c-w> <cmd>bw!<cr>
# nnoremap bw <cmd>bw!<cr>

nnoremap g= <ScriptCmd>myfunctions.FormatWithoutMoving()<cr>

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
Plug 'lifepillar/vim-solarized8'
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'yegappan/lsp'
Plug 'ubaldot/vim-highlight-yanked'
Plug 'ubaldot/vim-open-recent'
Plug 'ubaldot/vim-helpme'
Plug 'ubaldot/vim-outline'
Plug 'ubaldot/vim-replica'
Plug 'ubaldot/vim-manim'
Plug 'ubaldot/vim-microdebugger'
Plug 'ubaldot/vim9-conversion-aid'
# Plug 'ubaldot/vim-conda-activate'
Plug 'girishji/easyjump.vim'
# Plug 'Donaldttt/fuzzyy'
Plug 'ubaldot/fuzzyy'
Plug 'Konfekt/vim-compilers'
Plug 'puremourning/vimspector'
plug#end()
# filetype plugin indent on
syntax on

# Bundled plugins
packadd comment
packadd! termdebug

augroup SetHeadersAsCfiletype
  autocmd!
  autocmd BufRead,BufNewFile *.h set filetype=c
augroup END
# Conda activate at startup
# augroup CondaActivate
#     autocmd!
#     autocmd VimEnter * :CondaActivate myenv
# augroup END

# Plugins settings
# -----------------
# everforest colorscheme
var hour = str2nr(strftime("%H"))
if hour < 7 || 17 < hour
  set background=dark
else
  set background=light
endif
# set background=dark
g:everforest_background = 'medium'
# colorscheme solarized8_flat
colorscheme everforest

# fuzzyy setup
g:enable_fuzzyy_keymaps = false
g:fuzzyy_dropdown = true
nnoremap <c-s>f <cmd>FuzzyFiles<cr>
nnoremap <c-s>w <cmd>FuzzyInBuffer<cr>
nnoremap <c-s>b <cmd>FuzzyBuffer<cr>
nnoremap <c-s>o <cmd>FuzzyMRUFiles<cr>
nnoremap <c-s>g <cmd>FuzzyGrep<cr>

# g:fuzzyy_window_layout = {
#   FuzzyFiles: { preview: false },
#   FuzzyMRUFiles: { preview: false }
# }

def ShowRecentFiles()
  var readable_args = copy(v:argv[1 : ])->filter((_, x) =>
         !empty(x) && filereadable(x)
        )
  if len(readable_args) == 0
    execute('FuzzyMRUFiles')
  endif
enddef

augroup OpenRecent
    autocmd!
    autocmd VimEnter * ShowRecentFiles()
augroup END

# augroup CHANGE_DIR
#   autocmd!
#   autocmd BufEnter * cd %:p:h
# augroup END

# Vim9-conversion-aid
g:vim9_conversion_aid_fix_let = true

# vim-open-recent
g:vim_open_change_dir = true
g:vim_open_at_empty_startup = false


# Plugin settings
# TODO: You may want to use a popup_create and pick
# Open plugin settings
var Open_special = (textobject) => {
  var filename = g:dotvim .. myfunctions.GetTextObject(textobject)
  if stridx(filename, "/plugins_settings/") != -1
    execute("edit " .. filename)
  else
    echo "Not a plugin settings path."
  endif
}

# exe "source " .. g:dotvim .. "/plugins_settings/txtfmt_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/statusline_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/bufline_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/fern_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/lsp_settings.vim"
# source "~/vim_official/vim/runtime/pack/dist/opt/comment/plugin/comment.vim"
g:termdebug_config = {}
exe "source " .. g:dotvim .. "/plugins_settings/microdebugger_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/vimspector_settings.vim"

# TODO; remove me
# exe "source ~/vim_official/vim/runtime/pack/dist/opt/termdebug/plugin/termdebug.vim"
# 'i"' is interpreted as 'inside "'
nnoremap <leader>z <ScriptCmd>Open_special('i"')<cr>

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
command! HelpmeUnitTests exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_unit_tests.txt"
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
nmap <silent> <c-enter> <Plug>ReplicaSendCell<cr>j
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
nnoremap <expr> gl &diff ? ':diffget LOCAL<CR>' : 'gl'
nnoremap <expr> gr &diff ? ':diffget REMOTE<CR>' : 'gr'
nnoremap <expr> gn &diff ? ']c' : 'gn'
nnoremap <expr> gp &diff ? '[c' : 'gp'
# nnoremap gn &diff ? 'lib.NextChange()' : 'gn'
# nnoremap gp &diff ? 'lib.PrevChange()' : 'gp'

command! ColorsToggle myfunctions.ColorsToggle()

# Utils commands
command! -nargs=1 -complete=command -range Redir
      \ silent myfunctions.Redir(<q-args>, <range>, <line1>, <line2>)

# Example: :HH 62, execute the 62 element of :history
command! -nargs=1 HH execute histget("cmd", <args>)

# vip = visual inside paragraph
# This is used for preparing a text file for the caption to be sent to
# YouTube.
