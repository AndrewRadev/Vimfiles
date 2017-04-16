RunCommand RustRun
compiler cargo

let b:extract_var_template = 'let %s = %s;'
let b:inline_var_pattern   = '\vlet (\k+)\s+\=\s+(.*);'

let b:outline_pattern = '\s*\%(pub\s*\)\=\(impl\|fn\|struct\|macro_rules!\)\(\s\|$\)'

nmap <buffer> gd <Plug>(rust-def)
nmap <buffer> gm <Plug>(rust-doc)

onoremap <buffer> am :<c-u>call <SID>FunctionTextObject('a')<cr>
xnoremap <buffer> am :<c-u>call <SID>FunctionTextObject('a')<cr>
onoremap <buffer> im :<c-u>call <SID>FunctionTextObject('i')<cr>
xnoremap <buffer> im :<c-u>call <SID>FunctionTextObject('i')<cr>
function! s:FunctionTextObject(mode)
  let saved_position = winsaveview()
  let function_start = search('^\s*\%(pub\s*\)\=fn\>', 'bWc')
  if function_start > 0
    call search('{\s*\%(\/\/.*\)\=$', 'W')
    normal! %
    let function_end = line('.')
  endif
  call winrestview(saved_position)

  if function_start <= 0 || function_end <= 0
    return
  elseif a:mode == 'a'
    if function_start == 1
      " then select whitespace below
      let start = function_start
      let end   = nextnonblank(function_end + 1) - 1
    else
      " select whitespace above
      let start = prevnonblank(function_start - 1) + 1
      let end   = function_end
    endif

    call lib#MarkVisual('V', start, end)
  elseif a:mode == 'i' && (function_end - function_start) > 1
    call lib#MarkVisual('V', function_start + 1, function_end - 1)
  endif
endfunction
