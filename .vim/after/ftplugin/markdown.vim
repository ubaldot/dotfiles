vim9script

inoremap ä `

def OpenNewLine(): string
  const a = getline('.')
  if a =~ '\v^\s*(-|\*|-\s*\[\s*\]|-\s*\[\s*x\s*\])'
    return $"A\<cr>{a->matchstr('^\W*')}"
  else
    return "o"
  endif
enddef

nnoremap <buffer> <expr> o OpenNewLine()
