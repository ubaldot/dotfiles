vim9script

g:everforest_background = 'soft'
g:everforest_ui_contrast = 'low'
var hour = str2nr(strftime("%H"))
if hour < 7 || 18 < hour
  set background=dark
else
  set background=light
endif
#
colorscheme catppuccin
# colorscheme wildcharm
# set background=dark
# set background=light
# set background=dark
# colorscheme solarized8_flat
# colorscheme everforest
