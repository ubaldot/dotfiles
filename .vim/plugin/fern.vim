vim9script

# Fern
# ------------
# Disable netrw.
g:loaded_netrw  = 1
g:loaded_netrwPlugin = 1
g:loaded_netrwSettings = 1
g:loaded_netrwFileHandlers = 1

def Hijack_directory()
  var path = expand('%:p')
  if !isdirectory(path)
    return
  endif
  bwipeout %
  execute printf('Fern %s', fnameescape(path))
enddef

augroup my-fern-hijack
  autocmd!
  autocmd BufEnter * ++nested Hijack_directory()
augroup END

# Custom settings and mappings.
g:fern#disable_default_mappings = 1


g:fern#renderer#default#leading = "  "
g:fern#renderer#default#leaf_symbol = ""
g:fern#renderer#default#collapsed_symbol = "+"
g:fern#renderer#default#expanded_symbol = "-"

# TODO: may remap <f1> somewhere
noremap <silent> <space> <cmd>Fern . -drawer -reveal=% -toggle -width=28<CR><C-w>=

def FernInit()
  nmap <buffer><expr>
        \ <Plug>(fern-my-open-expand-collapse)
        \ fern#smart#leaf(
        \   "\<Plug>(fern-action-open:select)",
        \   "\<Plug>(fern-action-expand)",
        \   "\<Plug>(fern-action-collapse)",
        \ )
  nmap <buffer> <CR> <Plug>(fern-my-open-expand-collapse)
  nmap <buffer> <2-LeftMouse> <Plug>(fern-my-open-expand-collapse)
  nmap <buffer> n <Plug>(fern-action-new-path)
  nmap <buffer> d <Plug>(fern-action-remove)
  nmap <buffer> m <Plug>(fern-action-move)
  nmap <buffer> M <Plug>(fern-action-rename)
  nmap <buffer> h <Plug>(fern-action-hidden)
  nmap <buffer> r <Plug>(fern-action-reload)
  nmap <buffer> o <Plug>(fern-action-mark)
  nmap <buffer> b <Plug>(fern-action-open:split)
  nmap <buffer> v <Plug>(fern-action-open:vsplit)
  nmap <buffer><nowait> < <Plug>(fern-action-leave)<Cmd>pwd<cr>
  nmap <buffer><nowait> > <Plug>(fern-action-enter)<Cmd>pwd<cr>
  nmap <buffer><nowait> cd <Plug>(fern-action-enter)<Plug>(fern-action-cd:cursor)<Cmd>pwd<cr>
  nmap <buffer><expr>
        \ <Plug>(fern-cr-mapping)
        \ fern#smart#root(
        \   "<Plug>(fern-action-leave)",
        \   "<Plug>(fern-my-open-expand-collapse)",
        \ )
  nmap <buffer> <CR> <Plug>(fern-cr-mapping)
  nmap <buffer> O <Plug>(fern-action-ex=)Open<CR>
  nmap <buffer> <right> <c-w>>
  nmap <buffer> <left> <c-w><
  setlocal nonumber
enddef

augroup FernGroup
  autocmd!
  autocmd FileType fern FernInit()
augroup END
