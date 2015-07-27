let b:surround_{char2nr('p')} = "pending do \r end"
let b:surround_{char2nr('d')} = "describe do \r end"
let b:surround_{char2nr('c')} = "context do \r end"

RunCommand !rspec % -c -d -fd <args>

command! -buffer A exe "edit ".substitute(expand('%'), 'spec/\(.*\)_spec.rb', 'lib/\1.rb', '')

command! -buffer Focus RunCommand exec '!rspec % -c -d -fd --line='.line('.')
command! -buffer Unfocus RunCommand !rspec % -c -d -fd <args>

" Transform should-syntax to expect-syntax
command! -buffer Expect call s:Expect()
function! s:Expect()
  s/^\s*\zs\(.\{-}\)\.should/expect(\1).to/e
endfunction

let b:outline_pattern = '\v^\s*(it|specify|describe|context|feature|background|scenario).*do$'
