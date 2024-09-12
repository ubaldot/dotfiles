vim9script

if has("win64") || has("win32") || has("win16")
  g:os = "Windows"
else
  g:os = substitute(system('uname'), '\n', '', '')
endif

# For WSL conditionals
def IsWSL(): bool
  if has("unix")
    if filereadable("/proc/version") # avoid error on Android
      var lines = readfile("/proc/version")
      if lines[0] =~ "microsoft"
        return true
      endif
    endif
  endif
  return false
enddef


if has('unix') && IsWSL()
  def WslPut(above: bool = false)
     var copied_text = system('powershell.exe Get-Clipboard')->substitute("\r", '', 'g' )
     setreg("p", copied_text)
     if !above
       norm! "pp
     else
       norm! "pP
     endif
  enddef

  noremap "pp <scriptcmd>WslPut()<cr>
  noremap "pP <scriptcmd>WslPut(true)<cr>
endif

# Set clipboard on WSL
# if has('unix') && IsWSL()
#   g:clipboard = {
#     name: 'WslClipboard',
#     copy: {
#       '+': 'clip.exe',
#       '*': 'clip.exe',
#     },
#     paste: {
#       '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
#       '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
#     },
#     'cache_enabled': 0,
#   }
# endif

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
if executable("xdg-open")
  g:start_cmd = "xdg-open"
# Linux/BSD
elseif executable('cmd.exe')
  g:start_cmd = "explorer.exe"
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
# set clipboard^=unnamed,unnamedplus
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
set wildignore+=**/*cache*,*.o,**/*miniforge*,**/*ipynb*
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
# inoremap å `
cnoremap å ~


# For using up and down in popup menu
# inoremap <expr><Down> pumvisible() ? "\<C-n>" : "\<Down>"
# inoremap <expr><Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <cr> pumvisible() ? "\<C-Y>" : "\<cr>"
# inoremap kj <esc>

# Remap {['command-line']} stuff
cnoremap <c-p> <up>
cnoremap <c-n> <down>

# Otherwise I cannot paste in registers
# xnoremap " <esc><ScriptCmd>myfunctions.Surround('"', '"')<cr>
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

# Change to repo root, ~ or /.
#
#
def GoToGitRoot()
  # Change dir to the current buffer location and if you are in a git repo,
  # then change dir to the git repo root.
  exe $'cd {expand('%:p:h')}'
  var git_root = system('git rev-parse --show-toplevel')
  if v:shell_error == 0
    exe $'cd {git_root}'
  endif
  pwd
enddef

noremap cd <scriptcmd>GoToGitRoot()<cr>

# Opposite of J, i.e. split from current cursor position
nnoremap S i<cr><esc>
# noremap <silent> <c-v> :call system("clip.exe", getreg("0"))<cr>
# <ScriptCmd> allows remapping to functions without the need of defining
# them as g:.
nnoremap <c-w>q <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <c-w><c-q> <ScriptCmd>myfunctions.QuitWindow()<cr>
# nnoremap <leader>b <Cmd>ls!<cr>:b
nnoremap <s-tab> <cmd>bprev <cr>
# nnoremap <c-tab> :b <tab>
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
# nnoremap bw <cmd>bw!<cr>
nnoremap <c-b><c-w> <cmd>bw!<cr>

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
# Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
# Plug 'junegunn/fzf.vim' # For getting the help, :h plug-options
Plug 'sainnhe/everforest'
Plug 'lifepillar/vim-solarized8'
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'yegappan/lsp'
Plug 'ubaldot/vim-highlight-yanked'
Plug 'ubaldot/vim-helpme'
Plug 'ubaldot/vim-outline'
Plug 'ubaldot/vim-replica'
Plug 'ubaldot/vim-manim'
Plug 'ubaldot/vim-microdebugger'
Plug 'ubaldot/vim9-conversion-aid'
Plug 'ubaldot/vim-extended-view'
Plug 'ubaldot/vim-poptools'
# Plug 'ubaldot/vim-open-recent'
# Plug 'ubaldot/vim-conda-activate'
Plug 'girishji/easyjump.vim'
# Plug 'girishji/scope.vim'
# Plug 'Donaldttt/fuzzyy'
Plug 'Konfekt/vim-compilers'
Plug 'puremourning/vimspector'
Plug 'qadzek/link.vim'
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

# vim-poptools
g:poptools_config = {}
g:poptools_config['preview_recent_files'] = false
g:poptools_config['preview_buffer'] = false
# g:poptools_config['preview_syntax'] = false

nnoremap <c-p> <cmd>PoptoolsFindFile<cr><cr>
nnoremap <c-g> <cmd>PoptoolsGrep<cr>
nnoremap <c-p>f <cmd>PoptoolsFindFile<cr>
nnoremap <c-p>l <cmd>PoptoolsLastSearch<cr>
nnoremap <c-tab> <cmd>PoptoolsBuffers<cr>
nnoremap <c-p>h <cmd>PoptoolsCmdHistory<cr>
xnoremap <c-p>h <esc>PoptoolsCmdHistory<cr>
nnoremap <c-p>d <cmd>PoptoolsFindDir<cr>
nnoremap <c-p>o <cmd>PoptoolsRecentFiles<cr>

def ShowRecentFiles()
  var readable_args = copy(v:argv[1 : ])->filter((_, x) =>
         !empty(x) && filereadable(x)
        )
  if len(readable_args) == 0
    execute('PoptoolsRecentFiles')
  endif
enddef

augroup OpenRecent
    autocmd!
    autocmd VimEnter * ShowRecentFiles()
augroup END
# var use_scope = false
# if filereadable($'{g:dotvim}/plugins/scope.vim/plugin/scope.vim')
#   import autoload 'scope/fuzzy.vim'
# endif
# if use_scope
#   # scope.vim
#   if executable('fd')
#     nnoremap <c-p> <scriptcmd>fuzzy.File('fd -tf --follow')<cr>
#   else
#     nnoremap <c-p> <scriptcmd>fuzzy.File()<cr>
#   endif
#   nnoremap <c-p>g <c-u>:Scope Grep<space>
#   nnoremap <c-p>b <scriptcmd>fuzzy.Buffer()<cr>
#   nnoremap <c-p>o <scriptcmd>fuzzy.MRU()<cr>

#   highlight default link ScopeMenuMatch Normal
#   highlight default link ScopeMenuSubtle Normal

#   fuzzy.OptionsSet({
#     mru_rel_path: true
#   })
# else
#   # fuzzyy setup
#   g:enable_fuzzyy_keymaps = false
#   g:fuzzyy_dropdown = true
#   g:fuzzyy_menu_matched_hl = 'WarningMsg'
#   g:fuzzyy_files_ignore_file = ['*.beam', '*.so', '*.exe', '*.dll', '*.dump',
#     '*.core', '*.swn', '*.swp', '*.ipynb']
#   g:fuzzyy_files_ignore_dir = ['*cache*', '.github', '.git', '.hg', '.svn', '.rebar', '.eunit']

#   nnoremap <c-p> <cmd>FuzzyFiles<cr>
#   nnoremap <c-p>w <cmd>FuzzyInBuffer<cr>
#   nnoremap <c-p>b <cmd>FuzzyBuffer<cr>
#   nnoremap <c-p>o <cmd>FuzzyMRUFiles<cr>
#   nnoremap <c-p>c <cmd>FuzzyCmdHistory<cr>
#   nnoremap <c-p>g <cmd>FuzzyGrep<cr>

#   g:fuzzyy_window_layout = {
#     FuzzyFiles: { preview: false },
#     FuzzyMRUFiles: { preview: false },
#     FuzzyBuffers: { preview: false }
#   }
# endif

# def ShowRecentFiles()
#   var readable_args = copy(v:argv[1 : ])->filter((_, x) =>
#     !empty(x) && filereadable(x)
#   )
#   if len(readable_args) == 0
#     if use_scope && exists('*fuzzy.MRU') > 0
#       fuzzy.MRU()
#       # To remove the <80><fd>a added by gvim
#       if has('win32') && has('gui_running')
#         feedkeys("\<c-u>")
#       endif
#     elseif exists(':FuzzyMRUFiles') > 0
#       execute('FuzzyMRUFiles')
#     endif
#   endif
# enddef

# augroup OpenRecent
#   autocmd!
#   autocmd VimEnter * ShowRecentFiles()
# augroup END

# Vim9-conversion-aid
g:vim9_conversion_aid_fix_let = true
g:vim9_conversion_aid_fix_asl = true

# vim-outline
g:outline_autoclose = false

# vim-open-recent
# g:vim_open_change_dir = true
# g:vim_open_at_empty_startup = false
# nnoremap <c-p>o <scriptcmd>OpenRecent<cr>

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
g:replica_console_width = &columns / 2
# g:replica_python_options = "-Xfrozen_modules=off"
g:replica_jupyter_console_options = {
  python: " --config ~/.jupyter/jupyter_console_config.py"}
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
