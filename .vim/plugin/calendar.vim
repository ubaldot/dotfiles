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

# Open N buffers
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


# Past last N days
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
# Used for adding a day in the month file
def g:TodayUnique()
  const year = strftime('%Y')->str2nr()
  const month = strftime('%m')->str2nr()
  const day = strftime('%d')->str2nr()
  g:CalendarUnique(day, month, year, 0, '')
enddef

# It create files for each month rather than for each day
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
# g:calendar_action = 'g:CalendarActionUnique'
#
#
# ============= ATTEMPT FOR A NEW CALENDAR ======================


# Get number of days in a given month
def DaysInMonth(year: number, month: number): number
    if month == 2
        # Leap year check
        if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
            return 29
        endif
        return 28
    endif
    if index([1, 3, 5, 7, 8, 10, 12], month) != -1
        return 31
    endif
    return 30
enddef

# # Build calendar for a given date
# # Returns weekday of a date (0=Monday, 6=Sunday)
def WeekdayOfDate(year: number, month: number, day: number): number
    var month_tmp = month
    var year_tmp = year
    if month_tmp < 3
        month_tmp += 12
        year_tmp -= 1
    endif
    var K = year % 100
    var J = year / 100
    var h = (day + (13 * (month_tmp + 1)) / 5 + K + (K / 4) + (J / 4) + 5 * J) % 7
    # Zeller's h: 0=Saturday, ..., 6=Friday
    # Convert to Monday=0 ... Sunday=6
    return (h + 5) % 7
enddef

# def CalendarForDate(
#     year: number,
#     month: number,
#     day: number,
#     add_weeknum: bool = true): list<list<number>>

#   var month_days = DaysInMonth(year, month)
#   var first_wday = WeekdayOfDate(year, month, 1)
#   var weeks: list<list<number>> = []
#   var week: list<number> = []
#   var week_num = 1

#   # Fill first row with blanks before day 1
#   for _ in range(first_wday)
#     week->add(0)
#   endfor

#   # Fill days
#   for d in range(1, month_days)
#     week->add(d)
#     if week->len() == 7
#       if add_weeknum
#         week->add(week_num)
#       endif
#       weeks->add(week)
#       week = []
#       week_num += 1
#     endif
#   endfor

#   # Fill trailing blanks
#   if !empty(week)
#     while week->len() < 7
#       week->add(0)
#     endwhile
#     if add_weeknum
#       week->add(week_num)
#     endif
#     weeks->add(week)
#   endif

#   return weeks
# enddef


# Compute ISO 8601 week number for a given date
def ISOWeekNumber(year: number, month: number, day: number): number
    # Zeller's congruence to get weekday (0=Monday,...6=Sunday)
    var y = year
    var m = month
    if m < 3
        m += 12
        y -= 1
    endif
    var K = y % 100
    var J = y / 100
    var h = (day + (13 * (m + 1)) / 5 + K + (K / 4) + (J / 4) + 5 * J) % 7
    var d = (h + 5) % 7  # Monday=0,...Sunday=6

    # Compute day of year
    var days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    # Adjust February for leap year
    if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        days_in_month[1] = 29
    endif
    var doy = day
    for i in range(0, month - 2)
        doy += days_in_month[i]
    endfor

    # ISO week number formula
    var woy = (doy - d + 10) / 7
    if woy < 1
        # Week belongs to last week of previous year
        return ISOWeekNumber(year - 1, 12, 31)
    elseif woy > 52
        # Handle year-end edge cases
        var last_day_wday = ISOWeekNumber(year, 12, 31)
        if last_day_wday == 1 || last_day_wday == 2 || last_day_wday == 3 || last_day_wday == 4
            return 53
        else
            return 1
        endif
    endif
    return woy
enddef

# Generate calendar with optional ISO week numbers at the end
def CalendarForDateISO(year: number, month: number, day: number, add_weeknum: bool = 0): list<list<number>>
    var month_days = DaysInMonth(year, month)
    var first_wday = WeekdayOfDate(year, month, 1)  # weekday 0=Mon
    var weeks: list<list<number>> = []
    var week: list<number> = []

    # Get ISO week number of the first day of the month
    var week_num = ISOWeekNumber(year, month, 1)

    # Fill first week with blanks before day 1
    for _ in range(first_wday)
        week->add(0)
    endfor

    # Fill days
    for d in range(1, month_days)
        week->add(d)
        if week->len() == 7
            if add_weeknum
                week->add(week_num)
            endif
            weeks->add(week)
            week = []
            week_num += 1
        endif
    endfor

    # Fill trailing blanks
    if !empty(week)
        while week->len() < 7
            week->add(0)
        endwhile
        if add_weeknum
            week->add(week_num)
        endif
        weeks->add(week)
    endif

    return weeks
enddef

# Example: Get current date's calendar
var yy = str2nr(strftime('%Y'))
var mm = str2nr(strftime('%m'))
var dd = str2nr(strftime('%d'))
var Ww = str2nr(strftime('%W'))

yy = 1979
mm = 5
dd = 7
# var cal_list =  CalendarForDate(y, m, d)
# var cal_list =  CalendarForDateISO(yy, mm, dd, true)

def PrintCal(year: number, month: number, cal: list<list<number>>)
  only
  vnew

  # Fix head
  var month_str = month_n2_to_str[printf('%02d', month)]
  var padding = max([0, 18 - len(month_str)]) / 2
  var year_month = $"{repeat(' ', padding)}{month_str} {year}"
  appendbufline('%', line('$'), $"{year_month}")
  matchadd('WarningMsg', year_month)

  # Fix weekdays
  var weekdays = 'Su Mo Tu We Th Fr Sa'

  padding = len(cal[0]) == 7 ? 1 : 4
  appendbufline('%', line('$'), $" {weekdays}")
  matchadd('StatusLine', weekdays)

  # Fix actual days
  for line in cal
    var line_cleaned: string =
      line->mapnew((_, val) => printf('%02d', val))
    ->map((_, val) => substitute(val, '00', '  ', 'g'))
    ->map((_, val) => substitute(val, '^0', ' ', 'g'))
    ->map((_, val) => substitute(val, ',', ' ', 'g'))
    ->join()
    appendbufline('%', line('$'), $" {line_cleaned}")
  endfor
enddef

# PrintCal(yy, mm, cal_list)
