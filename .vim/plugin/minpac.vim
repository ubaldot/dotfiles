vim9script

def PackInit()

  packadd minpac
  minpac#init()
  minpac#add('k-takata/minpac', {'type': 'opt'})
  minpac#add('yegappan/lsp', {'type': 'opt'})
  minpac#add('ubaldot/vim9-conversion-aid', {'type': 'opt'})
  minpac#add('ubaldot/vim-latex-tools', {'type': 'opt'})
  minpac#add('ubaldot/vim-replica', {'type': 'opt'})
  minpac#add('ubaldot/vim-manim', {'type': 'opt'})
  minpac#add('ubaldot/vim-microdebugger', {'type': 'opt'})
  minpac#add('ubaldot/vim-extended-view', {'type': 'opt'})
  minpac#add('ubaldot/vimspector', {'type': 'opt'})

  # Additional plugins here.
  minpac#add('sainnhe/everforest')
  minpac#add('lambdalisue/fern.vim')
  minpac#add('junegunn/vim-easy-align')
  minpac#add('ubaldot/vim-highlight-yanked')
  minpac#add('ubaldot/vim-outline')
  minpac#add('ubaldot/vim-markdown-extras')
  minpac#add('ubaldot/vim-poptools')
  minpac#add('ubaldot/vim-git-master')
  minpac#add('ubaldot/vim-helpme')
  minpac#add('ubaldot/vim-calendar')
  minpac#add('ubaldot/vim-op-surround')
enddef

# Define user commands for updating/cleaning the plugins.
# Each of them calls PackInit() to load minpac and register
# the information of plugins, then performs the task.
command! PackUpdate  PackInit() |  minpac#update()
command! PackClean   PackInit() |  minpac#clean()
command! PackStatus packadd minpac | minpac#status()

def PackList(A: any, L: any, P: any): list<string>
  PackInit()
  return sort(keys(minpac#getpluglist()))
enddef

def PackEditPlugin(dirname: string)
  # First search in "start" folder
  var plugin_dir = getcompletion($'{g:dotvim}/pack/minpac/start/', 'dir')
            ->filter((_, val) => val =~ dirname)

  # Then search in "opt" folder
  if empty(plugin_dir)
    plugin_dir = getcompletion($'{g:dotvim}/pack/minpac/opt/', 'dir')
            ->filter((_, val) => val =~ dirname)
  endif

  if !empty(plugin_dir)
    exe $"cd {plugin_dir[0]}"
  else
    echoerr $"Cannot find folder '{dirname}'"
  endif
enddef

command! -nargs=1 -complete=customlist,PackList PackEditPlugin PackEditPlugin(<f-args>)

def PackConfigList(arglead: string,
    command_line: string,
    cursor_position: number): list<string>

  var opt_settings_files = getcompletion($'{g:dotvim}/autoload/config/', 'file')
                      ->map((_, val)  => fnamemodify(val, ':t:r'))
  var start_settings_files = getcompletion($'{g:dotvim}/plugin/', 'file')
                      ->map((_, val)  => fnamemodify(val, ':t:r'))
  return opt_settings_files + start_settings_files->filter($'v:val =~ "^{arglead}"')

enddef

def PackConfig(filename: string)
  # First start in plugin/ folder
  var start_settings_files = getcompletion($'{g:dotvim}/plugin/', 'file')
  var filename_full = start_settings_files->filter((_, val) => val =~ filename)

  # Next, search in autoload/config folder
  if empty(filename_full)
    var opt_settings_files = getcompletion($'{g:dotvim}/autoload/config/', 'file')
    filename_full = opt_settings_files->filter((_, val) => val =~ filename)
  endif
  exe $"edit {filename_full[0]}"
enddef

command! -nargs=1 -complete=customlist,PackConfigList PackConfig
      \ PackConfig(<f-args>)

def PackDevSetup()
  const supported_filetypes = ['c', 'python', 'cpp', 'latex']

  if index(supported_filetypes, &filetype) != -1
    if !exists('g:loaded_termdebug')
      g:termdebug_config = {}
      packadd termdebug
    endif

    # Order matters...
    if !exists('g:loaded_lsp')
      packadd lsp
      config#lsp#Setup()
    endif

    if !exists('g:loaded_microdebugger')
      config#microdebugger#Setup()
      packadd vim-microdebugger
    endif

    if !exists('g:loaded_vimspector')
      packadd vimspector
      config#vimspector#Setup()
    endif


    if !exists('g:loaded_replica')
      packadd vim-replica
    endif

    if !exists('g:loaded_vim_manim')
      packadd vim-manim
    endif

    config#statusline#Setup(true)
  else
    config#statusline#Setup(false)
  endif
enddef

augroup PACK_DEV_SETUP
  autocmd!
  autocmd FileType * PackDevSetup()
augroup END
