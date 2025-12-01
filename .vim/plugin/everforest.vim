vim9script

g:everforest_background = 'soft'
g:everforest_ui_contrast = 'low'
var hour = str2nr(strftime("%H"))
if hour < 7 || 16 < hour
  set background=dark
else
  set background=light
endif
#
colorscheme everforest
# colorscheme wildcharm
# set background=light
# set background=dark
# colorscheme solarized8_flat
# colorscheme everforest
