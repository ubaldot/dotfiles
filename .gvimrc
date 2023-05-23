vim9script

# Some good VIM notes
# ======================
# This file is sourced AFTER .vimrc
# ==========================

# The following does not work
# !echo $CONDA_DEFAULT_ENV won't show anything
# call system('source ~/.zshrc')
# call system('conda activate myenv')

set mousehide

# Set fonts for gvim
# In this way with the 14'' MacBook you have exactly two columns
# with textwidth = 78
g:fontsize = 13
if has("gui_win32")
     g:fontsize = 11
     g:fontface = "FiraCode_NFM:h"
     g:fontsize_tail = ":cANSI:qDRAFT"
     set guioptions-=T
    # Open gvim in full-screen
    au GUIEnter * simalt ~x
elseif has("gui_macvim")
    # set shell=zsh # to be able to source ~/.zshrc (conda init)
     g:fontsize_tail = ""
     g:fontface = "Fira\ Code:h"
endif
# guifont is reserved word (aka 'option')
&guifont = g:fontface .. string(g:fontsize) .. g:fontsize_tail

def g:ChangeFontsize(n: number)
    g:fontsize = g:fontsize + n
    &guifont = g:fontface .. string(g:fontsize) .. g:fontsize_tail
enddef

# Some key bindings
nnoremap  <c-c><c-i> :call g:ChangeFontsize(1)<cr>
nnoremap  <c-c><c-o> :call g:ChangeFontsize(-1)<cr>

# nnoremap <C-c><c-i> :silent! let &guifont = substitute(
#  \ &guifont,
#  \ ':h\zs\d\+',
#  \ '\=eval(submatch(0)+1)',
#  \ '')<CR>
# nnoremap <C-c><c-o> :silent! let &guifont = substitute(
#  \ &guifont,
#  \ ':h\zs\d\+',
#  \ '\=eval(submatch(0)-1)',
#  \ '')<CR>
