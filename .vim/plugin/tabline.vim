vim9script

# ---------- Bufline -----------------------
#  OBS! DOES NOT WORK WITH GVIM
# -----------------------------------------
set showtabline=2

if !exists('*g:SpawnBufferLine')
  def g:SpawnBufferLine(): string
    # var s = pwd .. ' | '
    var buf_line = ''

    # Get the list of buffers. Use bufexists() to include hidden buffers
    var bufferNums = range(1, bufnr('$'))->filter((_, val) => buflisted(val))
    # Making a buffer list on the left side
    for i in bufferNums
      # Highlight with yellow if it's the current buffer
      buf_line ..= (i == bufnr()) ? ('%#TabLineSel#') : ('%#TabLine#')
      buf_line = $'{buf_line}{i} '		# Append the buffer number
      if bufname(i) == ''
        buf_line = $'{buf_line}[NEW]'		# Give a name to a new buffer
      endif
      if getbufvar(i, '&modifiable')
        buf_line ..= fnamemodify(bufname(i), ':t')	# Append the file name
        # buf_line ..= pathshorten(bufname(i))  # Use this if you want a trimmed path
        # If the buffer is modified, add + and separator. Else, add separator
        buf_line ..= (getbufvar(i, "&modified")) ? (' [+] |') : (' |')
      else
        buf_line ..= fnamemodify(bufname(i), ':t') .. ' [RO] | '  # Add read only flag
      endif
    endfor
    buf_line = $'{buf_line}%#TabLineFill#%T'  # Reset highlight

    buf_line = $'{buf_line}%='			# Spacer

    # Making a tab list on the right side
    for i in range(1, tabpagenr('$'))  # Loop through the number of tabs
      # Highlight with yellow if it's the current tab
      buf_line ..= (i == tabpagenr()) ? ('%#TabLineSel#') : ('%#TabLine#')
      buf_line = $'{buf_line}%{i}T '		# set the tab page number (for mouse clicks)
      buf_line = $'{buf_line}{i}'		# set page number string
    endfor
    buf_line = $'{buf_line}%#TabLineFill#%T'	# Reset highlight

    # Close button on the right if there are multiple tabs
    if tabpagenr('$') > 1
      buf_line = $'{buf_line}%999X X'
    endif

    return buf_line
  enddef
endif
# ---------- Bufline -----------------------

set tabline=%!SpawnBufferLine()  # Assign the tabline
