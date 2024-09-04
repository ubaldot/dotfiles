vim9script

import g:dotvim .. "/lib/myfunctions.vim"
setlocal iskeyword-=_

# Bold, italic, strikethrough
xnoremap <buffer> <silent> <c-b> <esc><ScriptCmd>myfunctions.Surround('**', '**')<cr>
xnoremap <buffer> <silent> <c-i> <esc><ScriptCmd>myfunctions.Surround('_', '_')<cr>
xnoremap <buffer> <silent> <c-s> <esc><ScriptCmd>myfunctions.Surround('~~', '~~')<cr>

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
    var output_file = $'{expand('%:p:r')}.{format}'
    var css_style = ""
    if format ==# 'html'
        css_style = "-c ~/dotfiles/my_css_style.css"
    endif
    silent exe $"make {input_file} -o {output_file} -s {css_style}"

    var open_file_cmd = $'{g:start_cmd} {shellescape(output_file)}'->substitute("'", "", "g")
    # echom open_file_cmd
    job_start(open_file_cmd)
enddef

def MarkdownRenderCompleteList(A: any, L: any, P: any): list<string>
  return ['html', 'docx', 'pdf', 'txt', 'jira', 'csv', 'ipynb', 'latex', 'odt', 'rtf']
enddef

# Usage :MarkdownRender, :MarkdownRender pdf, :MarkdownRender docx, etc
command! -nargs=? -buffer -complete=customlist,MarkdownRenderCompleteList MarkdownRender MarkdownRender(<f-args>)
