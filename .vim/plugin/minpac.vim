vim9script

def PackInit()
  # This function has nothing to do with plugin loading.

  packadd minpac
  minpac#init()
  minpac#add('k-takata/minpac', {'type': 'opt'})

  # Optional plugins
  # minpac#add('yegappan/lsp', {'type': 'opt'})
  minpac#add('ubaldot/lsp', {'type': 'opt'})
  minpac#add('ubaldot/vim-microdebugger', {'type': 'opt'})
  minpac#add('ubaldot/vim-extended-view', {'type': 'opt'})
  minpac#add('yegappan/snake', {'type': 'opt'})
  minpac#add('yegappan/tetris', {'type': 'opt'})
  minpac#add('ubaldot/vim9-conversion-aid', {'type': 'opt'})
  minpac#add('ubaldot/vim-latex-tools', {'type': 'opt'})
  minpac#add('ubaldot/vim-manim', {'type': 'opt'})
  minpac#add('ubaldot/copilot-chat.vim', {'type': 'opt'})
  minpac#add('ubaldot/vim-outlook', {'type': 'opt'})
  minpac#add('lambdalisue/fern.vim', {'type': 'opt'})
  minpac#add('ubaldot/vim-outline', {'type': 'opt'})
  minpac#add('ubaldot/vim-markdown-extras', {'type': 'opt'})
  minpac#add('ubaldot/vim-poptools', {'type': 'opt'})
  minpac#add('ubaldot/vim-git-box', {'type': 'opt'})
  minpac#add('ubaldot/vim-helpme', {'type': 'opt'})
  minpac#add('ubaldot/vim-calendar', {'type': 'opt'})
  minpac#add('ubaldot/vim-op-surround', {'type': 'opt'})
  minpac#add('ubaldot/vim-replica', {'type': 'opt'})

  # Start plugins.
  minpac#add('ubaldot/vimspector')
enddef

# Define user commands for updating/cleaning the plugins.
# Each of them calls PackInit() to load minpac and register
# the information of plugins, then performs the task.
command! PackUpdate  PackInit() |  minpac#update()
command! PackClean   PackInit() |  minpac#clean()
command! PackStatus packadd minpac | minpac#status()

command! -nargs=1 -complete=customlist,PackConfig_CompleteList PackConfig
      \ PackConfig(<f-args>)

command! -nargs=1 -complete=customlist,PackEditPlugin_CompleteList PackEditPlugin PackEditPlugin(<f-args>)

def PackEditPlugin_CompleteList(arglead: string,
    command_line: string,
    cursor_position: number): list<string>

  var start_plugins = getcompletion($'{g:dotvim}/pack/minpac/start/', 'dir')
    ->map((_, val)  => fnamemodify(val, ':h:t'))
  var opt_plugins = getcompletion($'{g:dotvim}/pack/minpac/opt/', 'dir')
    ->map((_, val)  => fnamemodify(val, ':h:t'))
  return (start_plugins + opt_plugins)->filter($'v:val =~ "{arglead}"')

enddef

def PackEditPlugin(dirname: string)
  var start_dir = getcompletion($'{g:dotvim}/pack/minpac/start/', 'dir')
    ->filter((_, val) => val =~ dirname)
  var opt_dir = getcompletion($'{g:dotvim}/pack/minpac/opt/', 'dir')
    ->filter((_, val) => val =~ dirname)

  var plugin_dir = start_dir + opt_dir

  if !empty(plugin_dir)
    exe $"cd {plugin_dir[0]}"
  else
    echoerr $"Cannot find folder '{dirname}'"
  endif
enddef


def PackConfig_CompleteList(arglead: string,
    command_line: string,
    cursor_position: number): list<string>

  var opt_settings_files = getcompletion($'{g:dotvim}/lib/config/', 'file')
    ->map((_, val)  => fnamemodify(val, ':t:r'))
  var start_settings_files = getcompletion($'{g:dotvim}/plugin/', 'file')
    ->map((_, val)  => fnamemodify(val, ':t:r'))
  return (opt_settings_files + start_settings_files)->filter($'v:val =~ "^{arglead}"')

enddef

def PackConfig(filename: string)
  # First start in plugin/ folder
  var start_settings_files = getcompletion($'{g:dotvim}/plugin/', 'file')
  var filename_full = start_settings_files->filter((_, val) => val =~ filename)

  # Next, search in autoload/config folder
  if empty(filename_full)
    var opt_settings_files = getcompletion($'{g:dotvim}/lib/config/', 'file')
    filename_full = opt_settings_files->filter((_, val) => val =~ filename)
  endif
  exe $"edit {filename_full[0]}"
enddef


# ----------------------------------------
# opt packages and statusline management
# ----------------------------------------

def PackDevSetup()
  const supported_filetypes = ['c', 'python', 'cpp', 'latex']

  if index(supported_filetypes, &filetype) != -1
    if !exists('g:loaded_termdebug')
      g:termdebug_config = {}
      packadd! termdeubug
      exe $"set ft={&filetype}"
    endif

    # Order matters...
    if !exists('g:loaded_lsp')
      echom g:dotvim
      execute $'source {g:dotvim}/lib/config/lsp.vim'
      packadd! lsp

      highlight link LspDiagLine NONE

      # ---- Useful mappings -----
      nnoremap <buffer> <silent> öd <Cmd>LspDiag prev<cr>
      nnoremap <buffer> <silent> äd <Cmd>LspDiag next<cr>
      # nnoremap <silent> <leader>p <Cmd>LspDiag prev<cr>
      # nnoremap <silent> <leader>n <Cmd>LspDiag next<cr>
      nnoremap <buffer> <silent> <leader>dd <Cmd>LspDiag show<cr>
      nnoremap <buffer> <silent> <leader>d <Cmd>LspDiag current<cr>
      nnoremap <buffer> <silent> <leader>i <Cmd>LspGotoImpl<cr>
      nnoremap <buffer> <silent> <leader>g <Cmd>LspGotoDefinition<cr>
      nnoremap <buffer> <silent> <leader>r <Cmd>LspShowReferences<cr>
    endif

    if !exists('g:loaded_microdebugger')
      source $'{g:dotvim}/lib/config/vim-microdebugger.vim'
      packadd! vim-microdebugger
    endif
  endif
enddef

augroup PACK_DEV_SETUP
  autocmd!
  autocmd FileType * PackDevSetup()
augroup END
