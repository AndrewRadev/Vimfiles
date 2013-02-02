" TODO (2013-01-31) Create a few more processors:
"
"   - With/Endwith?
"   - Optional args?
"   - Lambda functions?

function! xruntime#Source(path)
  let original_file  = a:path
  let processed_file = tempname().'.vim'

  call xruntime#Compile(original_file, processed_file)

  exe 'source '.processed_file
endfunction

function! xruntime#Runtime(path)
  let original_file  = s:FindPath(a:path)
  let processed_file = tempname().'.vim'

  call xruntime#Compile(original_file, processed_file)

  exe 'source '.processed_file
endfunction

function! xruntime#Compile(original_file, processed_file)
  let lines = readfile(a:original_file)

  let should_inline_function_arguments = 0

  for line in lines
    if line =~ '""" LANGUAGE .*InlineFunctionArguments.*'
      let should_inline_function_arguments = 1
    end
  endfor

  if should_inline_function_arguments
    let lines = s:JoinContinuations(lines)
    let lines = xruntime#inline_function_arguments#Run(lines)
  endif

  call writefile(lines, a:processed_file)
endfunction

function! s:JoinContinuations(lines)
  let processed_lines = []
  let line_parts      = []

  " iterate backwards
  for line in reverse(a:lines)
    if line =~ '^\s*\'
      let part = substitute(line, '^\s*\', '', '')
      call add(line_parts, part)
    else
      " join continued lines
      let real_line = join(reverse(line_parts + [line]), ' ')
      call add(processed_lines, real_line)
      let line_parts = []
    endif
  endfor

  return reverse(processed_lines)
endfunction

function! s:FindPath(path)
  for dir in split(&rtp, ',')
    let full_path = dir.'/'.a:path
    if filereadable(full_path)
      return full_path
    endif
  endfor
endfunction
