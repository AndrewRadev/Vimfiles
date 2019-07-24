if exists('b:erb_loaded')
  finish
endif

setlocal foldmethod=indent

compiler ruby
setlocal makeprg=ruby\ -wc\ %

" Look up the word under the cursor on apidock:
nnoremap <buffer> gm :Doc ruby<cr>

if &ft =~ 'rspec'
  finish
endif

let b:deleft_closing_pattern = '^\s*end\>'
let b:outline_pattern = '\v^\s*(def|class|module|public|protected|private|(attr_\k{-})|test)(\s|$)'

call RubyFold()
setlocal nofoldenable
