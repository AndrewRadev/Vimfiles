set foldmethod=indent

let b:switch_definitions =
      \ [
      \   g:switch_builtins.ruby_hash_style,
      \ ]

nmap <buffer> <localleader>dh <Plug>CoffeeToolsDeleteAndDedent
xmap <buffer> <localleader>dh <Plug>CoffeeToolsDeleteAndDedent
nmap <buffer> <localleader>O  <Plug>CoffeeToolsOpenLineAndIndent
xmap <buffer> <localleader>O  <Plug>CoffeeToolsOpenLineAndIndent
