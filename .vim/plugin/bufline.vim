vim9script

# ---------- Bufline -----------------------
#  OBS! DOES NOT WORK WITH GVIM
# -----------------------------------------
set showtabline=2

if !exists('*g:SpawnBufferLine')
  def g:SpawnBufferLine(): string
    # var s = pwd .. ' | '
    var s = ''

    # Get the list of buffers. Use bufexists() to include hidden buffers
    var bufferNums = filter(range(1, bufnr('$')), 'buflisted(v:val)')
    # Making a buffer list on the left side
    for i in bufferNums
      # Highlight with yellow if it's the current buffer
      s ..= (i == bufnr()) ? ('%#TabLineSel#') : ('%#TabLine#')
      s = $'{s}{i} '		# Append the buffer number
      if bufname(i) == ''
        s = $'{s}[NEW]'		# Give a name to a new buffer
      endif
      if getbufvar(i, '&modifiable')
        s ..= fnamemodify(bufname(i), ':t')	# Append the file name
        # s ..= pathshorten(bufname(i))  # Use this if you want a trimmed path
        # If the buffer is modified, add + and separator. Else, add separator
        s ..= (getbufvar(i, "&modified")) ? (' [+] |') : (' |')
      else
        s ..= fnamemodify(bufname(i), ':t') .. ' [RO] | '  # Add read only flag
      endif
    endfor
    s = $'{s}%#TabLineFill#%T'  # Reset highlight

    s = $'{s}%='			# Spacer

    # Making a tab list on the right side
    for i in range(1, tabpagenr('$'))  # Loop through the number of tabs
      # Highlight with yellow if it's the current tab
      s ..= (i == tabpagenr()) ? ('%#TabLineSel#') : ('%#TabLine#')
      s = $'{s}%{i}T '		# set the tab page number (for mouse clicks)
      s = $'{s}{i}'		# set page number string
    endfor
    s = $'{s}%#TabLineFill#%T'	# Reset highlight

    # Close button on the right if there are multiple tabs
    if tabpagenr('$') > 1
      s = $'{s}%999X X'
    endif

    return s
  enddef
endif
# ---------- Bufline -----------------------

set tabline=%!SpawnBufferLine()  # Assign the tabline
