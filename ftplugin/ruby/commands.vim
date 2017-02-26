if exists('b:erb_loaded')
  finish
endif

if &ft =~ 'rspec'
  finish
endif

ConsoleCommand !irb -r'./%' <args>
RunCommand !ruby % <args>

DefineTagFinder Method f,method,F,singleton\ method
DefineTagFinder Module m,module

if !exists('b:alternate_file_matcher')
  let b:alternate_file_matcher = {'pattern': 'lib/\(.*\).rb', 'replacement': 'spec/\1_spec.rb'}
endif
command! -buffer A exe "edit ".substitute(expand('%'), b:alternate_file_matcher.pattern, b:alternate_file_matcher.replacement, '')

command! -buffer R call s:R()
function! s:R()
  let filename   = expand('%')
  let basename   = expand('%:t:r')
  let directory  = expand('%:h')
  let class_name = lib#CapitalCamelCase(basename)
  let pattern    = class_name.'\s\+<\s\+\(\k\+\)'

  call sj#PushCursor()

  if search(pattern)
    let parent_class = lib#ExtractRx(getline('.'), pattern, '\1')
    let parent_class_filename = lib#Underscore(parent_class)
    call sj#PopCursor()
    exe 'edit '.directory.'/'.parent_class_filename.'.rb'
  else
    call sj#PopCursor()
    echoerr "Parent class of ".class_name." not found"
  endif
endfunction

command! -buffer Init call s:Init()
function! s:Init()
  let args = split(lib#GetMotion('vi('), ',\s*')

  let assignments = []
  for arg in args
    let var = matchstr(arg, '^\k\+')
    call add(assignments, '@'.var.' = '.var)
  endfor

  let lineno = line('.')
  call append(lineno, assignments)
  let [start, end] = [lineno + 1, lineno + len(assignments)]

  exe start.','.end.'normal! =='
  call feedkeys('Vimsa=')
endfunction
