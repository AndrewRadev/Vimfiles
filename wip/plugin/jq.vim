" TODO (2016-07-15) What to do with multiple args? What about namespacing with
" "|"?

command! -nargs=* -complete=custom,s:JqComplete Jq call s:Jq(<q-args>)
function! s:Jq(args)
  exe 'silent %!jq '.shellescape(a:args)
endfunction

function! s:JqComplete(argument_lead, command_line, cursor_position)
  let prefix = substitute(a:argument_lead, '\.[^.]\+$', '', '')
  let keys = s:ExecKeys(expand('%'), prefix)
  return join(s:NamespaceKeys(prefix, keys), "\n")
endfunction

function! s:NormalizePath(path)
  let path = a:path

  if path == ''    | let path = '.'      | endif
  if path !~ '^\.' | let path = '.'.path | endif

  let path = substitute(path, '\(.\+\)\.$', '\1', '')

  return path
endfunction

function! s:NamespaceKeys(prefix, keys)
  let path = s:NormalizePath(a:prefix)
  let keys = copy(a:keys)

  if path == '.'
    let path = ''
  endif

  return map(keys, 'path.".".v:val')
endfunction

function! s:ExecKeys(filename, path)
  let path = s:NormalizePath(a:path)
  let command = 'jq '.shellescape(path.' | keys').' '.shellescape(a:filename)
  let result = system(command)

  if v:shell_error
    return []
  else
    return json_decode(result)
  endif
endfunction
