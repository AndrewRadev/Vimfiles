if exists('b:erb_loaded')
  finish
endif

setlocal foldmethod=indent

compiler ruby
setlocal makeprg=ruby\ -wc\ %

if &ft =~ 'rspec'
  finish
endif

let b:deleft_closing_pattern = '^\s*end\>'
let b:outline_pattern = '\v^\s*(def|class|module|public|protected|private|(attr_\k{-})|test)(\s|$)'

call ruby_folding#Create()
setlocal nofoldenable
