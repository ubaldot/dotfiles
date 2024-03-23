vim9script

# Autocmd to format with black.
augroup FORMAT
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> :LspFormat
augroup END
