vim9script

import g:dotvim .. "/lib/myfunctions.vim"
&l:tabstop = 2

# Bold, italic, strike-through, code
xnoremap <buffer> <silent> <leader>b
      \ <esc><ScriptCmd>myfunctions.VisualSurround('**', '**')<cr>
xnoremap <buffer> <silent> <leader>i
      \ <esc><ScriptCmd>myfunctions.Surround('*', '*')<cr>
xnoremap <buffer> <silent> <leader>s
      \ <esc><ScriptCmd>myfunctions.VisualSurround('~~', '~~')<cr>
xnoremap <buffer> <silent> <leader>c
      \ <esc><ScriptCmd>myfunctions.VisualSurround('`', '`')<cr>
# After you run the following you may run prettier to make it nicer.


xnoremap <buffer> <silent> <leader>cc
      \ <esc><ScriptCmd>myfunctions.ToggleBlock('```', line("'<"), line("'>"))<cr>
# ---- Not a nice part end ------

inoremap <buffer> <silent> <CR> <ScriptCmd>myfunctions.MDContinueList()<CR>

# This is very ugly: you add a - [ ] by pasting the content of register 'o'
setreg("o", "- [ ] ")

if exists(':OutlineToggle') != 0
  nnoremap <buffer> <silent> <leader>o <Cmd>OutlineToggle ^- [ <cr>
endif

inoremap ä `

if executable('prettier')
  &l:formatprg = $"prettier --prose-wrap always --print-width {&l:textwidth} "
        .. $"--stdin-filepath {shellescape(expand('%'))}"

  # Autocmd to format with ruff
  augroup MARKDOWN_FORMAT_ON_SAVE
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> myfunctions.FormatWithoutMoving()
  augroup END
else
  echoerr "'prettier' not installed!'"
endif

export def Make(format = "html")
  if executable('pandoc')
    var input_file = expand('%:p')
    var output_file = $'{expand('%:p:r')}.{format}'
    var css_style = ""
    if format ==# 'html'
      css_style = $"-c {$HOME}/dotfiles/my_css_style.css"
    endif

    &l:makeprg = $'pandoc --standalone --metadata title="{expand("%:t")}"'
                    .. $'--from=markdown --css={css_style} '
                    .. $'--output "{output_file}" "{input_file}"'
    make
    echom &l:makeprg

    if exists(':Open') != 0
      exe $'Open {output_file}'
    else
      var open_file_cmd = $'{g:start_cmd} {shellescape(output_file)}'
        ->substitute("'", "", "g")
      job_start(open_file_cmd)
    endif
  else
    echoerr "'pandoc' not installed. 'Make' won't work"
  endif
enddef

export def MakeCompleteList(A: any, L: any, P: any): list<string>
  return ['html', 'docx', 'pdf', 'txt', 'jira', 'csv', 'ipynb', 'latex',
    'odt', 'rtf']
enddef

# Note taking
nnoremap <buffer> <silent> <leader>x <ScriptCmd>myfunctions.MDToggleMark()<cr>
nnoremap <buffer> <silent> <enter> <ScriptCmd>myfunctions.MDHandleLink()<cr>
nnoremap <buffer> <silent> <backspace> <ScriptCmd>myfunctions.MDRemoveLink()<cr>

# Usage :Make, :Make pdf, :Make docx, etc
command! -nargs=? -buffer -complete=customlist,MakeCompleteList
      \ Make Make(<f-args>)
