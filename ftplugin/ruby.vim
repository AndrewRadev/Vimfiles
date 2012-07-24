setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

setlocal foldmethod=indent

compiler ruby

" surround area with <foo> (...) { }
if !exists('b:erb_loaded')
  let b:surround_{char2nr('i')} = "if \1if: \1 \r end"
  let b:surround_{char2nr('u')} = "unless \1unless: \1 \r end"
  let b:surround_{char2nr('w')} = "while \1while: \1 do \r end"
  let b:surround_{char2nr('e')} = "\1collection: \1.each do |\2item: \2| \r end"
  let b:surround_{char2nr('m')} = "module \r end"
  let b:surround_{char2nr('d')} = "do\n \r end"
endif

let b:surround_{char2nr(':')} = ":\r"
let b:surround_{char2nr('#')} = "#{\r}"

let b:surround_indent = 1

ConsoleCommand !irb -r'./%' <args>

DefineTagFinder Method f,method,F,singleton\ method
DefineTagFinder Module m,module

" Define a text object for block arguments (do |...|)
onoremap <buffer> i\| :<c-u>normal! T\|vt\|<cr>
xnoremap <buffer> i\| :<c-u>normal! T\|vt\|<cr>
onoremap <buffer> a\| :<c-u>normal! F\|vf\|<cr>
xnoremap <buffer> a\| :<c-u>normal! F\|vf\|<cr>

" Look up the word under the cursor on apidock:
nnoremap <buffer> gm :Doc ruby<cr>

" Make conditional expressions true or false
command! -buffer True  call s:True()
command! -buffer False call s:False()
command! -buffer Maybe call s:Maybe()
function! s:True()
  s/if \(.\{-\}\)\($\|#.*\)/if (true or (\1))\2/e
  s/unless \(.\{-\}\)\($\|#.*\)/unless (false and (\1))\2/e
endfunction
function! s:False()
  s/if \(.\{-\}\)\($\|#.*\)/if (false and (\1))\2/e
  s/unless \(.\{-\}\)\($\|#.*\)/unless (true or (\1))\2/e
endfunction
function! s:Maybe()
  s/if (true or (\(.\{-}\)))\(.*\)/if \1\2/e
  s/if (false and (\(.\{-}\)))\(.*\)/if \1\2/e
  s/unless (true or (\(.\{-}\)))\(.*\)/if \1\2/e
  s/unless (false and (\(.\{-}\)))\(.*\)/if \1\2/e
endfunction

if !exists('b:erb_loaded')
  " fold nicely -- experimental
  call RubyFold()
  setlocal nofoldenable

  if &ft == 'ruby'
    command! -buffer A exe "edit ".substitute(expand('%'), 'lib/\(.*\).rb', 'spec/\1_spec.rb', '')

    let b:outline_pattern = '\v^\s*(def|class|module|public|protected|private)(\s|$)'

    RunCommand !ruby % <args>
  endif
endif

if @% =~ 'step_definitions'
  let b:fswitchdst  = 'feature'
  let b:fswitchlocs = 'rel:..'

  let b:outline_pattern = '\v^\s*(Given|When|Then)'
endif

let b:switch_definitions =
      \ [
      \   ['word', {
      \       ':\(\k\+\) =>': '\1:',
      \       '\<\(\k\+\):':  ':\1 =>',
      \     }
      \   ]
      \ ]
