setlocal tabstop=8
setlocal shiftwidth=8
setlocal noexpandtab

iabbr null NULL

nmap <buffer> gm :exe "Man ".expand("<cword>")<cr>

let b:outline_pattern = '^\k'

RunCommand !./a.out <args>

let s:type_pattern       = '\%(\k\|*\|&\)\+'
let s:definition_pattern = '^'.s:type_pattern.'\s\+\(\k\+\)(.*$'

if !exists(':Implement')
  command! Implement call s:Implement()
  function! s:Implement()
    let function_line        = getline('.')
    let function_name        = substitute(function_line, s:definition_pattern, '\1', '')
    let function_definition  = substitute(function_line, ';$', ' {', '')
    let nearby_function_name = ''

    " First, check if there is a function declaration below, so we can put this
    " one in the same place
    if search(s:definition_pattern, 'W') > 0
      let nearby_function_name = substitute(getline('.'), s:definition_pattern, '\1', '')
    endif

    " Go to the implementation file
    A

    " Position ourselves
    normal! gg
    if nearby_function_name != '' && search('^\s*'.s:type_pattern.'\s\+'.nearby_function_name, 'W') > 0
      normal! gk
    else
      normal! Go
    endif

    " Add the skeleton of an implementation
    call append(line('.'), [function_definition, '', '}', ''])
    normal! gjgj
    call feedkeys('cc')
  endfunction

  command! Update call s:Update()
  function! s:Update()
    let view = winsaveview()

    try
      if search(s:definition_pattern, 'Wb') <= 0
        echohl WarningMsg | echomsg "Couldn't find a function around" | echohl NONE
        return
      endif

      let function_line        = getline('.')
      let function_name        = substitute(function_line, s:definition_pattern, '\1', '')
      let function_declaration = substitute(function_line, '\s*{$', '', '').';'

      " Go to the header file
      A

      " Find the function declaration
      if search('^\s*'.s:type_pattern.'\s\+'.function_name, '') <= 0
        echohl WarningMsg
        echomsg "Couldn't find function in header. (Note: Should probably implement automatic adding)"
        echohl NONE

        A

        return
      endif

      " Update!
      call append(line('.'), function_declaration)
      delete _
      update

      " Go back to the implementation
      A
    finally
      call winrestview(view)
    endtry
  endfunction
endif
