vim9script

if !exists('g:replica_config')
  g:replica_config = {
      console_position: "L",
      display_range: false,
      debug: true,
      log_level: 'Debug',
      display_variables: 'tab'
  }
endif

nnoremap <silent> <c-enter> <Plug>ReplicaSendCell<cr>
nnoremap <silent> <s-enter> <Plug>ReplicaSendFile<cr>
nnoremap <silent> <F9> <Plug>ReplicaSendLines<cr>
xnoremap <silent> <F9> <Plug>ReplicaSendLines<cr>
