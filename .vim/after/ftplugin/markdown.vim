vim9script

# This is very ugly: you add a - [ ] by pasting the content of register 'o'
setreg("o", "- [ ] ")

def OpenNewLine(): string
  const a = getline('.')
  if a =~ '\v^\s*(-|\*|-\s*\[\s*\]|-\s*\[\s*x\s*\])'
    return $"A\<cr>{a->matchstr('^\W*')}"
  else
    return "o"
  endif
enddef

import autoload "mde_funcs.vim"
setlocal completeopt=menu,menuone,noselect
setlocal omnifunc=mde_funcs.OmniFunc
inoremap <buffer> [ [<C-x><C-o>
nnoremap <buffer> <expr> o OpenNewLine()

def MarkdownStrikeLine()
    const curpos = getcursorcharpos()
    execute "normal! \<s-V>"
    execute "normal! \<Plug>MarkdownStrike"
    cursor(curpos[1], curpos[2] + 2)
enddef

def MarkdownBoldLine()
    const curpos = getcursorcharpos()
    execute "normal! \<s-V>"
    execute "normal! \<Plug>MarkdownBold"
    cursor(curpos[1], curpos[2] + 2)
enddef

def MarkdownItalicLine()
    const curpos = getcursorcharpos()
    execute "normal! \<s-V>"
    execute "normal! \<Plug>MarkdownItalic"
    cursor(curpos[1], curpos[2] + 1)
enddef

def MarkdownHighlightLine()
    const curpos = getcursorcharpos()
    execute "normal! \<s-V>"
    execute "normal! \<Plug>MarkdownHighlight"
    cursor(curpos[1], curpos[2])
enddef

def MarkdownUnderlineLine()
    const curpos = getcursorcharpos()
    execute "normal! \<s-V>"
    execute "normal! \<Plug>MarkdownUnderline"
    cursor(curpos[1], curpos[2] + 3)
enddef

nnoremap <localleader>S <ScriptCmd>MarkdownStrikeLine()<cr>
nnoremap <localleader>B <ScriptCmd>MarkdownBoldLine()<cr>
nnoremap <localleader>I <ScriptCmd>MarkdownItalicLine()<cr>
nnoremap <localleader>H <ScriptCmd>MarkdownHighlightLine()<cr>
nnoremap <localleader>U <ScriptCmd>MarkdownUnderlineLine()<cr>
