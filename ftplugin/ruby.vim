setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

setlocal foldmethod=indent

setlocal tags+=~/tags/ruby.tags
setlocal tags+=~/tags/gems.tags

compiler ruby

" surround area with <foo> (...) { }
let b:surround_{char2nr('i')} = "if \1if: \1 \r end"
let b:surround_{char2nr('w')} = "while \1while: \1 do \r end"
let b:surround_{char2nr('e')} = "\1collection: \1.each do |\2item: \2| \r end"
let b:surround_{char2nr('m')} = "module do \r end"
let b:surround_{char2nr('d')} = "do \r end"

let b:surround_{char2nr(':')} = ":\r"

let b:surround_indent = 1

ConsoleCommand !irb -r % <args>

if !exists('b:erb_loaded') && &ft == 'ruby'
	" fold nicely -- experimental
	call RubyFold()

  if expand('%') =~ '_spec.rb'
    RunCommand !rspec --color --format documentation % <args>
    command! -buffer A exe "edit ".substitute(expand('%'), 'spec/\(.*\)_spec.rb', 'lib/\1.rb', '')
  else
    RunCommand !ruby % <args>
    command! -buffer A exe "edit ".substitute(expand('%'), 'lib/\(.*\).rb', 'spec/\1_spec.rb', '')
  endif
endif

if @% =~ 'step_definitions'
  let b:fswitchdst	= 'feature'
  let b:fswitchlocs = 'rel:..'
endif
