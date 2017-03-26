if @% =~ '_spec\.cr'
  " Specs
  let b:outline_pattern = '\v^\s*(it|specify|describe|context).*do$'

  if !exists('b:alternate_file_matcher')
    let b:alternate_file_matcher = {'pattern': 'spec/\(.*\)_spec.cr', 'replacement': 'src/\1.cr'}
  endif
else
  " Code
  let b:outline_pattern = '\v^\s*(def|class|struct|module|public|private|protected)(\s|$)'

  if !exists('b:alternate_file_matcher')
    let b:alternate_file_matcher = {'pattern': 'src/\(.*\).cr', 'replacement': 'spec/\1_spec.cr'}
  endif
endif

command! -buffer A exe "edit ".substitute(expand('%'), b:alternate_file_matcher.pattern, b:alternate_file_matcher.replacement, '')

let b:deleft_closing_pattern = '^\s*end\>'
