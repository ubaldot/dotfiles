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
      autocmd TextYankPost * if v:event.operator ==# 'y' | system('clip.exe', getreg('0')) | endif
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
	g:dotvim = $HOME .. "\\.vim"
	g:dotvim = $HOME .. "\\vimfiles"
  exe $"set runtimepath+={g:dotvim}"
else
  g:tmp = "/tmp"
  g:null_device = "/dev/null"
  g:dotvim = $HOME .. "/.vim"
  &pythonthreehome = fnamemodify(trim(system("which python")), ":h:h")
  if g:os == 'Linux' || g:os == 'WSL'
    &pythonthreedll = $'{&pythonthreehome}/lib/libpython3.12.so'
  else
    &pythonthreedll = $'{&pythonthreehome}/lib/libpython3.11.dylib'
  endif
endif

# Windows
if exists(':Open') == 0
  if executable("xdg-open")
    g:start_cmd = "xdg-open"
# Linux/BSD
  elseif executable('cmd.exe')
    g:start_cmd = "explorer.exe"
# MacOS
  elseif executable("open")
    g:start_cmd = "open"
  endif
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
set langmap=ö[,ä]
nnoremap <C-ö> <C-[>
nnoremap <C-ä> <C-]>
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
set wildignore+=**/*cache*,*.o,**/*miniforge*,**/*ipynb*
set completeopt-=preview
set textwidth=78
set iskeyword+=-
set formatoptions+=wnp
set diffopt+=vertical
set wildcharm=<tab>
set conceallevel=2
set concealcursor=nvc
# TODO adjust path option. Move to after/ftplugin
# set path+=**
# set cursorline

# Some key ""bindings""
# ----------------------
map <f1> <cmd>helpclose<cr>
g:mapleader = ","
map <leader>vr <Cmd>source $MYVIMRC<cr> \| <Cmd>echo ".vimrc reloaded."
map <leader>vv <Cmd>e $MYVIMRC<cr>

# For using up and down in popup menu
inoremap <expr> <cr> pumvisible() ? "\<C-Y>" : "\<cr>"

# Remap {['command-line']} stuff
cnoremap <c-p> <up>
cnoremap <c-n> <down>
cnoremap å ~

def ToggleCmdWindow()
  if empty(getcmdwintype())
    feedkeys("q:i", "n")
  else
    var cmd = getline('.')
    quit
    feedkeys($":{cmd}", "n")
  endif
enddef

nnoremap <c-c> <ScriptCmd>ToggleCmdWindow()<cr>

# Otherwise I cannot paste in registers
xnoremap <leader>" <esc><ScriptCmd>myfunctions.Surround('"', '"')<cr>
xnoremap <leader>' <esc><ScriptCmd>myfunctions.Surround("'", "'")<cr>
xnoremap <leader>( <esc><ScriptCmd>myfunctions.Surround('(', ')')<cr>
xnoremap <leader>[ <esc><ScriptCmd>myfunctions.Surround('[', ']')<cr>
xnoremap <leader>{ <esc><ScriptCmd>myfunctions.Surround('{', '}')<cr>
xnoremap <leader>< <esc><ScriptCmd>myfunctions.Surround('<', '>')<cr>

# TODO: does not work with macos
# adjustment for Swedish keyboard
# nmap <c-ö> <c-[>
# nmap <c-ä> <c-]>
# Avoid polluting registers
nnoremap x "_x

# Change to repo root, ~ or /.
def GoToGitRoot()
  # Change dir to the current buffer location and if you are in a git repo,
  # then change dir to the git repo root.
  exe $'cd {expand('%:p:h')}'
  var git_root = system('git rev-parse --show-toplevel')
  # v:shell_error does not work in Windows, it returns 0
  if v:shell_error == 0 && g:os != "Windows"
    exe $'cd {git_root}'
  endif
  pwd
enddef
noremap cd <scriptcmd>GoToGitRoot()<cr>

# Better gx
nnoremap gx <ScriptCmd>myfunctions.Gx()<cr>

# Auto push/pull dotfiles
def PullDotfiles()
    # If there is any local change, commit them first, then pull
  if !empty(systemlist($'git -C {$HOME}/dotfiles status')
      ->filter('v:val =~ "Changes not staged for commit\\|Changes to be committed"'))
    exe $'!git -C {$HOME}/dotfiles add -u'
    exe $'!git -C {$HOME}/dotfiles ci -m "Saved local changes"'
  endif

  # Pull & merge eventual commit
  var git_pull_status = systemlist($'git -C {$HOME}/dotfiles pull')
  if !empty(git_pull_status ->filter('v:val =~ "CONFLICT"'))
    echoerr "You have conflicts in ~/dotfiles"
  elseif !empty(git_pull_status ->filter('v:val !~ "Already up to date"'))
    echo "dotfiles updated. Close and re-open Vim to update your environment."
  endif
enddef

augroup DOTFILES_PULL
  autocmd!
  autocmd VimEnter * PullDotfiles()
augroup END

def PushDotfiles()
  # Pull first, in case there has been some change in the remote
  if !empty(systemlist($'git -C {$HOME}/dotfiles pull')
      ->filter('v:val =~ "CONFLICT"'))
    # Needed to prevent Vim to automatically quit
    input('You have conflicts in ~/dotfiles. Nothing will be pushed.')
  # If I changed some dotfiles I want to push them to the remote
  elseif !empty(systemlist($'git -C {$HOME}/dotfiles status')
        ->filter('v:val =~ "Changes not staged for commit\\|Changes to be committed"'))
    exe $'!git -C {$HOME}/dotfiles add -u'
    exe $'!git -C {$HOME}/dotfiles ci -m "Auto pushing ~/dotfiles... "'
    exe $'!git -C {$HOME}/dotfiles push'
  endif
enddef

augroup DOTFILES_PUSH
  autocmd!
  autocmd VimLeavePre * PushDotfiles()
augroup END

# Opposite of J, i.e. split from current cursor position
nnoremap S i<cr><esc>
# <ScriptCmd> allows remapping to functions without the need of defining
# them as g:.
nnoremap <c-w>q <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <c-w><c-q> <ScriptCmd>myfunctions.QuitWindow()<cr>
nnoremap <s-tab> <cmd>bprev <cr>
nnoremap <leader>b :b <tab>
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

# Wipe buffer
nnoremap <c-d> <cmd>bw!<cr>

# Formatting
# command! -range=% Prettify myfunctions.Prettify(<line1>, <line2>)
nnoremap Q <ScriptCmd>myfunctions.FormatWithoutMoving()<cr>
xnoremap Q <esc><ScriptCmd>myfunctions.FormatWithoutMoving(line("'<"), line("'>"))<cr>

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

# vim-plug
# ----------------
plug#begin(g:dotvim .. "/plugins/")
Plug 'junegunn/vim-plug' # For getting the help, :h plug-options
Plug 'sainnhe/everforest'
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
Plug 'ubaldot/vim-latex-tools'
Plug 'ubaldot/vim-git-master'
# Plug 'ubaldot/vim-conda-activate'
Plug 'girishji/easyjump.vim'
Plug 'puremourning/vimspector'
Plug 'ubaldot/vimspector'
# Plug 'habamax/vim-rst'
plug#end()
filetype plugin on
filetype indent on
syntax on

# Bundled plugins
packadd comment
g:termdebug_config = {}
packadd! termdebug
# source $HOME/vim_my_fork/vim/runtime/pack/dist/opt/termdebug/plugin/termdebug.vim

augroup SET_HEADERS_AS_C_FILETYPE
  autocmd!
  autocmd BufRead,BufNewFile *.h set filetype=c
augroup END

# Plugins settings
# -----------------
# everforest colorscheme
var hour = str2nr(strftime("%H"))
if hour < 7 || 14 < hour
  set background=dark
  colorscheme everforest
else
  set background=light
  colorscheme wildcharm
endif
# set background=dark
g:everforest_background = 'medium'
# colorscheme solarized8_flat
# colorscheme everforest

# vim-git-essentials
nnoremap git <Cmd>GitMasterStatus<cr>

# vim-poptools
g:poptools_config = {}
g:poptools_config['preview_recent_files'] = false
g:poptools_config['preview_buffer'] = false
# g:poptools_config['preview_syntax'] = false

nnoremap <c-p> <cmd>PoptoolsFindFile<cr>
nnoremap <c-g> <cmd>PoptoolsGrepInBuffer<cr>
# Copy in the selected text into t register ad leave it. Who cares about the t
# register?
xnoremap <c-g> "ty<cmd>exe $"PoptoolsGrepInBuffer {getreg('t')}"<cr>
nnoremap <c-p>å <cmd>PoptoolsBuffers<cr>
nnoremap <c-g><c-g> <cmd>PoptoolsGrep<cr>
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

# Vim9-conversion-aid
g:vim9_conversion_aid_fix_let = true
g:vim9_conversion_aid_fix_asl = true

# vim-outline
g:outline_autoclose = false

# Plugin settings
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
exe "source " .. g:dotvim .. "/plugins_settings/microdebugger_settings.vim"
exe "source " .. g:dotvim .. "/plugins_settings/vimspector_settings.vim"

nnoremap <leader>z <ScriptCmd>Open_special('i"')<cr>

# vim-manim setup
var manim_common_flags = '--fps 30 --disable_caching -v WARNING --save_sections'
g:manim_flags = {
  low_quality: $"-pql {manim_common_flags}",
  high_quality: $"-pqh -c ~/Documents/YouTube/ControlTheoryInPractice/github_ctip/ctip_manim.cfg {manim_common_flags}",
  dry_run: $'--dry_run {manim_common_flags}',
  transparent: $"-pqh -c ~/Documents/YouTube/ControlTheoryInPractice/github_ctip/ctip_manim.cfg {manim_common_flags} --transparent"
}
g:manim_default_flag = keys(g:manim_flags)[-1]

if g:os == "Darwin"
  augroup CLOSE_QUICKTIME
    autocmd!
    autocmd! User ManimPre exe "!osascript ~/QuickTimeClose.scpt"
  augroup END
endif

# Manim commands
# To make docs go to manim/docs and run make html. Be sure that all the
# sphinx
# extensions packages are installed.
# TODO Make it working with Windows

# command ManimDocs silent :!open -a safari.app
#             \ ~/Documents/manimce-latest/index.html

command ManimNew :enew | :0read ~/.manim/new_manim.txt
command ManimHelpVMobjs exe "HelpMe " .. g:dotvim ..
      \ "/helpme_files/manim_vmobjects.txt"
command ManimHelpTex exe "HelpMe " .. g:dotvim ..
      \ "/helpme_files/manim_tex.txt"
command ManimHelpUpdaters exe "HelpMe " .. g:dotvim ..
      \ "/helpme_files/manim_updaters.txt"
command ManimHelpTransform exe "HelpMe " .. g:dotvim
      \ .. "/helpme_files/manim_transform.txt"


# HelpMe files for my poor memory
var help_me_loc = $"{g:dotvim}/helpme_files/"
command! HelpmeBasic exe $"HelpMe {help_me_loc}/vim_basic.txt"
command! HelpmeScript exe $"HelpMe {help_me_loc}/vim_scripting.txt"
command! HelpmeGlobal exe $"HelpMe {help_me_loc}/vim_global.txt"
command! HelpmeExCommands exe $"HelpMe {help_me_loc}/vim_excommands.txt"
command! HelpmeSubstitute exe $"HelpMe {help_me_loc}/vim_substitute.txt"
command! HelpmeUnitTests exe $"HelpMe {help_me_loc}/vim_unit_tests.txt"
command! HelpmeAdvanced exe $"HelpMe {help_me_loc}/vim_advanced.txt"
command! HelpmeDiffMerge exe $"HelpMe {help_me_loc}/vim_merge_diff.txt"
command! HelpmeCoding exe $"HelpMe {help_me_loc}/vim_coding.txt"
command! HelpmeClosures exe $"HelpMe {help_me_loc}/python_closures.txt"
command! HelpmeDebug exe $"HelpMe {help_me_loc}/vim_debug.txt"
command! HelpmeVimspector exe $"HelpMe {help_me_loc}/vim_vimspector.txt"

# vim-replica stuff
# ----------------------------------
g:replica_console_position = "J"
g:replica_display_range  = false
g:replica_console_height = &lines / 4
g:replica_console_height = 20
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
nnoremap <expr> gl &diff ? ':diffget LOCAL<CR>' : 'gl'
nnoremap <expr> gr &diff ? ':diffget REMOTE<CR>' : 'gr'

command! ColorsToggle myfunctions.ColorsToggle()

# Utils commands
command! -nargs=1 -complete=command -range Redir
      \ silent myfunctions.Redir(<q-args>, <range>, <line1>, <line2>)

# Activity log
#
var work_log_path = '/mnt/c/Users/yt75534/OneDrive\ -\ Volvo\ Group/work_log.txt'
var day_string = strftime("=== %b %d %y ==========")
if g:os == "Windows"
  work_log_path = 'C:\Users\yt75534/OneDrive\ -\ Volvo\ Group/work_log.txt'
endif
command! LLogNewDay  exe "LLogOpen" | append(line('$'), day_string) | norm! G0r<cr>
command! LLogOpen exe $'edit {work_log_path}' | norm! G

# vip = visual inside paragraph
# This is used for preparing a text file for the caption to be sent to
# YouTube.
