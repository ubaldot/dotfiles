vim9script

# ======== SCRIPT FOR PLOTTING: EXAMPLE USAGE =====================

# Input data
# const xs = FloatRange(0.0, 10, 0.1)
# const ys = xs->mapnew((_, val) => 1.0 - exp(-1.0 * val))

# Function call
# const my_plot_str = PlotSimple_GNUPlot(xs, ys, 'Time [s]', 'T [C]', 'Il mio cazzo')
# const my_plot_str = PlotSimple_plotext(xs, ys, 'Time [s]', 'T [C]', 'Il mio cazzo')
#
# ---------------- Helper functions for floats ----------------
def Min_float(lst: list<float>): float
  var m = lst[0]
  for val in lst
    if val < m
      m = val
    endif
  endfor
  return m
enddef

def Max_float(lst: list<float>): float
  var m = lst[0]
  for val in lst
    if val > m
      m = val
    endif
  endfor
  return m
enddef

# Aux function for generating x-axis
def FloatRange(start: float, stop: float, step: float): list<float>
 const n_steps = float2nr(ceil((stop - start) / step))
 return range(0, n_steps)->mapnew((ii, _) => start + ii * step)
enddef

# ======== Function for making simple plots ==============
def g:PlotSimple_plotext(x: list<float>,
    y: list<float>,
    x_label: string = 'x',
    y_label: string = 'y',
    title: string = '',
    ): list<string>

  # Requires plotext python package
  g:x_tmp = x
  g:y_tmp = y
  g:x_label_tmp = x_label
  g:y_label_tmp = y_label
  g:title_tmp = title

  # Generate g:my_plot variable
  py3 << EOF
import vim, plotext as plt

# Grab lists from Vim (they arrive as list of strings)
x = list(map(float, vim.eval("g:x_tmp")))
y = list(map(float, vim.eval("g:y_tmp")))
x_label = vim.eval("g:x_label_tmp")
y_label = vim.eval("g:y_label_tmp")
title = vim.eval("g:title_tmp")

plt.clear_figure()
plt.clc()
plt.title(title)
plt.xlabel(x_label)
plt.ylabel(y_label)
plt.plot(x, y)

# Set g:my_plot
vim.vars["my_plot"] = plt.build().splitlines()
EOF

  # Retrieve plot & avoiding polluting global namespace
  const my_plot = g:my_plot
  unlet g:my_plot
  unlet g:x_tmp
  unlet g:y_tmp
  unlet g:x_label_tmp
  unlet g:y_label_tmp
  unlet g:title_tmp

  # Plot in a split buffer
  vnew
  setline(1, my_plot)
  return my_plot
enddef


# ======== Example 2 plotext from CLI ==============
def PlotSimple_not_working(x: list<float>, y: list<float>): list<string>
  # DO NOT USE It shows the color-codes
  $PYTHONUTF8 = '1'

  const tmp_file = tempname()
  # Arrange data in the tmp_file as
  # 0 1
  # 1 3
  # 2 3
  # 3 5

  var lines = x->mapnew((ii, xi) => $'{string(xi)} {string(y[ii])}')
  # Write data to tmp file
  writefile(lines, tmp_file)

  var cmd = [
    "plotext",
    "plot",
    "--path",
    $"{tmp_file}",
    "--xcolumn",
    "1",
    "--ycolumns",
    "2",
    "--clear_terminal",
    "True",
  ]

  vnew
  exe $":read! {join(cmd)}"
  return getline(1, line('$'))
enddef

# ======== GNUPLOT from CLI ========================

# ---------------- Main plotting function ----------------
def g:PlotSimple_GNUPlot(x: list<float>,
    y: list<float>,
    x_label: string = 'x',
    y_label: string = 'y',
    title: string = '',
    ): list<string>

  const tmp_file = tempname()

  # Write "x,y" pairs into temp file
  var lines = x->mapnew((ii, xi) => $'{string(xi)} {string(y[ii])}')
  writefile(lines, tmp_file)

  # Compute ranges
  var x_min = Min_float(x)
  var x_max = Max_float(x)
  var y_min = Min_float(y)
  var y_max = Max_float(y)

  # Add 5% padding
  var dx = (x_max - x_min) * 0.05
  var dy = (y_max - y_min) * 0.05
  x_min -= dx
  x_max += dx
  y_min -= dy
  y_max += dy

  # Terminal width = number of samples (cap 100)
  var term_w = min([len(x), 80])

  # Terminal height = proportional to y-range (10–30)
  var term_h = float2nr((y_max - y_min) * 20.0)
  if term_h < 10
    term_h = 10
  elseif term_h > 30
    term_h = 30
  endif

  # Build gnuplot command
  var cmd = [
    'gnuplot',
    '-e',
    printf('"set term dumb %d %d; ', term_w, term_h) ..
    'set key off; ' ..
    'set tics scale 0; ' ..
    # $'set xlabel \"{x_label}\"; set ylabel \"{y_label}\"; set title \"{title}\";' ..
    printf('set xrange [%f:%f]; ', x_min, x_max) ..
    printf('set yrange [%f:%f]; ', y_min, y_max) ..
    printf("plot '%s' with dots title 'data'\"", tmp_file)
  ]

  echom join(cmd)

  # Insert plot into a new buffer
  vnew
  exe $":read! {join(cmd)}"
  return getline(1, line('$'))
enddef
