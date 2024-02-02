vim9script

# For auto-completion, jumps to definitions, etc
# you can either use ctags or LSP.
# gutentags automatically creates ctags as you open files
# so you don't need to create them manually.

if has("gui_win32") || has("win32")
    g:dotvim = $HOME .. "\\vimfiles"
    &pythonthreehome = $HOME .. "\\Miniconda3"
    &pythonthreedll = $HOME .. "\\Miniconda3\\python39.dll"
elseif has("mac")
    g:dotvim = $HOME .. "/.vim"
    &pythonthreehome = fnamemodify(trim(system("which python")), ":h:h")
    &pythonthreedll = trim(system("which python"))
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

# augroup CommandWindowOpen
#     autocmd!
#     autocmd CmdwinEnter * map <buffer> <cr> <cr>q:
# augroup END


# Open help pages in vertical split
# augroup vimrc_help
#     autocmd!
#     autocmd BufEnter *.txt if &buftype == 'help' | wincmd H | endif
# augroup END
#
# Internal vim variables aka 'options'
# Set terminal with 256 colors
set encoding=utf-8
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
set cursorline
set diffopt+=iwhite

# Some key bindings
# ----------------------
g:mapleader = ","
map <leader>vr <Cmd>source $MYVIMRC<cr> \| <Cmd>echo ".vimrc reloaded."
map <leader>vv <Cmd>e $MYVIMRC<cr>

def QuitWindow()
    # Close window and wipe buffer but it prevent to quit Vim if one window is
    # left.
   if winnr('$') != 1
      quit
   endif
enddef

# For using up and down in popup menu
# inoremap <expr><Down> pumvisible() ? "\<C-n>" : "\<Down>"
# inoremap <expr><Up> pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <cr> pumvisible() ? "\<C-Y>" : "\<cr>"

# Avoid polluting registers
nnoremap x "_x
# <ScriptCmd> allows remapping to functions without the need of defining
# them as g:.
nnoremap <c-w>q <ScriptCmd>call QuitWindow()<cr>
nnoremap <c-w><c-q> <ScriptCmd>call QuitWindow()<cr>
nnoremap <leader>b <Cmd>ls!<cr>:b
nnoremap <c-tab> :b <tab>
nnoremap <s-tab> <Cmd>b#<cr>
# nnoremap <c-tab> <Plug>Bufselect_Toggle
# nnoremap <C-tab> <Plug>(FileselectToggle)
nnoremap <tab> <Cmd>bnext<cr>
# nnoremap <s-tab> <Cmd>bprev<cr>
# nnoremap <leader>c <C-w>c<cr>
noremap <c-PageDown> <Cmd>bprev<cr>
noremap <c-PageUp> <Cmd>bnext<cr>
# Switch window
# nnoremap <C-w>w :bp<cr>:bw! #<cr>
# nnoremap <leader>w <Cmd>bp<cr><Cmd>bw! #<cr>
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j
# Switch window with arrows
# nnoremap <c-Left> <C-w>h<cr>
# nnoremap <c-Right> <C-w>l<cr>

# super quick search and replace:
nnoremap <Space><Space> :%s/\<<C-r>=expand("<cword>")<cr>\>/
# to be able to undo accidental c-w"
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
# Automatically surround highlighted selection
# xnoremap ( <ESC>`>a)<ESC>`<i(<ESC>
# xnoremap ) <ESC>`>a)<ESC>`<i(<ESC>
# xnoremap [ <ESC>`>a]<ESC>`<i[<ESC>
# xnoremap ] <ESC>`>a]<ESC>`<i[<ESC>
# xnoremap { <ESC>`>a}<ESC>`<i{<ESC>
# xnoremap } <ESC>`>a}<ESC>`<i{<ESC>
# Don't use the following otherwise you lose registers function!
# Indent without leaving the cursor position
nnoremap g= <Cmd>vim9cmd b:temp = winsaveview()<cr>gg=G
            \ <Cmd>vim9cmd winrestview(b:temp)<cr>
            \ <Cmd>vim9cmd unlet b:temp<cr>
            \ <Cmd>echo "file indented"<cr>

# Format text
nnoremap g- <Cmd>vim9cmd b:temp = winsaveview()<cr>gggqG
            \ <Cmd>vim9cmd winrestview(b:temp)<cr>
            \ <Cmd>vim9cmd unlet b:temp<cr>
            \ <Cmd>echo "file formatted, textwidth: "
            \ .. &textwidth .. " cols."<cr>

# TERMINAL IN BUFFER (NO POPUP)
# Some terminal remapping
# When using iPython to avoid that shift space gives 32;2u
tnoremap <S-space> <space>
tnoremap <ESC> <c-w>N
tnoremap <c-h> <c-w>h
tnoremap <c-l> <c-w>l
tnoremap <c-k> <c-w>k
tnoremap <c-j> <c-w>j
tnoremap <s-tab> <cmd>bnext<cr>
# tnoremap <s-tab> <cmd>bprev<cr>
tnoremap <c-tab> <c-w>:b <tab>
# tnoremap <leader>b <c-w>:b <tab>
# tnoremap <leader>l :ls!<cr>:b

# TERMINAL IN POPUP
# This function can be called only from a terminal windows/popup, so there is
# no risk of closing unwanted popups (such as HelpMe popups).
def Quit_term_popup(quit: bool)
    if empty(popup_list())
        if quit
           exe "quit"
        else
            exe "close"
        endif
    else
        if quit
            var bufno = bufnr()
            popup_close(win_getid())
            exe "bw! " .. bufno
        else
            popup_close(win_getid())
        endif
    endif
enddef


tnoremap <c-w>q <ScriptCmd>Quit_term_popup(true)<cr>
tnoremap <c-w>c <ScriptCmd>Quit_term_popup(false)<cr>

# Make vim to speak
if has('mac')
    # <esc> is used in xnoremap because '<,'> are updated once you leave visual mode
    xnoremap <leader>s <esc><ScriptCmd>TextToSpeech(line("'<"), line("'>"))<cr>
    command -range Say vim9cmd TextToSpeech(<line1>, <line2>)

    def TextToSpeech(firstline: number, lastline: number)
        exe $":{firstline},{lastline}w !say"
    enddef
endif

# def TextToSpeech(firstline: number, lastline: number)
#     exe $":{firstline},{lastline}w !say"
# enddef


# Open terminal below all windows
exe "cabbrev bter bo terminal " .. &shell
exe "cabbrev vter vert botright terminal " .. &shell


# vim-plug
# ----------------
plug#begin(g:dotvim .. "/plugins/")
Plug 'junegunn/vim-plug' # For getting the help, :h plug-options
Plug 'sainnhe/everforest'
Plug 'preservim/nerdtree'
# Plug 'yegappan/bufselect'
Plug 'yegappan/lsp'
# TODO enable plugin when matchbufline becomes available
# Plug "yegappan/searchcomplete"
# Plug 'normen/vim-pio'
# Plug 'stevearc/vim-arduino'
# # Plug 'ludovicchabant/vim-gutentags'
Plug 'tpope/vim-commentary'
# # Plug 'tpope/vim-scriptease'
Plug 'ubaldot/vim-highlight-yanked'
# Plug 'ubaldot/vim-conda-activate'
Plug 'ubaldot/vim-helpme'
Plug 'ubaldot/vim-outline'
Plug 'ubaldot/vim-replica'
# Plug 'ubaldot/vim-writegood'
Plug 'bpstahlman/txtfmt'
# Plug 'hungpham3112/vide'
#
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
if hour < 7 || 14 < hour
    set background=dark
else
    set background=light
endif
g:everforest_background = 'soft'
colorscheme everforest


# txtfmt settings
# TODO fix this and change the Shortcuts with R Y and G rather than r,y,g
g:txtfmtBgcolor2 = '^R$,c:LightRed,g:' .. matchstr(execute('highlight DiffDelete'), 'guibg=\zs#\x\+')
g:txtfmtBgcolor3 = '^Y$,c:LightYellow,g:' .. matchstr(execute('highlight DiffChange'), 'guibg=\zs#\x\+')
g:txtfmtBgcolor5 = '^G$,c:LightGreen,g:' .. matchstr(execute('highlight DiffAdd'), 'guibg=\zs#\x\+')

g:txtfmtShortcuts = []

# Note: Shortcuts that don't specify modes will get select mode mappings if and only if txtfmtShortcutsWorkInSelect=1.
# bold-underline (\u for Visual and Operator)
add(g:txtfmtShortcuts, 'h1 kR')
add(g:txtfmtShortcuts, 'h2 kY')
add(g:txtfmtShortcuts, 'h3 kG')
add(g:txtfmtShortcuts, 'hh k-')

augroup SetTxtFmt
    autocmd!
    autocmd BufRead,BufNewFile *.txt set filetype=text.txtfmt
    autocmd BufRead,BufNewFile *.md set filetype=markdown.txtfmt
augroup END

augroup SetHeadersAsC
    autocmd!
    autocmd BufRead,BufNewFile *.h set filetype=c
augroup END

# Delete MakeTestPage so when typing :Ma I get Manim as first hit
augroup deletePluginCommand
    autocmd!
    autocmd VimEnter * delcommand MakeTestPage
augroup END

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

def ShowFuncName(): string
  var n_max = 20 # max chars to be displayed.
  var filetypes = ['c', 'cpp', 'python']
  var text = "" # displayed text

  if index(filetypes, &filetype) != -1
      # If the filetype is recognized, then search the function line
      var line = 0
      if index(['c', 'cpp'], &filetype) != -1
          line = search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bWn')
      elseif &filetype ==# 'python'
          line = search("^ \\{0,}def \\+.*", 'bWn')
      endif
      var n = match(getline(line), '\zs)') # Number of chars until ')'
      if n < n_max
          text = "|" .. trim(getline(line)[: n])
      else
          text = "|" .. trim(getline(line)[: n_max]) .. "..."
      endif
  endif
  return text
enddef

augroup show_funcname
  autocmd!
  autocmd BufEnter,BufWinEnter,CursorMoved * b:current_function = ShowFuncName()
augroup end


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
    autocmd VimEnter,BufEnter,BufWinEnter * g:conda_env = Conda_env()
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
set statusline+=%#StatusLine#\ %t(%n)%m%*
set statusline+=%#StatusLineNC#\%{b:current_function}\ %*
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
    autocmd DirChanged global myfunctions.ChangeTerminalDir()
augroup END
# Close NERDTree when opening a file
g:NERDTreeQuitOnOpen = 1


# This json-like style to encode configs like
# pylsp.plugins.pycodestyle.enabled = true
var pylsp_config = {
    'pylsp': {
        'plugins': {
            'pycodestyle': {
                'enabled': false},
            'pyflakes': {
                'enabled': true},
            'pydocstyle': {
                'enabled': false},
            'autopep8': {
                'enabled': false}, }, }, }


# path: trim(system('where pylsp')),
        # workspaceConfig: pylsp_config,
var lspServers = [
    {
        name: 'pylsp',
        filetype: ['python'],
        path: 'pylsp',
        workspaceConfig: pylsp_config,
        args: ['--check-parent-process', '-v'],
    },
    {
        name: 'clangd',
        filetype: ['c', 'cpp'],
        path: 'clangd',
        args: ['--background-index', '--clang-tidy', '-header-insertion=never']
    },
]

autocmd VimEnter * g:LspAddServer(lspServers)

var lspOpts = {'showDiagOnStatusLine': true, 'noNewlineInCompletion': true}
autocmd VimEnter * g:LspOptionsSet(lspOpts)
highlight link LspDiagLine NONE

nnoremap <silent> <leader>p <Cmd>LspDiag prev<cr>
nnoremap <silent> <leader>n <Cmd>LspDiag next<cr>
nnoremap <silent> <leader>d <Cmd>LspDiag current<cr>
nnoremap <silent> <leader>i <Cmd>LspGotoImpl<cr>
nnoremap <silent> <leader>k <Cmd>LspHover<cr>
nnoremap <silent> <leader>g <Cmd>LspGotoDefinition<cr>
nnoremap <silent> <leader>r <Cmd>LspPeekReferences<cr>


# HelpMe files for my poor memory
command! HelpmeBasic exe "HelpMe " .. g:dotvim .. "/helpme_files/vim_basic.txt"
command! HelpmeScript exe "HelpMe" .. g:dotvim .. "/helpme_files/vim_scripting.txt"
command! HelpmeGlobal exe "HelpMe" .. g:dotvim ..  "/helpme_files/vim_global.txt"
command! HelpmeExCommands exe "HelpMe" .. g:dotvim .. "/helpme_files/vim_excommands.txt"
command! HelpmeSubstitute exe "HelpMe" .. g:dotvim .. "/helpme_files/vim_substitute.txt"
command! HelpmeAdvanced exe "HelpMe" .. g:dotvim .. "/helpme_files/vim_advanced.txt"
command! HelpmeNERDTree exe "HelpMe" .. g:dotvim .. "/helpme_files/vim_nerdtree.txt"
command! HelpmeDiffMerge exe "HelpMe" .. g:dotvim .. "/helpme_files/vim_merge_diff.txt"
command! HelpmeCoding exe "HelpMe" .. g:dotvim .. "/helpme_files/vim_coding.txt"
command! HelpmeClosures exe "HelpMe" .. g:dotvim .. "/helpme_files/python_closures.txt"
command! HelpmeDebug exe "HelpMe" .. g:dotvim .. "/helpme_files/vim_debug.txt"

command! ColorsToggle myfunctions.ColorsToggle()

# Utils commands
command! -nargs=1 -complete=command -range Redir
            \ silent myfunctions.Redir(<q-args>, <range>, <line1>, <line2>)

# Source additional files
# source $HOME/PE.vim
# source $HOME/VAS.vim
# source $HOME/dymoval.vim

# vim-replica stuff
# g:replica_console_position = "J"
# g:replica_console_height = 10
g:replica_display_range  = false
g:replica_python_options = "-Xfrozen_modules=off"
g:replica_jupyter_console_options = {"python":
            \ " --config ~/.jupyter/jupyter_console_config.py"}

# g:writegood_compiler = "vale"
# g:writegood_options = "--config=$HOME/vale.ini"

g:use_black = true


# Self-defined functions
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

augroup shoutoff_terminals
    autocmd QuitPre * call myfunctions.WipeoutTerminals()
augroup END

# Manim commands
# To make docs go to manim/docs and run make html. Be sure that all the sphinx
# extensions packages are installed.
command ManimDocs silent :!open -a safari.app
            \ ~/Documents/manimce-latest/index.html
command ManimNew :enew | :0read ~/.manim/new_manim.txt
command ManimHelpVMobjs :HelpMe ~/.vim/helpme_files/manim_vmobjects.txt
command ManimHelpTex :HelpMe ~/.vim/helpme_files/manim_tex.txt
command ManimHelpUpdaters :HelpMe ~/.vim/helpme_files/manim_updaters.txt
command ManimHelpTransform :HelpMe ~/.vim/helpme_files/manim_transform.txt

command! Terminal myfunctions.OpenMyTerminal()
# xnoremap h1 <Plug>Highlight<cr>
# noremap <leader><s-tab> :buffers t<cr>:filter // buffers t <bar> call feedkeys(':buffer ')<home><s-right><s-right><left>

# vip = visual inside paragraph
# This is used for preparing a text file for the caption to be sent to
# YouTube.
command! JoinParagraphs v/^$/norm! vipJ

# Termdebug stuff
# Call as Termdebug build/myfile.elf

g:termdebug_config = {}

var debugger_path = "/Applications/STM32CubeIDE.app/Contents/Eclipse/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.11.3.rel1.macos64_1.1.100.202310310803/tools/bin/"
var debugger = "arm-none-eabi-gdb"

var opendocd_script = "openocd_stm32f4x_stlink.sh"

g:termdebug_config['command'] = [debugger_path .. debugger, "-x", "../gdb_init_commands.txt"]
g:termdebug_config['variables_window'] = 1


packadd Termdebug
def MyTermdebug()
    # The .elf name is supposed to be the same as the folder name.
    # Before calling this function you must launch a openocd server.
    # This happens inside this script with

    #   source ../openocd_stm32f4x_stlink.sh
    #
    # Then Termdebug is launched.
    # When Termdebug is closed, then the server is automatically shutoff

    # Start a openocd terminal

    var ii = term_start(&shell, {'term_name': 'OPENOCD', 'hidden': 1, 'term_finish': 'close'})
    term_sendkeys(ii, 'source ../' .. opendocd_script .. "\n")

    var filename = fnamemodify(getcwd(), ':t')
    execute "Termdebug build/" .. filename .. ".elf"
    execute "close " ..  bufwinnr("debugged program")
enddef

augroup OpenOCDShutdown
    autocmd!
    autocmd User TermdebugStopPost {
        for bufnum in term_list()
            if bufname(bufnum) ==# 'OPENOCD'
               execute "bw! " .. bufnum
            endif
        endfor
    }
augroup END

command! Debug vim9cmd MyTermdebug()
