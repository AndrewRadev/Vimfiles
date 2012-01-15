command! -nargs=1 -complete=file Rnew call s:Rnew(<f-args>)
function! s:Rnew(name)
  let parts     = split(a:name, '/')
  let base_name = parts[-1]
  let dir_parts = parts[0:-2]

  let underscored_name = base_name
  if underscored_name =~ '\.rb$'
    let underscored_name = fnamemodify(underscored_name, ':r')
  endif
  let camelcased_name = lib#CapitalCamelCase(underscored_name)

  call s:CreateRubyFile(underscored_name, dir_parts)
  call s:CreateRubySpec(underscored_name, dir_parts)

  redraw!
endfunction

function! s:CreateRubyFile(name, dir_parts)
  let file_name = join(a:dir_parts + [a:name . '.rb'], '/')
  let class_name = lib#CapitalCamelCase(a:name)
  call s:EnsureDirectoryExists(file_name)

  exe 'edit '.file_name
  call append(0, [
        \ 'class '.class_name,
        \ 'end',
        \ ])
  $delete _
  normal! gg
  write
endfunction

function! s:CreateRubySpec(name, dir_parts)
  let spec_name = join(a:dir_parts + [a:name . '_spec.rb'], '/')
  let class_name = lib#CapitalCamelCase(a:name)

  if spec_name =~ '\<app/'
    let spec_name = s:SubstitutePathSegment(spec_name, 'app', 'spec')
  else
    let spec_name = s:SubstitutePathSegment(spec_name, 'lib', 'spec')
  endif

  call s:EnsureDirectoryExists(spec_name)

  exe 'split '.spec_name
  call append(0, [
        \ 'require ''spec_helper''',
        \ '',
        \ 'describe '.class_name.' do',
        \ 'end',
        \ ])
  $delete _
  normal! gg
  write
endfunction

function! s:SubstitutePathSegment(expr, segment, replacement)
  return substitute(a:expr, '\(^\|/\)'.a:segment.'\(/\|$\)', '\1'.a:replacement.'\2', '')
endfunction

function! s:EnsureDirectoryExists(file)
  let dir = fnamemodify(a:file, ':p:h')

  if !isdirectory(dir)
    call mkdir(dir, 'p')
  endif
endfunction
