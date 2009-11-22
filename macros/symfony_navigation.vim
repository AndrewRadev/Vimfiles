command! Ejavascript exe "edit web/js/".CurrentAppName()."/".CurrentModuleName().".js"
command! Eview exe "edit apps/".CurrentAppName()."/modules/".CurrentModuleName()."/templates/".CurrentActionName()."Success.php"

let s:PS = has('win32') ? '\\' : '/'
let s:capture_group = '\(.\{-}\)'
let s:anything = '.*'

function! CurrentModuleName()
  let rx = '^'

  let rx .= s:anything
  let rx .= 'modules'
  let rx .= s:PS
  let rx .= s:capture_group
  let rx .= s:PS

  let rx .= s:anything
  let rx .= '$'

  let result = substitute(expand('%:p'), rx, '\1', '')

  return result
endfunction

function! CurrentAppName()
  let rx = '^'

  let rx .= s:anything
  let rx .= 'apps'
  let rx .= s:PS
  let rx .= s:capture_group
  let rx .= s:PS

  let rx .= s:anything
  let rx .= '$'

  let result = substitute(expand('%:p'), rx, '\1', '')

  return result
endfunction

function! CurrentActionName()
  let path = expand('%:p')

  if path =~# 'templates' " we're in a view
    return substitute(path, '^.*[/\]templates[/\]\(.\{-}\)Success\.php', '\1', '')
  else " we're in an action
    let function_line = search('function', 'b')
    if function_line == 0
      throw "Didn't find a function"
    else
      let rx = '^'

      let rx .= s:anything
      let rx .= 'function'
      let rx .= '\s\+'
      let rx .= 'execute'
      let rx .= s:capture_group
      let rx .= '\s*'
      let rx .= '('

      let rx .= s:anything
      let rx .= '$'

      let result = substitute(getline(function_line), rx, '\l\1', '')

      return result
    endif
  endif
endfunction
