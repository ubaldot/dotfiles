vim9script

# Autocmd to format with something
if exists(':LspFormat')
  augroup FORMAT
    autocmd! * <buffer>
    autocmd BufWritePost <buffer> :LspFormat
  augroup END
endif
