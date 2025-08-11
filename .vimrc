vim9script

# For avap dev
g:is_avap = false
var is_PE = true
var auto_update_dotfiles = get(g:, 'auto_update_dotfiles', false)
var auto_update_notes = get(g:, 'auto_update_dotfiles', false)

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
elseif IsWSL()
  g:os = 'WSL'
else
  g:os = substitute(system('uname'), '\n', '', '')
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
    var copied_text = split(getreg('+'), '\n')
    var end_linenr = start_linenr + len(copied_text)
    appendbufline(bufnr(), start_linenr, copied_text)
    silent! exe $":{start_linenr},{end_linenr}s/\\r$//g"
  enddef

  nnoremap "+p <scriptcmd>WslPut()<cr>
  nnoremap "+P <scriptcmd>WslPut(true)<cr> # Paste
endif

if g:os == "Windows" || g:os =~ "^MINGW64"
  g:tmp = "C:/temp"
  g:null_device = "NUL"
	g:dotvim = $HOME .. "\\vimfiles"
  exe $"set runtimepath+={g:dotvim}"
else
  g:tmp = "/tmp"
  g:null_device = "/dev/null"
  g:dotvim = $HOME .. "/.vim"
  #if !is_PE
	  &pythonthreehome = fnamemodify(trim(system("which python")), ":h:h")
	  if g:os == 'Linux' || g:os == 'WSL'
	    &pythonthreedll = $'{&pythonthreehome}/lib/libpython3.12.so'
	  else
	    &pythonthreedll = $'{&pythonthreehome}/lib/libpython3.12.dylib'
	  endif
#else
#	&pythonthreehome =  '/usr/bin'
#	 &pythonthreedll = '/usr/lib/x86_64-linux-gnu/python3.10.so.1'
#	endif
endif
# ------------------------

import g:dotvim .. "/lib/myfunctions.vim"

# Set cursor
&t_SI = "\e[6 q"
&t_EI = "\e[2 q"
# &t_ti = "\e[6 q\e[?1049h"
# &t_te = "\e[5 q\e[?1049l"

augroup RELOAD_VIM_SCRIPTS
  autocmd!
  autocmd BufWritePost *.vim,*.vimrc,*.gvimrc {
    exe "source %"
    echo expand('%:t') .. " reloaded."
  }
augroup END

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
# langmap does not work with multi-byte chars,
# see https://github.com/vim/vim/issues/3018
set langmap=ö[,ä]
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
set wildignore+=**/*cache*,*.o,**/*miniforge*,**/*ipynb*,**/*dist*
set completeopt-=preview
set textwidth=78
set iskeyword+=-
set formatoptions+=wnp
set diffopt+=vertical
set wildcharm=<tab>
set conceallevel=2
set concealcursor=nvc
config#statusline#Setup()
# TODO adjust path option. Move to after/ftplugin
# set path+=**
# set cursorline
# UBA

filetype plugin on
filetype indent on
syntax on

# Some key ""bindings""
# ----------------------
g:mapleader = ","
g:maplocalleader = ","
map <leader>vr <Cmd>source $MYVIMRC<cr> \| <Cmd>echo ".vimrc reloaded."
map <leader>vv <Cmd>e $MYVIMRC<cr>

# For using up and down in popup menu
inoremap <expr> <cr> pumvisible() ? "\<C-Y>" : "\<cr>"

# Remap {['command-line']} stuff
cnoremap <c-p> <up>
cnoremap <c-n> <down>

def ToggleCmdWindow()
  if empty(getcmdwintype())
    feedkeys("q:i", "n")
  else
    var cmd = getline('.')
    quit
    feedkeys($":{cmd}", "n")
  endif
enddef

# nnoremap <c-c> <ScriptCmd>ToggleCmdWindow()<cr>

# TODO: does not work with macos
# adjustment for Swedish keyboard
nmap ö [
nmap ä ]
# Avoid polluting registers
nnoremap x "_x

# Change to repo root, ~ or /.
def GoToGitRoot()
  # Change dir to the current buffer location and if you are in a git repo,
  # then change dir to the git repo root.
  exe $'cd {expand('%:p:h')}'
  var git_root = system('git rev-parse --show-toplevel')
  # v:shell_error does not work in Windows, it returns 0
  if v:shell_error == 0 && git_root !~ 'fatal: not a git repository'
    exe $'cd {git_root}'
  endif
  pwd
enddef
noremap cd <scriptcmd>GoToGitRoot()<cr>

# Better gx
# nmap gx <ScriptCmd>myfunctions.Gx()<cr>

# Auto push/pull dotfiles
def PullRepofiles(repo_path: string)
  # If there is any local change, commit them first, then pull
  if !empty(system($'git -C {repo_path} status --short'))
    exe $'!git -C {repo_path} add .'
    exe $'!git -C {repo_path} ci -m "Saved local changes"'
  endif

  # Pull & merge eventual commit
  var output = systemlist($'git -C {repo_path} pull --rebase')
  if !empty(copy(output) ->filter('v:val =~ "CONFLICT"'))
    echoerr "You have conflicts in ~/dotfiles!"
  elseif !empty(copy(output) ->filter('v:val !~ "Already up to date"'))
    echom copy(output) ->filter('v:val !~ "Already up to date"')
    echoerr "OBS! ~/dotfiles updated! "
             .. "You may need restart Vim to update your environment."
  endif
enddef

def PushRepofiles(repo_path: string)
  # Pull first before pushing
  if !empty(systemlist($'git -C {repo_path} pull')
      ->filter('v:val =~ "CONFLICT"'))
    # Needed to prevent Vim to automatically quit
    input('You have conflicts in ~/dotfiles. Nothing will be pushed.')
  # If I changed some dotfiles I want to push them to the remote
  elseif !empty(systemlist($'git -C {repo_path} status')
        ->filter('v:val =~ "Changes not staged for commit'
             .. '\\|Changes to be committed'
             .. '\\|Your branch is ahead"'))
    exe $'!git -C {repo_path} add .'
    exe $'!git -C {repo_path} ci -m "Auto pushing {repo_path}... "'
    exe $'!git -C {repo_path} push'
  endif
enddef

if auto_update_dotfiles
  augroup DOTFILES
    autocmd!
    autocmd VimLeavePre * PushRepofiles($'{$HOME}/dotfiles')
    autocmd VimEnter * PullRepofiles($'{$HOME}/dotfiles')
  augroup END
endif

if auto_update_notes
  augroup NOTES
    autocmd!
    autocmd VimLeavePre * PushRepofiles($'{$HOME}/Documents/my_notes')
    autocmd VimEnter * PullRepofiles($'{$HOME}/Documents/my_notes')
  augroup END
endif

nnoremap <F1> <Cmd>helpclose<cr>
# Opposite of J, i.e. split from current cursor position
nnoremap S i<cr><esc>
# <ScriptCmd> allows remapping to functions without the need of defining
# them as g:.
nnoremap <c-w>q <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <c-w><c-q> <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <s-tab> <cmd>bprev <cr>
# nnoremap <leader>b :b <tab>
nnoremap <tab> <Cmd>bnext<cr>
nnoremap Y y$
noremap <c-PageDown> <Cmd>bprev<cr>
noremap <c-PageUp> <Cmd>bnext<cr>
#
# Switch window
nnoremap <c-h> <c-w>h
nnoremap <c-down> <c-e>
nnoremap <c-up> <c-y>
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j

# search
# nnoremap <c-s> <cmd>SearchAndReplace<cr>
nnoremap <c-s> :%s/
xnoremap <c-s> "ty<cmd>exe $"SearchAndReplace {getreg('t')}"<cr>
nnoremap <c-s><c-s> <cmd>SearchAndReplaceInFiles<cr>
xnoremap <c-s><c-s> "ty<cmd>exe $"SearchAndReplaceInFiles {getreg('t')}"<cr>
xnoremap <c-h> <esc><ScriptCmd>myfunctions.HighlightVisualSelection()<cr>

# Wipe buffer
nnoremap <c-d> <cmd>bw!<cr>

# Formatting
# command! -range=% Prettify myfunctions.Prettify(<line1>, <line2>)
nnoremap Q <ScriptCmd>myfunctions.FormatWithoutMoving()<cr>
xnoremap Q <esc><ScriptCmd>
      \myfunctions.FormatWithoutMoving(line("'<"), line("'>"))<cr>

# location list
nnoremap äl :lnext<CR>
nnoremap öl :lprevious<CR>

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
tnoremap <c-tab> <cmd>PoptolsBuffers<cr>
# tnoremap <s-tab> <cmd>bnext<cr>
tnoremap <s-tab> <c-w>:b <tab>
tnoremap <c-w>q <ScriptCmd>myfunctions.Quit_term_popup(true)<cr>
tnoremap <c-w>c <ScriptCmd>myfunctions.Quit_term_popup(false)<cr>
nnoremap <c-t> <ScriptCmd>myfunctions.OpenMyTerminal()<cr>
tnoremap <c-t> <ScriptCmd>myfunctions.HideMyTerminal()<cr>
tnoremap <c-d> <ScriptCmd>myfunctions.Quit_term_popup(true)<cr>
tnoremap <c-r> <c-w>"
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

augroup CMDWIN_MAPS
  autocmd!
  autocmd CmdWinEnter * nnoremap <buffer> <Esc> <cmd>q<CR>
  autocmd CmdWinEnter * nnoremap <buffer> <c-d> <cmd>q<CR>
augroup END

# plugins
# start plugins: the config files go in plugin/ and they are automatically
# loaded
# opt plugins: the config files go on autoload/config and the config must be
# run through a Setup() function
# Bundled plugins
packadd comment
packadd helptoc
packadd matchit

# Plugin settings
# -----------------
# comment
command! -range -nargs=0 Comment exe ":<line1>,<line2>norm gcc"
nnoremap <silent> <expr> gC comment#Toggle() .. '$'

augroup SET_HEADERS_AS_C_FILETYPE
  autocmd!
  autocmd BufRead,BufNewFile *.h set filetype=c
augroup END

# git master
nnoremap git <Cmd>GitMasterStatus<cr>

# Easy-align
# Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)*\|
# Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)*\|

inoremap <silent> <Bar> <Bar><Esc><ScriptCmd>myfunctions.Align()<CR>a
command! -nargs=0 EasyDelimiter myfunctions.InsertRowDelimiter()

# Vim9-conversion-aid
g:vim9_conversion_aid_fix_let = true
g:vim9_conversion_aid_fix_asl = true

# vim-outline
g:outline_autoclose = false

# vim-replica stuff
# ----------------------------------
g:replica_console_position = "J"
g:replica_display_range  = false
# g:replica_console_height = 8
g:replica_console_height = max([&lines / 6, 4])
g:replica_jupyter_console_options = {
  python: " --config ~/.jupyter/jupyter_console_config.py"}
nnoremap <silent> <c-enter> <Plug>ReplicaSendCell<cr>j
nnoremap <silent> <F9> <Plug>ReplicaSendLines<cr>
xnoremap <silent> <F9> <Plug>ReplicaSendLines<cr>

# Outline. <F8> is overriden by vimspector
nnoremap <silent> <F8> <Plug>OutlineToggle

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

# git add -u && git commit -m "."
command! GitCommitDot myfunctions.CommitDot()
command! GitPushDot myfunctions.PushDot()
# Merge and diff
command! -nargs=? Diff myfunctions.Diff(<q-args>)
nnoremap <expr> gl &diff
      \ ? 'execute "diffget " .. getcompletion("LOCAL", "diff_buffer")[0]<CR>'
      \ : 'gl'
nnoremap <expr> gr &diff
      \ ? 'execute "diffget " .. getcompletion("REMOTE", "diff_buffer")[0]<CR>'
      \ : 'gr'

command! ColorsToggle myfunctions.ColorsToggle()

# Utils commands
command! -nargs=1 -complete=command -range Redir
      \ silent myfunctions.Redir(<q-args>, <range>, <line1>, <line2>)

# Path to URL command
def PathToURL(path: string)
  setreg('p', myfunctions.PathToURL(fnamemodify(path, ':p')))
  echo "URL stored in register 'p'"
enddef

command! -nargs=1 -complete=file PathToURL PathToURL(<f-args>)


# ==  Note taking stuff ==
var work_log_path =
      \ '/mnt/c/Users/yt75534/OneDrive\ -\ Volvo\ Group/work_log.md'
if g:os == "Windows"
  work_log_path =
        \ 'C:\Users\yt75534/OneDrive\ -\ Volvo\ Group/work_log.md'
endif

def IndexOpen(index_path: string)
  # Opens and jump to the end. Finish.
  exe $'edit {index_path}'
  const references_string =
    "<!-- DO NOT REMOVE vim-markdown-extras references DO NOT REMOVE-->"
  var refs_line = search(references_string)
  if refs_line == 0
    norm! G
  else
    search('^.\+$', 'b')
  endif
enddef

command! LLogNewDay IndexNewDay(work_log_path)
command! LLogOpen IndexOpen(work_log_path)
command! TODO IndexOpen($'{$HOME}/Documents/my_notes/README.md')

# CC stuff
if g:os == "Windows"
  const WINDOWS_HOME = 'C:/Users/yt75534/OneDrive - Volvo Group'
  execute $"source {WINDOWS_HOME}/CabClimate/cab_climate.vim"
elseif g:os == "WSL"
  const WINDOWS_HOME = '/mnt/c/Users/yt75534/OneDrive\ -\ Volvo\ Group'
  const filename = 'cab_climate.vim'

  # Copy file from Windows
  exe $"system('cp {WINDOWS_HOME}/CabClimate/{filename} {$HOME}')"
  if v:shell_error
    myfunctions.Echoerr($"Error in copying '{filename}' from Windows")
  endif

  # Check if the file has been copied
  exe $"system('ls {$HOME}/cab_climate.vim')"
  if v:shell_error
    myfunctions.Echoerr($"'{filename}' not copied in {$HOME}")
  endif

  exe $"system('dos2unix.exe {$HOME}/cab_climate.vim')"
  execute $"source {$HOME}/cab_climate.vim"
endif
