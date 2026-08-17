vim9script

g:markdown_extras_config = {
  smart_table_format: false,
  table_updates_in_window: false,
  use_default_mappings: true,
  block_label: '',
  use_prettier: false,
  link_first_register: 'a',
  format_on_save: false,
  pandoc_args: [$'--css="{$HOME}/dotfiles/my_css_style.css"',
    $'--lua-filter="{$HOME}/dotfiles/emoji-admonitions.lua"']
}
