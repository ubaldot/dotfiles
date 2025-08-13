vim9script

# vim-calendar
g:calendar_datetime = 'statusline'
g:calendar_weeknm = 5
g:calendar_mark = 'right'
g:calendar_search_grepprg = 'internal'
g:calendar_no_mappings = true
g:calendar_keys = {
  close: '<esc>',
  goto_next_month: '<C-down>',
  goto_prev_month: '<C-up>',
  goto_prev_year: '<C-left>',
  goto_next_year: '<C-right>'
}

# All available diaries
var path_diary =  'C:\Users\yt75534\OneDrive - Volvo Group\CabClimate\diary'
var path_dddiary =  'C:\Users\yt75534\OneDrive - Volvo Group\CabClimate\dddiary'

# the idx specify what diary you are working on
g:calendar_diary_list = [
       {name: 'Cab climate', path: path_diary,
         ext: '_cc.md'},
       {name: 'Thermal supply', path: path_dddiary,
         ext: '_ts.md'},
     ]
g:calendar_diary_list_curr_idx = 0

# Adjust for WSL
if g:os == "WSL"
  for item in g:calendar_diary_list
    item.path = item.path->substitute('\\', '/' ,'g')->substitute('C:', '/mnt/c')
  endfor
elseif g:os == "Darwin"
  g:calendar_diary_list = [
    {name: 'My diary', path: $HOME .. '/my_diary', ext: '.md'},
  ]
endif

# Collect info from passed periods
const month_n2_to_str = {
  01: "January",
  02: "February",
  03: "March",
  04: "April",
  05: "May",
  06: "June",
  07: "July",
  08: "August",
  09: "September",
  10: "October",
  11: "November",
  12: "December",
}

# Collect last month
# Open 1 buffer with a summary
def g:MonthSummary(month_req: number = -1)
  # const month = month_req == -1 ? strftime('%m') : $"0{month_req}"[-2 : ]
  const month = month_req == -1 ? strftime('%m') : month_req
  const year = strftime("%Y")

  # This is needed if you stack all the pages in one buffer
  const bufname = $'{month_n2_to_str[month]} {year}'

  var win_list = win_findbuf(bufnr(bufname))
  if !empty(win_list)
    for w in win_list
      win_execute(w, 'bw!')
    endfor
  endif

  vnew
  wincmd H
  set ft=markdown

  exe $"file {bufname}"

  const path = g:calendar_diary_list[g:calendar_diary_list_curr_idx].path
  const full_path = $"{path}/{year}/{month}"
  if isdirectory(full_path)
    const files = readdir(full_path)->map((_, val) => $"{full_path}/{val}")

    var day = ''
    # Don't pick the last day
    for filename in files[: -2]
      if filereadable(filename)
        # Append on one single file
        day = filename->fnamemodify(':t:r')
        appendbufline('%', 0, ['', $"## {year} {month_n2_to_str[month]} {day}"])
        appendbufline('%', 2, readfile(filename))
      endif
    endfor
    cursor(1, 1)
  else
    bw!
    confirm($"Directory {full_path} does not exists")
  endif
enddef
command! -nargs=? CalendarMonthSummary g:MonthSummary(<args>)

# Open N buffers
def g:MonthPages(month_req: number = -1)
  # OBS: You need vim-calendar
  g:calendar_files = []
  const month = month_req == -1 ? strftime('%m') : month_req
  const year = strftime("%Y")

  const path = g:calendar_diary_list[g:calendar_diary_list_curr_idx].path
  const full_path = $"{path}/{year}/{month}"
  if isdirectory(full_path)
    const files = readdir(full_path)->map((_, val) => $"{full_path}/{val}")

    var day = ''
    for filename in files
      if filereadable(filename)
        exe $"edit {filename}"
        add(g:calendar_files, filename)
      endif
    endfor
  else
    confirm($"Directory {full_path} does not exists")
  endif
enddef
command! -nargs=? CalendarMonth g:MonthPages(<args>)

def CalendarClearPages()
  for file in g:calendar_files
    exe $"bw! {file->fnamemodify(':t')}"
  endfor
enddef
command! -nargs=0 CalendarClearPages CalendarClearPages()

def g:CalendarToday()

    var base_dir = g:calendar_diary_list[g:calendar_diary_list_curr_idx].path
    var year  = strftime('%Y')
    var month = strftime('%m')
    month = len(month) == 1 ? $"0{month}"[-2 : ] : month
    var day   = strftime('%d')

    const ext = g:calendar_diary_list[g:calendar_diary_list_curr_idx].ext
    var filename = $"{base_dir}/{year}/{month}/{day}{ext}"

    if filereadable(filename)
      exe $"edit {filename}"
    else
      exe $"vnew {filename}"
    endif
enddef
command! -nargs=0 CalendarToday g:CalendarToday()

# Open N buffers
def g:LastNDaysPages()

    g:calendar_files = []
    const N_default = 10
    var N_str = input($'How many days (default {N_default})? ')
    var N = empty(N_str) ? N_default : str2nr(N_str)

    var base_dir = g:calendar_diary_list[g:calendar_diary_list_curr_idx].path
    var ts = localtime()  # start from now

    for _ in range(N)
        var year  = strftime('%Y', ts)
        var month = strftime('%m', ts)
        month = len(month) == 1 ? $"0{month}"[-2 : ] : month
        var day   = strftime('%d', ts)
        day = len(day) == 1 ? $"0{day}"[-2 : ] : day

        const ext = g:calendar_diary_list[g:calendar_diary_list_curr_idx].ext
        var filename = $"{base_dir}/{year}/{month}/{day}{ext}"

        if filereadable(filename)
          exe $"edit {filename}"
          add(g:calendar_files, filename)
        endif

        # 86400 is the number of seconds in one day, 3600 * 24
        ts -= 86400  # go back one day
    endfor
enddef
command! -nargs=0 CalendarLastDays g:LastNDaysPages()


# Pass last N days
def g:LastNDaysPagesSummary()

    const N_default = 10
    var N_str = input($'How many days (default {N_default})? ')
    var N = empty(N_str) ? N_default : str2nr(N_str)
    var today = strftime('%d')

    vnew
    wincmd H
    exe $"file 'last {N} days'"
    set ft=markdown

    var base_dir = g:calendar_diary_list[g:calendar_diary_list_curr_idx].path
    var ts = localtime()  # start from now

    for _ in range(N)
        var year  = strftime('%Y', ts)
        var month = strftime('%m', ts)
        month = len(month) == 1 ? $"0{month}"[-2 : ] : month
        var day   = strftime('%d', ts)
        day = len(day) == 1 ? $"0{day}"[-2 : ] : day

        const ext = g:calendar_diary_list[g:calendar_diary_list_curr_idx].ext
        var filename = $"{base_dir}/{year}/{month}/{day}{ext}"

        if filereadable(filename) && day != today
            appendbufline('%', line('$'), ['', $"## {year} {month_n2_to_str[month]} {day}"])
            appendbufline('%', line('$'), readfile(filename))
            appendbufline('%', line('$'), '')
        endif

        # 86400 is the number of seconds in one day, 3600 * 24
        ts -= 86400  # go back one day
    endfor
    deletebufline('%', 1)
enddef
command! -nargs=0 CalendarLastDaysSummary g:LastNDaysPagesSummary()


def g:Today()
  const year = strftime('%Y')->str2nr()
  const month = strftime('%m')->str2nr()
  const day = strftime('%d')->str2nr()
  g:CalendarUnique(day, month, year, 0, '')
enddef

# Toggle calendar
def CalendarToggle()
  const calendar_id = bufwinid('__Calendar')
  if calendar_id > 0
    win_execute(calendar_id, 'q')
  else
   Calendar
  endif
enddef

nnoremap <leader>C <ScriptCmd>CalendarToggle()<cr>

# Unique calendar
def g:CalendarUnique(
    day: number,
    month: number,
    year: number,
    week: number,
    dir: string)

    const year_str = year->printf("%04d")
    const month_str = month->printf("%02d")
    var day_str = day->printf("%02d")

    const filename = $"{g:calendar_diary}/{year_str}/{month_n2_to_str[month_str]}.md"
    vnew
    exe $"edit {filename}"
    const header_original = $"# {year_str} {month_n2_to_str[month_str]} {day_str}"

    # Attempt to search a good day
    cursor(1, 1)
    var header = header_original
    var found_line = search(header, 'cW')
    var day_curr = day
    while found_line == 0 && day_curr > 0
      day_curr = day_curr - 1
      day_str = day_curr->printf("%02d")
      header = $"# {year_str} {month_n2_to_str[month_str]} {day_str}"
      found_line = search(header, 'cW')
    endwhile

    if found_line != 0 && getline(found_line) != header_original
      appendbufline('%', found_line - 1, [header_original, ''])
      norm! k
    elseif found_line == 0
      # It means that this is the oldest day
      appendbufline('%', line('$'), [header_original, ''])
      norm! j
    endif
enddef
# g:calendar_action = 'g:CalendarUnique'
