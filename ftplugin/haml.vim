let b:surround_{char2nr('t')} = "= t '\r' "

let b:switch_definitions =
      \ [
      \   g:switch_builtins.ruby_hash_style,
      \ ]

xmap <buffer> sO <Plug>CoffeeToolsOpenLineAndIndent

command! -range=% Herbalize call s:Herbalize(<line1>, <line2>)
function! s:Herbalize(start, end)
  let range = a:start.','.a:end

  let initial_whitespace = repeat(' ', indent(a:start))
  silent keeppatterns exe range.'s/^'.initial_whitespace.'//e'
  exe range.'!herbalizer'
endfunction

let b:extract_var_template = '- %s = %s'
let b:inline_var_pattern   = '\v-\s*(\k+)\s+\=\s+(.*)'
