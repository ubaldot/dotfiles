vim9script

g:calendar_config = {
  position: 'left',
  cal_type: 'eu',
  week_display_type: 'work',
  week_cell_width: 25,
  show_week_number: true,
  number_of_months: 3,
  holidays: {'2026-12-25': 'Christmas'},
  diaries_dict: {
    Notes: {
      path: '~/notes',
    },
  },
  active_diary: 'Notes'
}

nnoremap W <Cmd>CalendarToggle<cr>
