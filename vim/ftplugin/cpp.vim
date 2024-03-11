vim9script


# Autocmd to format with black.
augroup FORMAT
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> :LspFormat
augroup END

def FilterOutline(outline: list<string>): list<string>
        return outline
                \ ->filter("v:val =~ "
                \ .. string(join(g:outline_pattern_to_include["cpp"], '\|')))
enddef

b:FilterOutline = FilterOutline
