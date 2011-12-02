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

  let file_name = join(dir_parts + [underscored_name . '.rb'], '/')
  let spec_name = join(dir_parts + [underscored_name . '_spec.rb'], '/')

  if spec_name =~ '\<app/'
    let spec_name = s:SubstitutePathSegment(spec_name, 'app', 'spec')
  else
    let spec_name = s:SubstitutePathSegment(spec_name, 'lib', 'spec')
  endif

  call s:EnsureDirectoryExists(file_name)
  call s:EnsureDirectoryExists(spec_name)

  exe 'edit '.file_name
  write
  call s:InsertRubyClass(camelcased_name)

  exe 'split '.spec_name
  write
  call s:InsertRubyClassSpec(camelcased_name)
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

function! s:InsertRubyClass(class_name)
  call append(0, [
        \ 'class '.a:class_name,
        \ 'end',
        \ ])
  normal! Gddgg
  write
endfunction

function! s:InsertRubyClassSpec(class_name)
  call append(0, [
        \ 'require ''spec_helper''',
        \ '',
        \ 'describe '.a:class_name.' do',
        \ 'end',
        \ ])
  normal! Gddgg
  write
endfunction
