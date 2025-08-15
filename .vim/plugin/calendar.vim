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

# --- Helpers ---
# Number of days in a given month
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

# Build calendar for a given date
# Returns weekday of a date (0=Monday, 6=Sunday)
def WeekdayOfDate(year: number, month: number, day: number): number
    # Implement modified Zeller's congruence
    # Zeller's h: 0=Saturday, ..., 6=Friday
    var month_adj = month
    var year_adj = year
    if month_adj < 3
        month_adj += 12
        year_adj -= 1
    endif
    var h = (day + (13 * (month_adj + 1)) / 5 + year_adj + (year_adj / 4) - (year_adj / 100) + (year_adj / 400)) % 7
    # Convert to Monday=0 ... Sunday=6
    return (h + 5) % 7
enddef

# Compute ISO 8601 week number for a given date
def ISOWeekNumber(year: number, month: number, day: number): number
    var wd = WeekdayOfDate(year, month, day)

    # Day-of-year
    var dim = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        dim[1] = 29
    endif
    var doy = day
    for i in range(0, month - 1)
        if i > 0
            doy += dim[i - 1]
        endif
    endfor

    # Thursday of the week
    var doy_thu = doy + (3 - wd)

    # Days in year
    var days_in_year = 365
    if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        days_in_year = 366
    endif

    # Determine ISO year
    var iso_year = year
    if doy_thu < 1
        iso_year -= 1
        if (iso_year % 4 == 0 && iso_year % 100 != 0) || (iso_year % 400 == 0)
            doy_thu += 366
        else
            doy_thu += 365
        endif
    elseif doy_thu > days_in_year
        iso_year += 1
        doy_thu -= days_in_year
    endif

    # Week 1 start: Monday of the week containing Jan 4
    var jan4_wd = WeekdayOfDate(iso_year, 1, 4)
    var week1_start = 4 - jan4_wd

    # ISO week number
    return float2nr(1 + floor((doy_thu - week1_start - 1) / 7))
enddef

# Generate calendar with optional ISO week numbers at the end, 0=Monday
def CalendarMonth(
    year: number,
    month: number,
    add_weeknum: bool = false): list<list<number>>

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
            # If the first week of January is the same as the previous year,
            # then reset the week number
            week_num = month == 1 && (week_num == 52 || week_num == 53)
              ? 1
              : week_num + 1
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

# TODO: if 1st January is in the last week of December, then it shall be set
# to w1. However, we cannot distinguish the month as we just pass a calendar
# Convert ISO (Monday-start) calendar to US (Sunday-start) calendar
def ConvertISOtoUS(iso_calendar: list<list<number>>, month: number): list<list<number>>
    var us_calendar: list<list<number>> = []
    var carry_sunday = 0
    var carry_week = 0  # ISO week of carried Sunday

    for week in iso_calendar
        var new_week = week[0 : 6]
        var iso_week = week[7]
        var sunday = new_week[6]

        # Prepend carryover Sunday at start
        insert(new_week, carry_sunday, 0)
        remove(new_week, 7)

        # Determine US week number
        # var us_week = carry_sunday != 0 ? carry_week : iso_week
        var us_week = iso_week

        add(new_week, us_week)
        add(us_calendar, new_week)

        # Carry Sunday to next row
        carry_sunday = sunday
        carry_week = iso_week
    endfor

    # Add last row if a Sunday remains
    if carry_sunday != 0
        var last_week = [carry_sunday, 0, 0, 0, 0, 0, 0, carry_week + 1]
        add(us_calendar, last_week)
    endif

    # Remove first row if all zeros
    if count(us_calendar[0][0 : 6], 0) == 7
        remove(us_calendar, 0)
    endif

    # TODO: check it better
    # If 1st of January falls in the last week of the year, then it become the
    # first week of the year
    # if month == 12 && us_calendar[-1][-2] != 31
    #   us_calendar[-1][-1] = 1
    # endif

    return us_calendar
enddef

# Example: Get current date's calendar
var yy = str2nr(strftime('%Y'))
var mm = str2nr(strftime('%m'))
var dd = str2nr(strftime('%d'))
var Ww = str2nr(strftime('%W'))

def DisplaySingleCal(year: number, month: number, start_on_sunday: bool, inc_week: bool): list<list<number>>
  # Identify today
  var is_today_year_month = strftime('%Y') == printf('%04d', year)
      && strftime('%m') == printf('%02d', month)

  # TODO
  const five_days = false

  # Fix head
  var month_str = month_n2_to_str[printf('%02d', month)]
  var padding = max([0, 18 - len(month_str)]) / 2
  var year_month = $"{repeat(' ', padding)}{month_str} {year}"
  appendbufline('%', line('$'), $"{year_month}")
  matchadd('WarningMsg', year_month)

  # Fix weekdays
  var weekdays = start_on_sunday
    ? 'Su Mo Tu We Th Fr Sa'
    : 'Mo Tu We Th Fr Sa Su'

  padding = inc_week ? 4 : 1
  appendbufline('%', line('$'), $" {weekdays}")
  matchadd('StatusLine', weekdays)

  # Actual days
  var cal = start_on_sunday
    ? ConvertISOtoUS(CalendarMonth(year, month, inc_week), month)
    : CalendarMonth(year, month, inc_week)

  # For the highlight
  const col_Sa = start_on_sunday ? 20 : 17
  const col_Su = start_on_sunday ? 2 : 20

  # Build the calendar
  for line in cal
    var firstline = line('$')
    var line_cleaned: string =
      line->mapnew((_, val) => printf('%02d', val))
    ->map((_, val) => substitute(val, '00', '  ', 'g'))
    ->map((_, val) => substitute(val, '^0', ' ', 'g'))
    ->map((_, val) => substitute(val, ',', ' ', 'g'))
    ->join()
    appendbufline('%', firstline, $" {line_cleaned}")

    if !five_days
      # Higlight Saturdays
      range(firstline + 1, line('$'))
        ->map((_, val) => matchaddpos('Special', [[val, col_Sa, 2]]))

      # Highlight Sundays
      range(firstline + 1, line('$'))
        ->map((_, val) => matchaddpos('Error', [[val, col_Su, 2]]))
    endif

    if inc_week
      # Highlight week
      range(firstline + 1, line('$'))
        ->map((_, val) => matchaddpos('CursorLineNr', [[val, 23, 2]]))
    endif

    # Highlight today
    if is_today_year_month
      const today = strftime('%d')
      var line_span = range(firstline + 1, line('$'))
        ->map((_, val) => $'\%{val}l')->join('\|')
      matchadd('DiffAdd', $'{line_span}\zs{today}')
    endif
  endfor
  return cal
enddef

def DisplayMultipleCal(
    year: number,
    month: number,
    start_on_sunday: bool = true,
    inc_week: bool = false,
    N: number = 3)
  vnew
  for ii in range(N)
    DisplaySingleCal(year, month - 1 + ii, start_on_sunday, inc_week)
    appendbufline('%', line('$'), '')
  endfor
enddef

# ===================== TESTS =================================
# Expected results are for January of different years
const expected_results = {
  '2005': [0, 0, 0, 0, 0, 1, 2, 53],
  '2006': [0, 0, 0, 0, 0, 0, 1, 52],
  '2010': [0, 0, 0, 0, 1, 2, 3, 53],
  '2015': [0, 0, 0, 1, 2, 3, 4, 1],
  '2016': [0, 0, 0, 0, 1, 2, 3, 53],
  '2018': [1, 2, 3, 4, 5, 6, 7, 1],
  '2021': [0, 0, 0, 0, 1, 2, 3, 53],
  '2022': [0, 0, 0, 0, 0, 1, 2, 52],
  '2024': [1, 2, 3, 4, 5, 6, 7, 1]
}
var actual_results = {}
var current_result = {}
const test_years = [2005, 2006, 2010, 2015, 2016, 2018, 2021, 2022, 2024]
for yyy in test_years
  var cal = CalendarMonth(yyy, 1, true)
  current_result = {[yyy]: cal[0]}
  extend(actual_results, current_result)
endfor
echom assert_equal(expected_results, actual_results)


# Start on Sunday
const expected_us_results = {
  '2005': [0, 0, 0, 0, 0, 0, 1, 53],  # Jan 1 is Saturday → week 53 prev. year
  '2006': [1, 2, 3, 4, 5, 6, 7, 1],   # Jan 1 is Sunday → week 1
  '2010': [0, 0, 0, 0, 0, 1, 2, 53],   # first Sunday Jan 3
  '2015': [0, 0, 0, 0, 1, 2, 3, 1],   # first Sunday Jan 4
  '2016': [0, 0, 0, 0, 0, 1, 2, 53],   # first Sunday Jan 3
  '2018': [0, 1, 2, 3, 4, 5, 6, 1],   # first Sunday Jan 7
  '2021': [0, 0, 0, 0, 0, 1, 2, 53],   # first Sunday Jan 3
  '2022': [0, 0, 0, 0, 0, 0, 1, 52],   # first Sunday Jan 2
  '2024': [0, 1, 2, 3, 4, 5, 6, 1]    # first Sunday Jan 7
}

actual_results = {}
current_result = {}
for yyy in test_years
  var cal = ConvertISOtoUS(CalendarMonth(yyy, 1, true), 1)
  current_result = {[yyy]: cal[0]}
  extend(actual_results, current_result)
endfor
echom assert_equal(expected_us_results, actual_results)

var XXX  = 2026
vnew
DisplaySingleCal(XXX, 1, false, true)
DisplaySingleCal(XXX, 1, true, true)
