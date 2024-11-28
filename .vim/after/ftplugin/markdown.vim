vim9script

import g:dotvim .. "/lib/myfunctions.vim"
setlocal iskeyword-=_
&l:tabstop = 2

# Bold, italic, strikethrough
xnoremap <buffer> <silent> <leader>** <esc><ScriptCmd>myfunctions.Surround('**', '**')<cr>
xnoremap <buffer> <silent> <leader>* <esc><ScriptCmd>myfunctions.Surround('*', '*')<cr>
xnoremap <buffer> <silent> <leader>~ <esc><ScriptCmd>myfunctions.Surround('~~', '~~')<cr>

inoremap ä `

if executable('prettier')
  &l:formatprg = $"prettier --prose-wrap always --print-width {&l:textwidth}
            \ --stdin-filepath {shellescape(expand('%'))}"

  # Autocmd to format with ruff
  augroup MARKDOWN_FORMAT_ON_SAVE
      autocmd! * <buffer>
      autocmd BufWritePre <buffer> myfunctions.FormatWithoutMoving()
  augroup END
else
   echoerr "'prettier' not installed!'"
endif

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

export def MarkdownRender(format = "html")
  var input_file = expand('%:p')
  var output_file = $'{expand('%:p:r')}.{format}'
  var css_style = ""
  if format ==# 'html'
    css_style = "-c ~/dotfiles/my_css_style.css"
  endif
  silent exe $"make {input_file} -o {output_file} -s {css_style}"

  var open_file_cmd = $'{g:start_cmd} {shellescape(output_file)}'
    ->substitute("'", "", "g")
  # echom open_file_cmd
  job_start(open_file_cmd)
enddef

export def MarkdownRenderCompleteList(A: any, L: any, P: any): list<string>
  return ['html', 'docx', 'pdf', 'txt', 'jira', 'csv', 'ipynb', 'latex',
    'odt', 'rtf']
enddef

# Usage :MarkdownRender, :MarkdownRender pdf, :MarkdownRender docx, etc
command! -nargs=? -buffer -complete=customlist,MarkdownRenderCompleteList MarkdownRender MarkdownRender(<f-args>)
