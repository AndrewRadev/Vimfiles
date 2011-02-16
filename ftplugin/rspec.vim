let b:surround_{char2nr('p')} = "pending do \r end"
let b:surround_{char2nr('d')} = "describe do \r end"

RunCommand !rspec % -c -d -fd <args>

command! -buffer A exe "edit ".substitute(expand('%'), 'lib/\(.*\).rb', 'spec/\1_spec.rb', '')

command! -buffer Focus RunCommand exec '!rspec % -c -d -fd --line='.line('.')
command! -buffer Unfocus RunCommand !rspec % -c -d -fd <args>
