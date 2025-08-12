vim9script

g:markdown_extras_config = {}
g:markdown_extras_config['use_default_mappings'] = true
g:markdown_extras_config['block_label'] = ''
g:markdown_extras_config['use_prettier'] = true
g:markdown_extras_config['format_on_save'] = false
g:markdown_extras_config['pandoc_args'] =
  [$'--css="{$HOME}/dotfiles/my_css_style.css"',
  $'--lua-filter="{$HOME}/dotfiles/emoji-admonitions.lua"']
# g:markdown_extras_indices = ['testfile.md', 'testfile_1.md', 'testfile_2.md']
g:markdown_extras_index = {foo: 'testfile.md', bar: 'testfile_1.md', zoo: 'testfile_2.md'}
