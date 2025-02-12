vim9script

import g:dotvim .. "/after/ftplugin/markdown.vim"
setlocal iskeyword-=_
&l:tabstop = 3

# Bold, italic, strikethrough
xnoremap <buffer> <silent> <leader>** <esc><ScriptCmd>myfunctions.VisualSurround('**', '**')<cr>
xnoremap <buffer> <silent> <leader>* <esc><ScriptCmd>myfunctions.VisualSurround('*', '*')<cr>
xnoremap <buffer> <silent> <leader>~ <esc><ScriptCmd>myfunctions.VisualSurround('~~', '~~')<cr>

inoremap ä `

if executable('rstfmt')
  &l:formatprg = $"rstfmt -w {&l:textwidth}"
endif

if executable('pandoc')
  compiler pandoc
else
  echoerr "'pandoc' not installed. 'MarkdownRender' won't work"
endif

command! -nargs=? -buffer -complete=customlist,markdown.MarkdownRenderCompleteList RstRender markdown.MarkdownRender(<f-args>)
