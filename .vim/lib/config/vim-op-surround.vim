vim9script

g:op_surround_maps = [
  {map: "sa'", open_delim: "''", close_delim: "''", action: "append"},
  {map: "sd'", open_delim: "''", close_delim: "''", action: "delete"},
  {map: "sab", open_delim: "[", close_delim: "]", action: "append"},
  {map: "sdb", open_delim: "[", close_delim: "]", action: "delete"},
  {map: "sap", open_delim: "(", close_delim: ")", action: "append"},
  {map: "sdp", open_delim: "(", close_delim: ")", action: "delete"},
  {map: "sac", open_delim: "{", close_delim: "}", action: "append"},
  {map: "sdc", open_delim: "{", close_delim: "}", action: "delete"}
]
for [open, close] in [['"', '"'], ['`', '`']]
  # Append mappings
  add(g:op_surround_maps, {
    map: $"sa{open}",
    open_delim: open,
    close_delim: close,
    action: 'append'})

  # Delete mappings
  add(g:op_surround_maps, {
    map: $"sd{open}",
    open_delim: open,
    close_delim: close,
    action: 'delete'})
endfor
