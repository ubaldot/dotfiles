vim9script

# Some good VIM notes
# ======================
# This file is sourced AFTER .vimrc
# ==========================

# The following does not work
# !echo $CONDA_DEFAULT_ENV won't show anything
# call system('source ~/.zshrc')
# call system('conda activate myenv')

# Set terminal with 256 colors
set termguicolors
set mousehide

# Set fonts for gvim
# In this way with the 14'' MacBook you have exactly two columns
# with textwidth = 78
g:fontsize = 13
if has("gui_win32")
     g:fontface = "FiraCode_NFM"
     g:fontsize_small = ":h8:cANSI:qDRAFT"
     g:fontsize_large = ":h11:cANSI:qDRAFT"
     set guioption-=T
    # Open gvim in full-screen
    au GUIEnter * simalt ~x
elseif has("gui_macvim")
    # set shell=zsh # to be able to source ~/.zshrc (conda init)
     # g:fontsize_small = ":h8"
     # g:fontsize_large = ":h14"
     g:fontface = "Fira\ Code:h"
endif
# guifont is reserved word (aka 'option')
&guifont = g:fontface .. string(g:fontsize)

def g:ChangeFontsize(n: number)
    g:fontsize = g:fontsize + n
    &guifont = g:fontface .. string(g:fontsize)
    echo "Fontsize: " .. string(g:fontsize)
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
