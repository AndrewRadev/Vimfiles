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
  let saved_view = winsaveview()

  try
    let arglist = lib#GetMotion('vi(')
    if arglist == ''
      return
    endif
    let args = split(arglist, ',\s*')

    let existing_assignment_block = lib#GetMotion('vim')
    let existing_assignments = {}
    if existing_assignment_block =~ '^def'
      " then the whole method was selected as the "inner" method, so no
      " assignments
    else
      for line in split(existing_assignment_block, "\n")
        let line = lib#Trim(line)
        let var = matchstr(line, '^@\zs\k\+\ze\s*=')
        if var != ''
          let existing_assignments[var] = v:true
        endif
      endfor
    endif

    let assignments = []
    for arg in args
      let var = matchstr(arg, '^\k\+')
      if !get(existing_assignments, var, 0)
        call add(assignments, '@'.var.' = '.var)
      endif
    endfor

    if len(assignments) <= 0
      return
    endif

    let lineno = line('.')
    call append(lineno, assignments)
    let [start, end] = [lineno + 1, lineno + len(assignments)]

    exe start.','.end.'normal! =='
    exe start.','.end.'normal sa='
  finally
    call winrestview(saved_view)
  endtry
endfunction
