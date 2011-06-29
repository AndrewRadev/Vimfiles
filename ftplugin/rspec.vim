let b:surround_{char2nr('p')} = "pending do \r end"
let b:surround_{char2nr('d')} = "describe do \r end"
let b:surround_{char2nr('c')} = "context do \r end"

RunCommand !rspec % -c -d -fd <args>

command! -buffer A exe "edit ".substitute(expand('%'), 'spec/\(.*\)_spec.rb', 'lib/\1.rb', '')

command! -buffer Focus RunCommand exec '!rspec % -c -d -fd --line='.line('.')
command! -buffer Unfocus RunCommand !rspec % -c -d -fd <args>
command! -buffer Outline call lib#Outline('\v^\s*(it|describe|context).*do$')

" Toggle complementing conditions easily:
nmap <buffer> - :call <SID>ToggleShould()<cr>
function! s:ToggleShould()
  let line = getline('.')

  if line =~ '\<should\>'
    call lib#InPlace('s/should /should_not /e')
  elseif line =~ '\<should_not\>'
    call lib#InPlace('s/should_not /should /e')
  endif
endfunction
