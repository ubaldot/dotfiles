vim9script

g:copilot_chat_disable_mappings = 1

def CopilotWindowToggle()
  # OBS! bufname may change with new updates of the copilot_chat plugin
  const copilot_bufname = "CopilotChat"

  var unlisted_buffers = filter(getbufinfo(), (_, v) => !v.listed)
  if unlisted_buffers->filter($'v:val.name =~# "{copilot_bufname}"')->empty()
    exe "CopilotChatOpen"
  else
    exe "CopilotChatToggle"
  endif
enddef

nnoremap <leader>CC <scriptcmd>CopilotWindowToggle()<cr>
xnoremap <leader>CE <Plug>CopilotChatAddSelection
