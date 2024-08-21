vim9script

import g:dotvim .. "/lib/myfunctions.vim"
setlocal iskeyword-=_

# Bold, italic, strikethrough
xnoremap <buffer> <silent> bb <esc><ScriptCmd>myfunctions.Surround('**', '**')<cr>
xnoremap <buffer> <silent> ii <esc><ScriptCmd>myfunctions.Surround('_', '_')<cr>
xnoremap <buffer> <silent> ss <esc><ScriptCmd>myfunctions.Surround('~~', '~~')<cr>

if executable('pandoc')
  compiler pandoc
else
  echoerr "'pandoc' not installed. 'MarkdownRender' won't work"
endif

# if has('gui')
#   var fontsize = str2nr(matchstr(&guifont, '\v:h\zs(\d*)')) + 2
#   &l:guifont = "HackNF-Regular:h" .. string(fontsize)
#   # &l:guifont = "FiraCode-Regular:h" .. fontsize
# endif

def MarkdownRender(format = "html")
    var input_file = expand('%:p')
    var output_file = expand('%:p:r') .. "." .. format
    var css_style = ""
    if format ==# 'html'
        css_style = "-c ~/dotfiles/my_css_style.css"
    endif
    exe "make " .. input_file  .. " -o " ..  output_file .. " -s " .. css_style
    silent exe $'!{g:start_cmd} {shellescape(expand("%:r"))}.{format}'
enddef

# Usage :MarkdownRender, :MarkdownRender pdf, :MarkdownRender docx, etc
command! -nargs=? -buffer MarkdownRender MarkdownRender(<f-args>)
