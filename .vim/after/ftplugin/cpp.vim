vim9script

if exists(':LspFormat')
  augroup FORMAT
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> :LspFormat
  augroup END
endif

def FilterOutline(outline: list<string>): list<string>
  return outline
        \ ->filter("v:val =~ "
        \ .. string(join(g:outline_pattern_to_include["cpp"], '\|')))
enddef

b:FilterOutline = FilterOutline
