vim9script

g:everforest_background = 'soft'
g:everforest_ui_contrast = 'low'
var hour = str2nr(strftime("%H"))
if hour < 7 || 16 < hour
  set background=dark
  colorscheme everforest
else
  set background=light
  colorscheme everforest
endif
#
# colorscheme wildcharm
# set background=light
# colorscheme solarized8_flat
# colorscheme everforest
