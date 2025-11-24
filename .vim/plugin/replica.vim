vim9script

g:replica_console_position = "J"
g:replica_display_range  = false
# g:replica_console_height = 8
g:replica_console_height = max([&lines / 6, 4])
g:replica_jupyter_console_options = {
  python: " --config ~/.jupyter/jupyter_console_config.py"}
nnoremap <silent> <c-enter> <Plug>ReplicaSendCell<cr>j
nnoremap <silent> <s-enter> <Plug>ReplicaSendFile<cr>
nnoremap <silent> <F9> <Plug>ReplicaSendLines<cr>
xnoremap <silent> <F9> <Plug>ReplicaSendLines<cr>

# Outline. <F8> is overriden by vimspector
nnoremap <silent> <F8> <Plug>OutlineToggle
