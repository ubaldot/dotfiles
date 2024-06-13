vim9script

# -----------------------------------
# This file is sourced AFTER .vimrc
# -----------------------------------
set mousehide
set guioptions+=!
set guioptions-=e

# Set fonts for gvim
# fontsize = 11 with the 14'' MacBook you have exactly two columns
# with textwidth = 78
var fontsize = 8
var fontface = "Arial"
var fontsize_tail = ""

if g:os == "Windows"
     fontsize = 10
     fontface = "Fira_Code:h"
     fontsize_tail = ":cANSI:qDRAFT"
     set guioptions-=T
    # Open gvim in full-screen
    au GUIEnter * simalt ~x
elseif g:os == "Darwin"
     fontsize_tail = ""
     fontface = "Fira\ Code:h"
else
    fontsize = 10
     set guioptions-=T
     set lines=48
     set columns=180
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

def GuiResize()
  var old_size = matchstr(v:option_old, '\d\+')
  var new_size = matchstr(v:option_new, '\d\+')
  var factor = str2float(new_size) / str2float(old_size)
  &columns = float2nr(&columns / factor)
  &lines = float2nr(&lines / factor)
enddef

augroup GUI_RESIZE
    autocmd!
    autocmd OptionSet guifont GuiResize()
augroup END

# Some key bindings
command! FontsizeIncrease vim9cmd ChangeFontsize(1)
command! FontsizeDecrease vim9cmd ChangeFontsize(-1)
command! -nargs=1 FontsizeChange vim9cmd ChangeFontsize(<args>)
