" TODO (2012-04-10) autocommand?
function! NodeExpressIncludeExpr(filename)
  let line            = getline('.')
  let partial_pattern = 'partial\s*[''"]'.a:filename.'[''"]'

  if line =~ partial_pattern
    return s:FindFileByBasename('app/views/'.a:filename)
  else
    return a:filename
  endif
endfunction

function! s:FindFileByBasename(path)
  let files = glob(a:path.'.*')

  if files == ''
    return a:path
  else
    return split(files, "\n")[0]
  endif
endfunction

set includeexpr=NodeExpressIncludeExpr(v:fname)
