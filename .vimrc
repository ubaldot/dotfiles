vim9script

# For avap dev
g:is_avap = false

# OS detection
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

if has("win64") || has("win32") || has("win16")
  g:os = "Windows"
  g:dotfiles = '\\wsl.localhost\Ubuntu-22.04.2-PEES-0.0.7\home\yt75534\dotfiles'
elseif IsWSL()
  g:os = 'WSL'
  g:dotfiles = $'{$HOME}/dotfiles'
else
  g:os = substitute(system('uname'), '\n', '', '')
  g:dotfiles = $'{$HOME}/dotfiles'
  language en_US.UTF-8
endif

if has('unix') && g:os == 'WSL' && !has('+clipboard')
  # Yank
  if !has('gui_running')
    augroup WSL_YANK
      autocmd!
      autocmd TextYankPost * if v:event.operator ==# 'y'
            \ | system('clip.exe', getreg('0')) | endif
    augroup END
   endif

  def WslPut(above: bool = false)
    var start_linenr = above ? line('.') - 1 : line('.')
    var copied_text = split(getreg('+'), '\r\n')
    var end_linenr = start_linenr + len(copied_text)
    appendbufline(bufnr(), start_linenr, copied_text)
  enddef

  nnoremap "+p <scriptcmd>WslPut()<cr>
  nnoremap "+P <scriptcmd>WslPut(true)<cr> # Paste
endif

if g:os == "Windows" || g:os =~ "^MINGW64"
  g:tmp = "C:/temp"
  g:null_device = "NUL"
  g:dotvim = $HOME .. "\\vimfiles"
else
  g:tmp = "/tmp"
  g:null_device = "/dev/null"
  g:dotvim = $HOME .. "/.vim"
  &pythonthreehome = fnamemodify(trim(system("which python")), ":h:h")
  if g:os == 'Linux' || g:os == 'WSL'
    &pythonthreedll = $'{&pythonthreehome}/lib/libpython3.12.so'
  else
    &pythonthreedll = $'{&pythonthreehome}/lib/libpython3.12.dylib'
  endif
endif
# ------------------------

import g:dotvim .. "/lib/myfunctions.vim"

augroup RELOAD_VIM_SCRIPTS
  autocmd!
  autocmd BufWritePost *.vim,*.vimrc,*.gvimrc {
    exe "source %"
    echo $"{expand('%:t')} reloaded."
  }
augroup END

# Open help pages in vertical split
augroup vimrc_help
  autocmd!
  autocmd BufEnter *.txt {
    if &buftype == 'help'
      wincmd H
    endif
  }
augroup END

# langmap does not work with multi-byte chars,
# see https://github.com/vim/vim/issues/3018
# set langmap=ö[,ä]
set nocompatible
set nomodeline
set scrolloff=8
set encoding=utf-8

# These dotfiles are shared between Windows and WSL through the same physical
# files, so anything written with CRLF shows up as ^M in Linux Vim. Windows
# Vim defaults to 'fileformats=dos,unix', which gives every *new* file CRLF.
# Listing unix first makes new files LF everywhere; existing CRLF files are
# still detected correctly, because "dos" remains in the list.
set fileformats=unix,dos
set langmenu=en_US.UTF-8
set nofoldenable
set belloff=all
set colorcolumn=80
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
set splitright
set splitbelow
set incsearch # for displaying while searching
set ignorecase
set smartcase
set hidden
set noswapfile
set wildmenu wildoptions=pum
set wildmode=noselect:lastused,full
set wildignore+=**/*cache*,*.o,**/*ipynb*
set completeopt-=preview
set textwidth=78
set iskeyword+=-
set formatoptions+=wnp
set diffopt+=vertical
set wildcharm=<tab>
set conceallevel=2
set concealcursor=nvc
set autocomplete
set complete=.^5,w^5,b^5,u^5
set completeopt=popup

filetype plugin on
filetype indent on
syntax on

# Set spell only in selected filetypes
augroup SPELLLANG_OPTION
  autocmd!
  # autocmd FileType markdown setlocal spell spelllang=en_us
  autocmd FileType text,tex,gitcommit setlocal spell spelllang=en_us
  autocmd FileType gitcommit setlocal spell spelllang=en_us
augroup END

# Set cursor
# Needed for Windows terminal
if g:os == "Windows" && !has("gui_running")

  set guicursor=

  &t_SI = "\e[6 q" # beam in Insert mode
  &t_EI = "\e[2 q" # block in Normal mode

  # Restore cursor shape when leavig Vim
  def RestoreCursorWindowsTerminal()
    &t_EI = "\e[6 q"
    execute "normal! i\<Esc>"
  enddef

  augroup CURSOR_SHAPE_WINDOWS
    autocmd!
    autocmd VimEnter * silent! execute "normal! \<Esc>"
    autocmd VimLeave * RestoreCursorWindowsTerminal()
  augroup END
else
  &t_SI = "\e[6 q"
  &t_EI = "\e[2 q"
endif


# Some key ""bindings""
# ----------------------
g:mapleader = ","
g:maplocalleader = ","

# Essential mappings
# ----------------------
# Avoid polluting registers
nnoremap x "_x
# Switch window
nnoremap <c-h> <c-w>h
nnoremap <c-down> <c-e>
nnoremap <c-up> <c-y>
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j


# <tab> for pum completion
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <c-space> <c-n>

# Delete buffer
def BufferDelete()
if len(getbufinfo({'buflisted': 1})) == 2
  bdelete %
else
  bprev
   exe $"bd! {bufnr('#')}"
endif
enddef

nnoremap <c-d> <ScriptCmd>BufferDelete()<cr>

# to be able to undo accidental c-w"
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

nnoremap <leader>vv <cmd>exe $'edit {g:dotfiles}/.vimrc'<cr>

# Windows-like mapping
nnoremap <c-z> u
if g:os == "Windows"
  xnoremap <c-c> "*y
else
  xnoremap <c-c> "+y
endif

if g:os == "Windows"
  nnoremap <c-v> "*p
elseif g:os == "WSL"
  nnoremap <c-v> <scriptcmd>WslPut()<cr>
else
  nnoremap <c-v> "+p
endif

augroup SET_HEADERS_AS_C_FILETYPE
  autocmd!
  autocmd BufRead,BufNewFile *.h set filetype=c
augroup END
# For using up and down in popup menu
inoremap <expr> <cr> pumvisible() ? "\<C-Y>" : "\<cr>"

# Remap {['command-line']} stuff
cnoremap <c-p> <up>
cnoremap <c-n> <down>

# # TODO: does not work with macos
# # adjustment for Swedish keyboard
# # nmap ö [
# # nmap ä ]

# Resize gvim window to take notes:

# Only apply when in diff mode
augroup DIFF_KEYBINDINGS
  autocmd!
  autocmd OptionSet diff if &diff | DiffMappings() | endif
augroup END

def DiffMappings()
  # Navigation between changes
  nnoremap <buffer> j <cmd>normal! ]c<CR>
  nnoremap <buffer> k <cmd>normal! [c<CR>

  # Get changes from other buffers
  nnoremap <buffer> gr <cmd>diffget REMOTE<CR>
  nnoremap <buffer> gl <cmd>diffget LOCAL<CR>

  # Refresh diff
  nnoremap <buffer> <F5> <cmd>diffupdate<CR>

  # Quit diff mode
  nnoremap <buffer> <esc> <cmd>diffoff<CR>
enddef


def ResizeGvim()
  set lines=20 columns=60
enddef
command! -nargs=0 ResizeGvim ResizeGvim()

# Change to repo root, ~ or /.
def GoToGitRoot()
  # Change dir to the current buffer location and if you are in a git repo,
  # then change dir to the git repo root.
  exe $'cd {expand('%:p:h')}'
  var git_root = system('git rev-parse --show-toplevel')
  v:shell_error does not work in Windows, it returns 0
  if v:shell_error == 0 && git_root !~ 'fatal: not a git repository'
    exe $'cd {git_root}'
  endif
  pwd
enddef

noremap cd <scriptcmd>GoToGitRoot()<cr>

nnoremap <F1> <Cmd>helpclose<cr>
# Opposite of J, i.e. split from current cursor position
nnoremap S i<c-j><esc>
# <ScriptCmd> allows remapping to functions without the need of defining
# them as g:.
nnoremap <c-w>q <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <c-w><c-q> <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <s-tab> <cmd>bprev <cr>
# nnoremap <leader>b :b <tab>
# nnoremap <tab> <Cmd>bnext<cr>
nnoremap <tab> :b <tab><tab>
nnoremap <c-p>o <cmd>browse oldfiles<cr>
nnoremap Y y$
noremap <c-PageDown> <Cmd>bprev<cr>
noremap <c-PageUp> <Cmd>bnext<cr>

# nnoremap <leader>F :find<space>
 #

# search
# TODO:
# xnoremap <c-h> <esc><ScriptCmd>myfunctions.HighlightVisualSelection()<cr>

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
tnoremap <c-d> <ScriptCmd>myfunctions.Quit_term_popup(true)<cr>
tnoremap <c-r> <c-w>"

augroup DIRCHANGE
  autocmd!
  autocmd DirChanged global myfunctions.ChangeTerminalDir()
augroup END

augroup shoutoff_terminals
  autocmd QuitPre * myfunctions.WipeoutTerminals()
augroup END

augroup CMDWIN_MAPS
  autocmd!
  autocmd CmdWinEnter * nnoremap <buffer> <Esc> <cmd>q<CR>
  autocmd CmdWinEnter * nnoremap <buffer> <c-d> <cmd>q<CR>
augroup END

def ShiftRegisters()
    for ii in [8, 7, 6, 5, 4, 3, 2, 1, 0]
      setreg(string(ii + 1), getreg(string(ii)))
    endfor
enddef

augroup YANK_SHIFT_REGISTERS
  autocmd!
  autocmd TextYankPost * if v:event.operator == 'y' | ShiftRegisters() | endif
augroup END

# packages
# ----------------
const packages_to_load = [
  'comment',
  'hlyank',
  # 'vim-outline',
  'fern.vim',
  'vim-calendar',
  # 'minpac',
  # 'vim-git-box',
  # 'copilot-chat.vim',
  'vim-helpme',
  'vim-markdown-extras',
  'vim-poptools',
  # 'vim-replica',
]

for pack in packages_to_load
  # No need to reload if a package is already loaded
  if index(myfunctions.LoadedPackages(), pack) == -1
    myfunctions.Packadd(pack)
  endif
endfor

if (g:os == "Windows" || g:os == "WSL")
    && index(myfunctions.LoadedPackages(), 'vim-outlook') == -1
  myfunctions.Packadd('vim-outlook')
endif


# Bunch of commands
# -----------------------
augroup REMOVE_TRAILING_WHITESPACES
  autocmd!
  autocmd BufWritePre * {
    if !&binary
      myfunctions.TrimWhitespace()
    endif
  }
augroup END

command! ColorsToggle myfunctions.ColorsToggle()

# Utils commands
command! -nargs=1 -complete=command -range Redir
      \ silent myfunctions.Redir(<q-args>, <range>, <line1>, <line2>)

# CC stuff
const CC_FILENAME = 'cab_climate.vim'

# The same OneDrive folder, addressed from whichever side Vim is running on.
# The WSL branch used to be given the Windows path, so the copy below failed
# on every startup.
const CC_DIR = g:os == 'WSL'
  ? '/mnt/c/Users/yt75534/OneDrive - Volvo Group/CabClimate'
  : 'C:\Users\yt75534\OneDrive - Volvo Group\CabClimate'

# On WSL the script is copied out of the Windows filesystem first: /mnt/c is
# slow to source from and the file arrives with CRLF endings.
const CC_LOCAL = g:os == 'WSL'
  ? $'{$HOME}/{CC_FILENAME}'
  : $'{CC_DIR}\{CC_FILENAME}'

def SourceCabClimate()
  if filereadable(CC_LOCAL)
    execute $'source {fnameescape(CC_LOCAL)}'
  endif
enddef

augroup CAB_CLIMATE_SOURCE_SCRIPT
  autocmd!
  autocmd VimEnter * SourceCabClimate()
augroup END

# If working in WSL
if g:os == "WSL"
  # Refresh the local copy from Windows, quietly doing nothing when the
  # OneDrive folder is not mounted (offline, or a machine without it).
  var cc_remote = $'{CC_DIR}/{CC_FILENAME}'
  if filereadable(cc_remote)
    # Copy and strip CR in one step. dos2unix is not used: the only one on
    # PATH here is the Windows .exe, which cannot see a Linux path.
    var cp_out = system(
      $'tr -d "\r" < {shellescape(cc_remote)} > {shellescape(CC_LOCAL)}')
    if v:shell_error
      myfunctions.Echoerr($"Error in copying '{CC_FILENAME}' from Windows: {cp_out}")
    endif
  endif
endif
