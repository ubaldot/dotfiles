vim9script

command! -range -nargs=0 Comment exe ":<line1>,<line2>norm gcc"
nnoremap <silent> <expr> gC comment#Toggle() .. '$'
