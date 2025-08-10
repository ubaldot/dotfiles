vim9script

# HelpMe
def HelpMeGetFiles(): list<string>
  return getcompletion($'{g:dotvim}/helpme_files/', 'file')
enddef

def HelpMeComplete(
    arglead: string,
    command_line: string,
    position: number
  ): list<string>

  var helpme_files = HelpMeGetFiles()->map((_, val)  => fnamemodify(val, ':t:r'))
  return helpme_files->filter($'v:val =~ "^{arglead}"')
enddef

def HelpMeShow(filename: string='')
  var helpme_files = HelpMeGetFiles()
  var filename_full = helpme_files->filter((_, val) => val =~ filename)
  if !empty(filename_full)
    exe $"HelpMe {filename_full[0]}"
  else
    HelpMe
  endif
enddef

def HelpMeEdit(filename: string='')
  var helpme_files = HelpMeGetFiles()
  var filename_full = helpme_files->filter((_, val) => val =~ filename)
  if !empty(filename_full)
    exe $"edit {filename_full[0]}"
  else
    echoerr $"File {filename_full[0]} not found"
  endif
enddef

command! -nargs=? -complete=customlist,HelpMeComplete HelpMeShow HelpMeShow(<q-args>)
command! -nargs=? -complete=customlist,HelpMeComplete HelpMeEdit HelpMeEdit(<q-args>)
