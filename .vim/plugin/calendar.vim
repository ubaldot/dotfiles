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
    item.path = item.path->substitute('\\', '/', 'g')->substitute('C:', '/mnt/c', 'g')
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

# Collect last month, resolution in days, i.e. ~/diary/year/month/day_cc.md
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

# Open N buffers, resolution in days, i.e. ~/diary/year/month/day_cc.md
def g:CalendarMonthPages(month_req: number = -1)
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
command! -nargs=? CalendarMonthPages g:CalendarMonthPages(<args>)

# Clear pages when you have N buffers open, resolution in days, i.e. ~/diary/year/month/day_cc.md
def CalendarClearPages()
  # Clear all the pages but today
  if exists('g:calendar_files') && !empty(g:calendar_files)
    const today = strftime('%Y/%m/%d')
    for file in g:calendar_files
      if file !~ today
        exe $"bw! {file->fnamemodify(':t')}"
      endif
    endfor
  endif
enddef
command! -nargs=0 CalendarClearPages CalendarClearPages()


# Open today's calendar page, resolution in days, i.e. ~/diary/year/month/day_cc.md
def g:CalendarToday()

    # Close all the windows
    const saved_win = win_getid()
    exe "only"
    var base_dir = g:calendar_diary_list[g:calendar_diary_list_curr_idx].path
    var year  = strftime('%Y')
    var month = strftime('%m')
    month = len(month) == 1 ? $"0{month}"[-2 : ] : month
    var day   = strftime('%d')

    const ext = g:calendar_diary_list[g:calendar_diary_list_curr_idx].ext
    var filename = $"{base_dir}/{year}/{month}/{day}{ext}"

    exe $"edit {filename}"
    # g:LastNDaysPagesSummary(30)
    g:LastNDaysPages(10)
    win_gotoid(saved_win)
enddef
command! -nargs=0 CalendarToday g:CalendarToday()

# Open N buffers, resolution in days, i.e. ~/diary/year/month/day_cc.md
def g:LastNDaysPages(N_req: number = 0)

  g:calendar_files = []

  var N = 0
  if N_req == 0
    const N_default = 10
    var N_str = input($'How many days (default {N_default})? ')
    N = empty(N_str) ? N_default : str2nr(N_str)
  else
    N = N_req
  endif

  var base_dir = g:calendar_diary_list[g:calendar_diary_list_curr_idx].path
  var ts = localtime()  # start from now
  vnew

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
command! -nargs=? CalendarLastDaysPages g:LastNDaysPages(<args>)


# Past last N days, resolution in days, i.e. ~/diary/year/month/day_cc.md
def g:LastNDaysPagesSummary(N_req: number = 0)

  var N = 0
  if N_req == 0
    const N_default = 10
    var N_str = input($'How many days (default {N_default})? ')
    N = empty(N_str) ? N_default : str2nr(N_str)
  else
    N = N_req
  endif

  var today = strftime('%d')
  vnew
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
command! -nargs=? CalendarLastDaysSummary g:LastNDaysPagesSummary(<args>)


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

# =========== Unique calendar =================
# Instead of using resolution at days level
# (i.e. g:calendar_diary/year/month/day.md)
# you have it at month level (i.e. g:calendar_diary/year/month/day.md)
#
# You have to set g:calendar_action, see EOF and change cab_climate dashboard
# TODO: a function for finding the last N days in this case
# =============================================
#
# Used for adding a day in the ~/diary/year/Month.md file
def g:CalendarTodayUnique()
  if !exists('g:calendar_diary')
    Calendar
    close
  endif
  const year = strftime('%Y')->str2nr()
  const month = strftime('%m')->str2nr()
  const day = strftime('%d')->str2nr()
  g:CalendarActionUnique(day, month, year, 0, '')
enddef

# What to do when you hit <cr> on the calendar.
# It append a new day in the  ~/diary/year/Month.md
def g:CalendarActionUnique(
    day: number,
    month: number,
    year: number,
    week: number,
    dir: string)

    # Header day format used in search is # {year} {month} {day}
    const year_str = year->printf("%04d")
    const month_str = month->printf("%02d")
    var day_str = day->printf("%02d")

    const filename = $"{g:calendar_diary}/{year_str}/{month_n2_to_str[month_str]}.md"
    # vsplit
    exe $"edit {filename}"
    const header_original = $"## {year_str} {month_n2_to_str[month_str]} {day_str}"

    # Attempt to search a good day
    cursor(1, 1)
    var header = header_original
    var found_line = search(header, 'cW')
    var day_curr = day
    while found_line == 0 && day_curr > 0
      day_curr = day_curr - 1
      day_str = day_curr->printf("%02d")
      header = $"## {year_str} {month_n2_to_str[month_str]} {day_str}"
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
g:calendar_action = 'g:CalendarActionUnique'
#
#
# ============= ATTEMPT FOR A NEW CALENDAR ======================

# import autoload g:dotvim .. "/pack/minpac/start/vim-calendar/autoload/backend.vim" as be
# import autoload g:dotvim .. "/pack/minpac/start/vim-calendar/autoload/frontend.vim" as fe
# import "./backend.vim" as be
# import "./frontend.vim" as fe
# ===================== TESTS =================================
# Expected results are for January of different years
# const expected_results = [
#   {'January 2005': [0, 0, 0, 0, 0, 1, 2, 53]},
#   {'January 2006': [0, 0, 0, 0, 0, 0, 1, 52]},
#   {'January 2010': [0, 0, 0, 0, 1, 2, 3, 53]},
#   {'January 2015': [0, 0, 0, 1, 2, 3, 4, 1]},
#   {'January 2016': [0, 0, 0, 0, 1, 2, 3, 53]},
#   {'January 2018': [1, 2, 3, 4, 5, 6, 7, 1]},
#   {'January 2021': [0, 0, 0, 0, 1, 2, 3, 53]},
#   {'January 2022': [0, 0, 0, 0, 0, 1, 2, 52]},
#   {'January 2024': [1, 2, 3, 4, 5, 6, 7, 1]}
# ]
# const test_years = [2005, 2006, 2010, 2015, 2016, 2018, 2021, 2022, 2024]
# for [idx, y] in items(test_years)
#   var [head, vals] = items(be.CalendarMonth_iso8601(y, 1, true))[0]
#   var current_result = {[head]: vals[0]}
#   # echom assert_equal(expected_results[idx], current_result)
# endfor


# # Start on Sunday
# const expected_us_results = [
#   {'January 2005': [0, 0, 0, 0, 0, 0, 1, 53]},  # Jan 1 is Saturday → week 53 prev. yea
#   {'January 2006': [1, 2, 3, 4, 5, 6, 7, 1]},   # Jan 1 is Sunday → week
#   {'January 2010': [0, 0, 0, 0, 0, 1, 2, 53]},   # first Sunday Jan
#   {'January 2015': [0, 0, 0, 0, 1, 2, 3, 1]},   # first Sunday Jan
#   {'January 2016': [0, 0, 0, 0, 0, 1, 2, 53]},   # first Sunday Jan
#   {'January 2018': [0, 1, 2, 3, 4, 5, 6, 1]},   # first Sunday Jan
#   {'January 2021': [0, 0, 0, 0, 0, 1, 2, 53]},   # first Sunday Jan
#   {'January 2022': [0, 0, 0, 0, 0, 0, 1, 52]},   # first Sunday Jan
#   {'January 2024': [0, 1, 2, 3, 4, 5, 6, 1]}    # first Sunday Jan
# ]

# for [idx, y] in items(test_years)
#   var [head, vals] = items(be.ConvertISOtoUS(be.CalendarMonth_iso8601(y, 1, true)))[0]
#   var current_result = {[head]: vals[0]}
#   # echom assert_equal(expected_us_results[idx], current_result)
# endfor
# echom assert_equal(expected_us_results, actual_results)

# var XXX  = 2021
# vnew
# fe.DisplaySingleCal(XXX, 4, false, true)
# fe.DisplaySingleCal(XXX, 4, true, true)
