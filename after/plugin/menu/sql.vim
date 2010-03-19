command! -nargs=* Sql call s:Sql(<f-args>)
function s:Sql(...)
  " Figure out the scratch sql file's name
  if a:0 > 0
    let scratch_name = a:1
  else
    let scratch_name = 'scratch.sql'
  endif

  " Open it
  exe 'e '.scratch_name

  " Place the menu at the right, 20 cols wide
  20vnew
  let m = g:MenuBuffer.create({ 'rootLabel': 'tables' })

  call m.addPath('asset', {'exe': 'echo', 'args': ['"asset table"'], 'close': 0})
  call m.addPath('user', {'exe': 'echo', 'args': ['"user table"'], 'close': 0})

  call m.render()

  " Open up another split
  wincmd l | split | wincmd k | wincmd j
endfunction
