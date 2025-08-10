vim9script

# vim-manim setup
var manim_common_flags = '--fps 30 --disable_caching -v WARNING --save_sections'
g:manim_flags = {
  low_quality: $"-pql {manim_common_flags}",
  high_quality: $"-pqh -c ~/Documents/YouTube/ControlTheoryInPractice/"
                    .. $"github_ctip/ctip_manim.cfg {manim_common_flags}",
  dry_run: $'--dry_run {manim_common_flags}',
  transparent: $"-pqh -c ~/Documents/YouTube/ControlTheoryInPractice/"
      .. $"github_ctip/ctip_manim.cfg {manim_common_flags} --transparent"
}
g:manim_default_flag = keys(g:manim_flags)[-1]

if g:os == "Darwin"
  augroup CLOSE_QUICKTIME
    autocmd!
    autocmd! User ManimPre exe "!osascript ~/QuickTimeClose.scpt"
  augroup END
endif

command! ManimNew :enew | :0read ~/.manim/new_manim.txt
