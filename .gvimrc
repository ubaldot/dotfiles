vim9script

# -----------------------------------
# This file is sourced AFTER .vimrc
# -----------------------------------
set mousehide

# Set fonts for gvim
# fontsize = 11 with the 14'' MacBook you have exactly two columns
# with textwidth = 78
var fontsize = 14
var fontface = "Arial"
var fontsize_tail = ""

if has("gui_win32")
     fontsize = 14
     fontface = "Fira_Code:h"
     fontsize_tail = ":cANSI:qDRAFT"
     fontsize = 12
     set guioptions-=T
    # Open gvim in full-screen
    au GUIEnter * simalt ~x
elseif has("mac")
     fontsize_tail = ""
     fontface = "Fira\ Code:h"
else
     fontsize_tail = ""
     fontface = "Fira\ Code\ "

endif

&guifont = fontface .. string(fontsize) .. fontsize_tail

def ChangeFontsize(n: number)
    var old_redraw = &lazyredraw
    set lazyredraw

    fontsize = fontsize + n
    &guifont = fontface .. string(fontsize) .. fontsize_tail

    &lazyredraw = old_redraw
enddef

# Some key bindings
command! FontsizeIncrease vim9cmd ChangeFontsize(1)
command! FontsizeDecrease vim9cmd ChangeFontsize(-1)
