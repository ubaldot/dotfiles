vim9script

def SendQuery()
  exe $"CopilotChatSetActive {bufnr()}"
  exe "CopilotChatSubmit"
enddef

nnoremap <buffer> <CR> <scriptcmd>SendQuery()<cr>
inoremap <buffer> <CR> <scriptcmd>SendQuery()<cr>
inoremap <buffer> <s-CR> <cr>
