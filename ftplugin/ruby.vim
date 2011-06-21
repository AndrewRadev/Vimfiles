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
let b:surround_{char2nr('u')} = "unless \1unless: \1 \r end"
let b:surround_{char2nr('w')} = "while \1while: \1 do \r end"
let b:surround_{char2nr('e')} = "\1collection: \1.each do |\2item: \2| \r end"
let b:surround_{char2nr('m')} = "module \r end"
let b:surround_{char2nr('d')} = "do\n \r end"

let b:surround_{char2nr(':')} = ":\r"

let b:surround_indent = 1

ConsoleCommand !irb -r % <args>

" Define a text object for block arguments (do |...|)
onoremap <buffer> i\| :<c-u>normal! T\|vt\|<cr>
xnoremap <buffer> i\| :<c-u>normal! T\|vt\|<cr>
onoremap <buffer> a\| :<c-u>normal! F\|vf\|<cr>
xnoremap <buffer> a\| :<c-u>normal! F\|vf\|<cr>

if !exists('b:erb_loaded')
  " fold nicely -- experimental
  call RubyFold()

  if &ft == 'ruby'
    command! -buffer A exe "edit ".substitute(expand('%'), 'lib/\(.*\).rb', 'spec/\1_spec.rb', '')
    command! -buffer Outline call lib#Outline('\v^\s*(def|class|module)')

    RunCommand !ruby % <args>
  endif
endif

if @% =~ 'step_definitions'
  let b:fswitchdst  = 'feature'
  let b:fswitchlocs = 'rel:..'
endif
