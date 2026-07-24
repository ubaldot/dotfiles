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
  else
    # valid for both popup and windows view
    win_execute(win_id, 'norm q')
  endif
enddef

nnoremap <leader>q <scriptcmd>CalendarToggle()<cr>
