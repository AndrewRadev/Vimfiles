command! -nargs=* Sql call s:Sql(<f-args>)
function s:Sql(...)
  " Clear the area
  silent only

  " Figure out the scratch sql file's name
  if a:0 > 0
    let scratch_name = a:1
  elseif exists('g:sql_scratch_file_name')
    let scratch_name = g:sql_scratch_file_name
  else
    let scratch_name = 'scratch.sql'
  endif

  " Open it
  exe 'e '.scratch_name

  " Open up result buffer
  let g:dbext_default_buffer_lines = 15
  normal _slt

  " Place the menu at the right, 30 cols wide
  vertical 30new
  let m = g:MenuBuffer.create({ 'rootLabel': 'database' })
  setlocal nowrap

  " Fire up completion, 'dictionary' holds the temp file with names {{{1
  call s:BuildSqlMenu(m)

  call m.render()

  redraw!
endfunction

function! s:BuildSqlMenu(m)
  DBCompleteTables
  for t_name in readfile(split(&dictionary, ',')[-1])
    if t_name == '' | continue | endif

    call a:m.addPath('Tables.'.t_name.'.data', {
          \ 'exe': 'DBSelectFromTable',
          \ 'args': ['"'.t_name.'"'],
          \ 'close': 0
          \ })
    call a:m.addPath('Tables.'.t_name.'.explain', {
          \ 'exe': 'DBDescribeTable',
          \ 'args': ['"'.t_name.'"'],
          \ 'close': 0
          \ })
  endfor

  DBCompleteViews
  for t_name in readfile(split(&dictionary, ',')[-1])
    call a:m.addPath('Views.'.t_name, {
          \ 'exe': 'DBSelectFromTable',
          \ 'args': ['"'.t_name.'"'],
          \ 'close': 0
          \ })
  endfor

  call a:m.render()
endfunction
