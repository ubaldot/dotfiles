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

setlocal completeopt=menu,menuone,noselect
setlocal omnifunc=MDEOmniFunc
inoremap <buffer> [ [<C-x><C-o>
nnoremap <buffer> <expr> o OpenNewLine()
