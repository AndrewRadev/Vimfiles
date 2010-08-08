function! rake#Run()
  let task = rake#GetCurrentTask()
  if task == ''
    echohl WarningMsg | echo 'No task found here.' | echohl None
  else
    execute "!rake ".task
  endif
endfunction

function! rake#GetCurrentTask()
  let save_cursor = getpos('.')

  if (searchpair('\<task\>', '', '\<end\>', 'bcW') < 0)
    return ''
  endif

  let task = lib#ExtractRx(getline('.'), 'task :\(\k\+\)', '\1')

  let namespace_found = searchpair('\<namespace\>', '', '\<end\>', 'bW')
  while namespace_found > 0
    let namespace = lib#ExtractRx(getline('.'), 'namespace :\(\k\+\)', '\1')
    let task = namespace.':'.task
    let namespace_found = searchpair('\<namespace\>', '', '\<end\>', 'bW')
  endwhile

  call setpos('.', save_cursor)

  return task
endfunction
