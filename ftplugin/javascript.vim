let g:jsl_config = '$HOME/.jsl'
if !exists('b:current_compiler')
  compiler jsl
  b:current_compiler = 'jsl'
endif
