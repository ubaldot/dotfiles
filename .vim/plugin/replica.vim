vim9script

if !exists('g:replica_config')
  g:replica_config = {}
endif
g:replica_config.console_position = "L"
g:replica_config.display_range  = false
g:replica_config.debug = true
g:replica_config.log_level = 'Debug'
g:replica_config.display_variables = 'vsplit'
# g:replica_config.replica_console_height = 20
# g:replica_config.replica_console_height = max([&lines / 3, 4])
nnoremap <silent> <c-enter> <Plug>ReplicaSendCell<cr>
nnoremap <silent> <s-enter> <Plug>ReplicaSendFile<cr>
nnoremap <silent> <F9> <Plug>ReplicaSendLines<cr>
xnoremap <silent> <F9> <Plug>ReplicaSendLines<cr>

# Outline. <F8> is overriden by vimspector
