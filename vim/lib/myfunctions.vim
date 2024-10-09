vim9script

export def Echoerr(msg: string)
  echohl ErrorMsg | echom $'{msg}' | echohl None
enddef

# Search and replace in files.
# Risky calls external 'sed' and it won't ask for confirmation.
var match_id = 0
def SearchReplacementHelper(search_user: string = ''): list<string>
  augroup SEARCH_HI | autocmd!
    autocmd CmdlineChanged @ if match_id > 0 | matchdelete(match_id) | endif | search(getcmdline(), 'w') | match_id = matchadd('IncSearch', getcmdline()) | redraw!
    autocmd CmdlineLeave @ if match_id > 0 | matchdelete(match_id) | match_id = 0 | endif
  augroup END
  var search = empty(search_user) ? input("String to search: ") : search_user
  if !empty(search_user)
    if match_id > 0
      matchdelete(match_id)
    endif
    match_id = matchadd('IncSearch', search_user)
    redraw!
  endif
  if empty(search)
    echom ""
    autocmd! SEARCH_HI
    augroup! SEARCH_HI
    return []
  endif
  autocmd! SEARCH_HI
  augroup! SEARCH_HI
  if match_id > 0
    matchdelete(match_id)
  endif
  echo ""
  var replacement = input("\nReplacement: ")
  return [search, replacement]
enddef

def SearchAndReplaceInFiles(search_user: string = '')
  echo "Search & replace in files\n"
  var search_replacement = SearchReplacementHelper(search_user)
  var search = search_replacement[0]
  var replacement = search_replacement[1]
  if empty(search_replacement)
    return
  endif
  var pattern = input("\nIn files: ", '*.')
  if empty(pattern)
    echom ""
    return
  endif
  var risky = input("\nRisky: ", 'n')
  if risky !~ "[yes]" &&  risky !~ "[no]" && empty(risky)
    return
  endif

  if risky[0] =~ "y"
    var cmd = 'Nothing'
    if g:os != 'Windows'
      cmd = printf('!find %s -type f -exec sed -i ''s/%s/%s/g'' {} \;', pattern, search, replacement)
    else
      # TODO: Command for Windows: to test
      # cmd = $'powershell -command "gci -Recurse -File | ForEach-Object \{
      #       \  (Get-Content $_.FullName) -replace ''{search}'', ''{replacement}'' | Set-Content $_.FullName
      #       \\}"'
    endif
    echo $"\n{cmd}"
  else
    var vimgrep_opts = input("\nVimgrep options: ", 'gj')
    var substitute_opts = input("\nSubstitute options: ", 'gci')
    if empty(substitute_opts)
      echo ''
      return
    endif
    var cmd = $'vimgrep /{search}/{vimgrep_opts} **/{pattern}'
    echo $"\n{cmd}"
    exe cmd
    cmd = $'cfdo :%s/{search}/{replacement}/{substitute_opts}'
    echo $"\n{cmd}"
    exe cmd
    echo "\nType ':wall' to save all or ':cfdo' u to undo"
  endif
enddef

# TODO: cannot distinguish when user hit esc or cr. Perhaps you want to use
# cmdleave?
def SearchAndReplace(search_user: string = '')
  echo "Search & replace in current buffer\n"
  var search_replacement = SearchReplacementHelper(search_user)
  if empty(search_replacement)
    return
  endif
  var search = search_replacement[0]
  if empty(search)
    return
  endif
  var replacement = search_replacement[1]
  var opts = input("\nSubstitute options: ", 'gci')
  if empty(opts)
    echo ''
    return
  endif
  var range = input("\nRange: ", '%')
  if empty(range)
    echo ''
    return
  endif
  # echom range
  # if range !~ "\(%\)"
  #   echom "  NOK"
  # else
  #   echom "  OK"
  # endif
  exe $':{range}s/{search}/{replacement}/{opts}'
enddef

command! -nargs=? SearchAndReplace SearchAndReplace(<f-args>)
command! -nargs=? SearchAndReplaceInFiles SearchAndReplaceInFiles(<f-args>)

# =======================
export def TrimWhitespace()
  var currwin = winsaveview()
  var save_cursor = getpos(".")
  silent! :keeppatterns :%s/\s\+$//e
  silent! :%s/\($\n\s*\)\+\%$//
  winrestview(currwin)
  setpos('.', save_cursor)
enddef

export def GetTextObject(textobject: string): string
  # backup the content of register t (arbitrary choice, YMMV)
  var oldreg = getreg("t")
  # silently yank the text covered by whatever text object
  # was given as argument into register t
  execute 'silent normal "ty' .. textobject
  # save the content of register t into a variable
  var text = getreg("t")
  # restore register t
  setreg("t", oldreg)
  # return the content of given text object
  return text
enddef

# Commit a dot.
# It is related to the opened buffer not to pwd!
export def CommitDot()
  # curr_dir = pwd
  cd %:p:h
  exe "!git add -u && git commit -m '.'"
  # cd curr_dir
enddef

export def PushDot()
  cd %:p:h
  exe "!git add -u && git commit -m '.' && git push"
enddef


def DiffInternal(commit_id: string)
  # For comparing:
  #   1. Your open buffer VS its last saved version (no args)
  #   2. Your open buffer with a given commit
  #
  # Usage: :Diff 12jhu23
  # To exit, just wipe the scratch buffer.

  var curr_winid = win_getid()
  vertical new
  var scratch_winid = win_getid()
  win_execute(scratch_winid, "setlocal bufhidden=wipe buftype=nofile nobuflisted noswapfile")

  if empty(commit_id)
    # Read from disk
    execute $"read {expand('#')}"
  else
    # Get lines from repo
    var file_lines = systemlist($"git show {commit_id}:{expand('#:.')}")
    map(file_lines, (idx, val) => substitute(val, '\r', '', ''))
    appendbufline(winbufnr(scratch_winid), 0, file_lines)
  endif

  setwinvar(scratch_winid, '&filetype', getbufvar('#', '&filetype'))
  augroup Diff
    autocmd!
    autocmd WinClosed scratch_winid diffoff!
  augroup END
  diffthis
  win_gotoid(curr_winid)
  diffthis
  win_gotoid(scratch_winid)
enddef

# TODO: add the various v:shell_error
var git_log_bufname = "Git-log"
export def GitLog(num_commits: number = 20)
  var path = expand('%:p:h')
  var git_root = trim(system($'cd {path} && git rev-parse --show-toplevel'))
  exe $"cd {git_root}"
  if v:shell_error != 0
    Echoerr('Not a git repo')
    return
  endif
  var log_list = systemlist($'git log --oneline --decorate -n {num_commits}')
  map(log_list, (idx, val) => substitute(val, '\r', '', ''))
  below new
  var log_winid = win_getid()
  w:scratch = 1
  silent exe $"file {git_log_bufname}"
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setline(1, log_list)
  matchadd('Directory', '^\w*\s')
  matchadd('Type', '(\_.\{-})')

  # Add
  setwinvar(win_id2win(log_winid), "GitCheckout", GitCheckout)
  win_execute(log_winid, 'nnoremap <buffer> <silent> <enter> <ScriptCmd>w:GitCheckout(getline("."))<cr>')
enddef

command! -nargs=? GitLog GitLog(<args>)

export def GitCheckout(log_line: string = '')
  if empty(log_line)
    GitLog()
  else
    var commit_id = LogLineToCommitID(log_line)
    exe $"!git checkout {commit_id}"
    exe $":{bufwinnr(git_log_bufname)}close!"
  endif
enddef

command! -nargs=? -complete=customlist,LogComplete GitCheckout GitCheckout(<f-args>)

def GitBranchComplete(A: any, L: any, P: any): list<string>
  var path = expand('%:p:h')
  var git_root = trim(system($'cd {path} && git rev-parse --show-toplevel'))
  if v:shell_error != 0
    return []
  endif
  return systemlist($'cd {git_root} && git branch')
enddef

export def GitBranch(branch_name: string = '')
  if empty(branch_name)
    var curr_branch = trim(system("git branch --show-current"))
    if empty(curr_branch)
      echo $'[(HEAD detached at {trim(system("git rev-parse --short HEAD"))})]'
    else
      echo curr_branch
    endif
  else
    var branch_name_cleaned = branch_name->substitute('*\s', '', '')
    exe $"!git checkout {branch_name_cleaned}"
  endif
enddef

command! -nargs=? -complete=customlist,GitBranchComplete GitBranch GitBranch(<f-args>)


export def GitDiff()
  var filename = expand('%:p')
  var path = expand('%:p:h')
  var git_root = trim(system($'cd {path} && git rev-parse --show-toplevel'))
  if v:shell_error != 0
    Echoerr('Not a git repo')
    return
  endif
  var diff_list = systemlist($"cd {git_root} && git diff HEAD -- {filename}")
  map(diff_list, (idx, val) => substitute(val, '\r', '', ''))
  vnew
  w:scratch = 1
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setline(1, diff_list)
  matchadd("Removed", '^-.*')
  matchadd("Type", '^+.*')
enddef
command! GitDiff GitDiff()

def LogLineToCommitID(log_line: string = ''): string
  var commit_id = ''
  if !empty(log_line) && log_line != '--'
    commit_id = matchstr(log_line, '^[a-f0-9]*')
  elseif !empty(log_line) && log_line == '--'
    commit_id = 'HEAD'
  else
    commit_id = log_line
  endif
  return commit_id
enddef

export def Diff(log_line: string = '')
  var commit_id = LogLineToCommitID(log_line)
  DiffInternal(commit_id)
enddef

def LogComplete(A: any, L: any, P: any): list<string>
  var path = expand('%:p:h')
  var git_root = trim(system($'cd {path} && git rev-parse --show-toplevel'))
  if v:shell_error != 0
    return []
  endif
  return systemlist($'cd {git_root} && git log --oneline --decorate -n 20')
enddef

command! -nargs=? -complete=customlist,LogComplete Diff Diff(<f-args>)

export def GitCommit(no_verify: bool = false)
  var message = input("Enter commit message: ")
  var no_verify_str = no_verify ? '--no-verify' : ''
  var shell_msg = system($"git commit -m '{message}' {no_verify_str}")
  silent $":{git_status_bufname}close!"
  if v:shell_error != 0
    echo shell_msg
  endif
enddef

command! -nargs=0 GitCommit GitCommit()
command! -nargs=0 GitCommitNoVerify GitCommit(true)
command! -nargs=0 GitPush execute('git push')

def GitCommitManagement(key: string)
  # Pick everything after the first 3 characters (git status --short used the
  # first 3 chars for the status
  var item = getline('.')->substitute('^...', '', '')->trim()
  var shell_msg = ''
  if key ==# 's'
    shell_msg = system($"git add {item}")
  elseif key ==# 'S'
    shell_msg = system("git add -u")
  elseif key ==# 'u'
    # Avoid to try to unstage lines that don't represent a file
    if index(systemlist($'git diff --cached --name-only'), item) != -1
      shell_msg = system($"git reset {item}")
    endif
  elseif key ==# 'U'
    shell_msg = system("git reset")
  elseif key ==# 'c'
    var commit_msg = input('Insert commit message: ')
    shell_msg = system($"git commit -m {commit_msg}")
  elseif key ==# 'cc'
    var commit_msg = input('Insert commit message: ')
    shell_msg = system($"git commit -m {commit_msg} --no-verify")
  elseif key ==# 'p'
    shell_msg = system("git push")
  endif
  # If no error update window
  if v:shell_error == 0
    var win_view = winsaveview()
    UpdateGitStatus()
    winrestview(win_view)
  else
    echo shell_msg
  endif
enddef

def UpdateGitStatus()
  var instructions = ['Instructions:', "  Stage: 's' ('S' for all)", "  Unstage: 'u' ('U' for all)", "  Commit: 'c'", "  Commit (--no-verify): 'cc'", "  Push: 'p'"]

  var all_files = systemlist('git status --short')
  var staged_list = copy(all_files)->filter('v:val =~ "^\\w\\s"')
  var unstaged_list = copy(all_files)->filter("v:val =~ '[^\\s^\\w]\\w\\s'")
  var untracked_list = copy(all_files)->filter('v:val =~ "^??"')

  var unmerged_list = systemlist('git ls-files --unmerged')

  # Create status buffer
  set modifiable
  exe ":%d _"
  # Append title
  appendbufline(git_status_bufname, 0, instructions)
  matchadd("WarningMsg", instructions[0])
  map(instructions[1 : ], 'matchadd("WarningFloat", v:val)')

  # Add staged files and color them
  var start_line = line('.')
  var section_name = ["Changes to be committed:"]
  var num_lines = len(section_name + staged_list)
  appendbufline(git_status_bufname, start_line, section_name + staged_list)
  map(staged_list, 'matchadd("Directory", v:val)')

  # Add staged files and color them
  start_line += num_lines
  section_name = ['', "Changes not staged for commit:"]
  num_lines = len( section_name + unstaged_list)
  appendbufline(git_status_bufname, start_line, section_name + unstaged_list)
  map(unstaged_list, 'matchadd("Error", v:val)')

  # Add staged files and color them
  start_line += num_lines
  section_name = ['', "Untracked files:"]
  num_lines = len(untracked_list + section_name)
  appendbufline(git_status_bufname, start_line, section_name + untracked_list)
  map(untracked_list, 'matchadd("Error", v:val)')

  if !empty(unmerged_list)
    start_line += num_lines
    section_name = ['(CONFLICTS) unmerged files need merge:']
    appendbufline(git_status_bufname, start_line, section_name + unmerged_list)
    map(section_name, 'matchadd("ErrorMsg", v:val)')
    map(untracked_list, 'matchadd("Error", v:val)')
  endif
  set nomodifiable
enddef

var git_status_bufname = 'Git-status'
def GitStatus()
  var path = expand('%:p:h')
  var git_root = trim(system($'cd {path} && git rev-parse --show-toplevel'))
  exe $"cd {git_root}"
  if v:shell_error != 0
    Echoerr('Not a git repo')
    return
  endif
  # Create sctarch buffer
  below new
  var status_winid = win_getid()
  w:scratch = 1
  silent exe $"file {git_status_bufname}"
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile

  UpdateGitStatus()

  # Add
  setwinvar(win_id2win(status_winid), "GitCommitManagement", GitCommitManagement)
  win_execute(status_winid, 'nnoremap <buffer> <silent> s <ScriptCmd>w:GitCommitManagement("s")<cr>')
  win_execute(status_winid, 'nnoremap <buffer> <silent> S <ScriptCmd>w:GitCommitManagement("S")<cr>')
  win_execute(status_winid, 'nnoremap <buffer> <silent> u <ScriptCmd>w:GitCommitManagement("u")<cr>')
  win_execute(status_winid, 'nnoremap <buffer> <silent> U <ScriptCmd>w:GitCommitManagement("U")<cr>')
  win_execute(status_winid, 'nnoremap <buffer> <silent> c <ScriptCmd>w:GitCommitManagement("c")<cr>')
  win_execute(status_winid, 'nnoremap <buffer> <silent> cc <ScriptCmd>w:GitCommitManagement("cc")<cr>')
  win_execute(status_winid, 'nnoremap <buffer> <silent> p <ScriptCmd>w:GitCommitManagement("p")<cr>')
  win_execute(status_winid, 'xnoremap <buffer> <silent> s :call w:GitCommitManagement("s")<cr>')
  win_execute(status_winid, 'xnoremap <buffer> <silent> u :call w:GitCommitManagement("u")<cr>')
enddef

command! -nargs=0 GitStatus GitStatus()

def GitLsFilesManagement(key: string)
  var item = getline('.')
  # Needed for unstaging correct lines
  var shell_msg = ''
  if key ==# 'u'
    shell_msg = system($"git rm --cached {item}")
  endif
  # If no error update window
  if v:shell_error == 0
    var win_view = winsaveview()
    UpdateLsFiles()
    winrestview(win_view)
  else
    echo shell_msg
  endif
enddef

def UpdateLsFiles()
  var instructions = ['Key bindings:', "  Untrack file: 'u'", '', 'Tracked files:']
  var lsfiles_list = systemlist($'git ls-files')
  map(lsfiles_list, (idx, val) => substitute(val, '\r', '', ''))

  set modifiable
  var win_view = winsaveview()
  exe ":%d _"
  appendbufline(bufnr(), 0, instructions + lsfiles_list)
  matchadd('WarningMsg', '\%1l')
  matchadd('WarningFloat', '\%2l')
  matchadd('ModeMsg', 'Tracked files:')
  winrestview(win_view)
  set nomodifiable
enddef

var git_lsfiles_bufname = 'Git-ls-files'
def GitLsFiles()
  var path = expand('%:p:h')
  var git_root = trim(system($'cd {path} && git rev-parse --show-toplevel'))
  exe $"cd {git_root}"
  if v:shell_error != 0
    Echoerr('Not a git repo')
    return
  endif
  var lsfiles_list = systemlist($'git ls-files')
  map(lsfiles_list, (idx, val) => substitute(val, '\r', '', ''))
  # lsfiles_list_cleaned = CleanStatusList()

  below new
  var lsfiles_winid = win_getid()
  w:scratch = 1
  silent exe $"file {git_lsfiles_bufname}"
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  UpdateLsFiles()

  # Add
  setwinvar(win_id2win(lsfiles_winid), "GitLsFilesManagement", GitLsFilesManagement)
  win_execute(lsfiles_winid, 'nnoremap <buffer> <silent> u <ScriptCmd>w:GitLsFilesManagement("u")<cr>')
  win_execute(lsfiles_winid, 'xnoremap <buffer> <silent> u :call w:GitLsFilesManagement("u")<cr>')

enddef

command! -nargs=0 GitLsFiles GitLsFiles()
 # ============== END GIT ==================


export def Redir(cmd: string, rng: number, start: number, end: number)
  # Used to redirect the output from the terminal in a scratch buffer
  #
  # Example: :Redir !ls
  #
  # You can use it also to redirect the output of some Vim commands
  for win in range(1, winnr('$'))
    if !empty(getwinvar(win, 'scratch'))
      execute ":" .. win .. 'windo :close'
    endif
  endfor
  var output = []
  if cmd =~ '^!'
    var cmd_filt = cmd =~ ' %'
      ? matchstr(substitute(cmd, ' %', ' ' .. shellescape(escape(expand('%:p'), '\')), ''), '^!\zs.*')
      : matchstr(cmd, '^!\zs.*')
    if rng == 0
      output = systemlist(cmd_filt)
    else
      var joined_lines = join(getline(start, end), '\n')
      var cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
      output = systemlist(cmd_filt .. " <<< $" .. cleaned_lines)
    endif
  else
    var tmp = execute(cmd)
    output = split(tmp, "\n")
  endif
  vnew
  w:scratch = 1
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  setline(1, output)
enddef



var color_is_shown = false
# export def ColorsShow(clear: bool = false): void
export def ColorsToggle(): void
  if exists('b:prop_ids')
    map(b:prop_ids, (_, p) => prop_remove({id: p}))
  endif

  if color_is_shown
    color_is_shown = false
    return
  endif

  # This is only needed for removing.
  b:prop_ids = []

  for row in range(1, line('$'))
    var current = getline(row)
    var cnt = 1
    var [hex, starts, ends] = matchstrpos(current, '#\x\{6\}', 0, cnt)
    while starts != -1
      var col_tag = "inline_color_" .. hex[1 : ]
      var col_type = prop_type_get(col_tag)
      if col_type == {}
        hlset([{name: col_tag, guibg: hex, guifg: "black"}])
        prop_type_add(col_tag, {highlight: col_tag})
      endif
      add(b:prop_ids, prop_add(row, starts + 1, { length: ends - starts,  type: col_tag }))
      cnt += 1
      [hex, starts, ends] = matchstrpos(current, '#\x\{6\}', 0, cnt)
    endwhile
  endfor
  color_is_shown = true
enddef

# Highlight toggle
# TODO:
# 1) Three different highlights
# 2) Normal mode highlight current line
# 3) Set operation on selection.
def Highlight()
  if !exists('b:prop_id')
    b:prop_id = 0
  endif
  if prop_type_get('my_hl') == {}
    prop_type_add('my_hl', {'highlight': 'DiffDelete'})
  endif

  var start_line = line("'<")
  var end_line = line("'>")
  var start_col = col("'<")
  var end_col = col("'>")
  # echom prop_list(line('.'), {'types':$ ['my_hl']})
  # echom prop_list(start_line, {'types': ['my_hl']})


  # If there are no prop under the cursor position, then add, otherwise if a
  # prop is detected remove it.
  var no_prop = empty(prop_list(start_line, {'types': ['my_hl']}))
  if no_prop
    prop_add(start_line, start_col, {'end_lnum': end_line, 'end_col': end_col, 'type': 'my_hl', 'id': b:prop_id})
    b:prop_id = b:prop_id + 1
  else
    var id = prop_list(start_line, {'types': ['my_hl']})[0]['id']
    prop_remove({'id': id})
  endif
enddef

# --------- General formatting function -----------------
export def FormatWithoutMoving()
  var view = winsaveview()
  silent normal! gggqG
  winrestview(view)
enddef

# ------------- Prettier --------------------
var prettier_supported_filetypes = ['markdown', 'markdown.txtfmt', 'json', 'yaml', 'html', 'css']
def Prettify()
  # If prettier is not available, then the buffer content will be canceled upon
  # write
  if executable('prettier') && (index(prettier_supported_filetypes, &filetype) != -1)
    var win_view = winsaveview()
    # exe $":%!prettier 2>{g:null_device} --prose-wrap always
    #             \ --print-width {&l:textwidth} --stdin-filepath {shellescape(expand("%"))}"
    exe $":%!prettier --prose-wrap always
          \ --print-width {&l:textwidth} --stdin-filepath {shellescape(expand("%"))}"
    winrestview(win_view)
  else
    echom $"'prettier' is not installed OR '{&filetype}' filetype is not supported"
  endif

  if v:shell_error != 0
    silent! undo
    # throw prevents to write on disk
    # throw "'prettier' errors!"
    # redraw!
    echoerr "'prettier' errors!"
  endif
enddef

command! Prettify Prettify()

# augroup PRETTIER
#   autocmd!
#   autocmd BufWritePre * if index(prettier_supported_filetypes, &filetype) != -1 | Prettify() | endif
# augroup END
# --------------------------------------------------------------

export def QuitWindow()
  # Close window and wipe buffer but it prevent to quit Vim if one window is
  # left.
  if winnr('$') != 1
    quit
  endif
enddef

# ------------ Terminal functions ------------------
# Change all the terminal directories when you change vim directory
export def ChangeTerminalDir()
  for ii in term_list()
    if bufname(ii) == "JULIA"
      term_sendkeys(ii, 'cd("' .. getcwd() .. '")' .. "\n")
    else
      term_sendkeys(ii, "cd " .. getcwd() .. "\n")
    endif
  endfor
enddef

# Close all terminals with :qa!
export def WipeoutTerminals()
  for buf_nr in term_list()
    exe "bw! " .. buf_nr
  endfor
enddef

# TERMINAL IN POPUP
# This function can be called only from a terminal windows/popup, so there is
# no risk of closing unwanted popups (such as HelpMe popups).

export def Quit_term_popup(quit: bool)
  if empty(popup_list())
    if quit
      exe "quit"
    else
      exe "close"
    endif
  else
    if quit
      var bufno = bufnr()
      popup_close(win_getid())
      exe "bw! " .. bufno
    else
      popup_close(win_getid())
    endif
  endif
enddef

var my_term_name = &shell
export def OpenMyTerminal()
  var terms_name = []
  for ii in term_list()
    add(terms_name, bufname(ii))
  endfor

  if term_list() == [] || index(terms_name, my_term_name) == -1
    # enable the following and remove the popup_create part if you want
    # the terminal in a "classic" window.
    # vert term_start(&shell, {'term_name': 'MANIM' })
    var os_shell = ""
    if g:os == "Windows"
      os_shell = "powershell"
    else
      os_shell = &shell
    endif
    var buf_no = term_start(os_shell, {'term_name': my_term_name, 'hidden': 1, 'term_finish': 'close'})
    # echom bufname(buf_no)
    setbufvar(bufname(buf_no), '&buflisted', 0)
    # win_execute(bufwinid(buf_no), 'setlocal nobuflisted')
    # setbufvar(buf_no, 'wrap', 0)
  endif

  popup_create(bufnr(my_term_name), {
    title: my_term_name,
    line: &lines,
    col: &columns,
    pos: "botright",
    posinvert: false,
    borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
    border: [1, 1, 1, 1],
    maxheight: &lines - 1,
    minwidth: 80,
    minheight: 20,
    close: 'button',
    resize: true
  })
enddef

export def HideMyTerminal()
  var terms_name = []
  for ii in term_list()
    add(terms_name, bufname(ii))
  endfor
  # This works because once a terminal popup is in place, it takes all the
  # focus and you cannot go anywhere if you don't close it first.
  if index(terms_name, my_term_name) != -1 && !empty(popup_list())
    popup_close(popup_list()[0])
  endif
enddef


# Make vim to speak on macos
if has('mac')
  # <esc> is used in xnoremap because '<,'> are updated once you leave visual mode
  xnoremap <leader>s <esc><ScriptCmd>TextToSpeech(line("'<"), line("'>"))<cr>
  command -range Say vim9cmd TextToSpeech(<line1>, <line2>)

  def TextToSpeech(firstline: number, lastline: number)
    exe $":{firstline},{lastline}w !say"
  enddef
endif

# Some mappings to learn
# noremap <unique> <script> <Plug>Highlight <esc><ScriptCmd>Highlight()
#
# TODO: separate leading and trailing chars
export def Surround(pre: string, post: string)
  # var [line_start, column_start] = getpos("v")[1 : 2]
  # var [line_end, column_end] = getpos(".")[1 : 2]
  var pre_len = strlen(pre)
  var post_len = strlen(post)
  var [line_start, column_start] = getpos("'<")[1 : 2]
  var [line_end, column_end] = getpos("'>")[1 : 2]
  if line_start > line_end
    var tmp = line_start
    line_start = line_end
    line_end = tmp

    tmp = column_start
    column_start = column_end
    column_end = tmp
  endif
  if line_start == line_end && column_start > column_end
    var tmp = column_start
    column_start = column_end
    column_end = tmp
  endif
  var leading_chars = strcharpart(getline(line_start), column_start - 1 - pre_len, pre_len)
  var trailing_chars = strcharpart(getline(line_end), column_end, post_len)

  # echom "leading_chars: " .. leading_chars
  # echom "trailing_chars: " .. trailing_chars

  cursor(line_start, column_start)
  var offset = 0
  if leading_chars == pre
    execute($"normal! {pre_len}X")
    offset = -pre_len
  else
    execute($"normal! i{pre}")
    offset = pre_len
  endif

  # Some chars have been added if you are working on the same line
  if line_start == line_end
    cursor(line_end, column_end + offset)
  else
    cursor(line_end, column_end)
  endif

  if trailing_chars == post
    execute($"normal! l{post_len}x")
  else
    execute($"normal! a{post}")
  endif
enddef


# TODO: Require more work!
# def SurroundPendingOperator(pre_string: string, post_string: string, type: string)

#   var pre_string_len = strlen(pre_string)
#   var post_string_len = strlen(post_string)
#   var leading_pos = getpos("'[")
#   var trailing_pos = getpos("']")
#   # To account of the chars added
#   var offset = 0

#   # Get chars
#   var leading_string = getline(leading_pos[1])[leading_pos[2] - pre_string_len ]
#   var trailing_string = getline(trailing_pos[1])[trailing_pos[2] - pre_string_len - 2]

#   # echom $"{leading_pos[1]},{leading_pos[2] - 2}, {trailing_pos[1]},{trailing_pos[2] - 2}"
#   echom $"leading_string: {leading_string}, trailing_string: {trailing_string}"

#   # I am at the leading position
#   cursor(leading_pos[1], leading_pos[2])
#   if leading_string == pre_string
#     execute($"normal! {pre_string_len}X")
#     offset = -pre_string_len
#   else
#     execute($"normal! i{pre_string}")
#     offset = pre_string_len
#   endif

#   # Some chars have been added if you are working on the same line
#   if leading_pos[1] == trailing_pos[1]
#     cursor(trailing_pos[1], trailing_pos[2] + offset)
#   else
#     cursor(trailing_pos[1], trailing_pos[2])
#   endif

#   # Fix trailing char
#   cursor(leading_pos[1], leading_pos[2])
#   if trailing_chars == post_string
#     execute($"normal! l{post_string_len}x")
#   else
#     execute($"normal! a{post_string}")
#   endif
# enddef

# nnoremap g" <ScriptCmd>&operatorfunc = (type) => Surround('"', '"', type)<cr>g@
# HOW TO WRITE FUNCTION THAT ALLOW COMMAND TO HAVE DOUBLE COMPLETION.
# noremap <unique> <script> <Plug>Highlight2 <esc><ScriptCmd>Highlight('WildMenu')
#

# Example of user-command with multiple args from different lists
# command! -nargs=* -complete=customlist,FooCompleteNope Manim call Foo(<f-args>)

# def FooComplete(current_arg: string, command_line: string, cursor_position: number): list<string>
#   # split by whitespace to get the separate components:
#   var parts = split(command_line, '\s\+')

#   if len(parts) > 2
#     # then we're definitely finished with the first argument:
#     return SecondCompletion(current_arg)
#   elseif len(parts) > 1 && current_arg =~ '^\s*$'
#     # then we've entered the first argument, but the current one is still blank:
#     return SecondCompletion(current_arg)
#   else
#     # we're still on the first argument:
#     return FirstCompletion(current_arg)
#   endif
# enddef

# def FirstCompletion(arg: string): list<string>
#     return ['pippo', 'pluto', 'stocazzo']->filter($'v:val =~ "^{arg}"')
# enddef

# def SecondCompletion(arg: string): list<string>
#     return ['cazzo', 'figa']->filter($'v:val =~ "^{arg}"')
# enddef
