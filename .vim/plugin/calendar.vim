vim9script

g:calendar_config = {
  position: 'popup',
  cal_type: 'eu',
  show_week_number: true,
  number_of_months: 3,
  holidays: {'2026-12-25': 'Christmas'},
  diaries_dict: {
    Notes: {path: '~/notes', resolution: 'month'},
  },
  active_diary: 'Notes'
}

def CalendarToggle()

  messages clear
  const win_id = bufwinid('__Calendar')

  if win_id == -1
    Calendar
  elseif bufname() != '__Calendar'
    win_execute(win_id, 'close')
  else
    close
  endif
enddef

nnoremap <leader>z <scriptcmd>CalendarToggle()<cr>
