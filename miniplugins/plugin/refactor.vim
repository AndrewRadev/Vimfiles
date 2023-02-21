" Note: Depends on splitjoin.vim

xmap so :<c-u>call <SID>ExtractVar()<cr>
nmap si :<c-u>call <SID>InlineVar('normal')<cr>
xmap si :<c-u>call <SID>InlineVar('visual')<cr>

function! s:ExtractVar()
  let saved_view = winsaveview()
  let var_name = input("Variable name: ")

  if exists('b:extract_var_template')
    let extract_var_template = b:extract_var_template
  else
    let extract_var_template = '%s = %s'
  endif

  let body = sj#Trim(sj#GetMotion('gv'))
  call sj#ReplaceMotion('gv', var_name)

  let declaration = printf(extract_var_template, var_name, body)
  let declaration_lines = split(declaration, "\n")
  call append(line('.') - 1, declaration_lines)

  " Indent all lines and position at the start
  exe 'normal! '.len(declaration_lines).'k'.len(declaration_lines).'==0'

  if search('${[^}]\+}', 'Wc', line('.') + len(declaration_lines) - 1)
    " delete the first '$'
    normal! "_x
    " remove the surrounding curly brackets
    let placeholder = sj#GetMotion('vi{')
    call sj#ReplaceMotion('va{', placeholder)

    if len(placeholder) > 1
      exe "normal! v".(len(placeholder) - 1)."l\<c-g>"
    else
      exe "normal! v\<c-g>"
    endif

    " don't restore cursor position
    return
  endif

  call winrestview(saved_view)
endfunction

function! s:InlineVar(mode) abort
  if exists('b:inline_var_pattern')
    let declaration_pattern = '^.\{-}'.b:inline_var_pattern.'\s*$'
  else
    let declaration_pattern = '\v^.{-}(\k+)\s+\=\s+(.*)$'
  endif

  if a:mode == 'normal'
    let declaration = getline('.')
  elseif a:mode == 'visual'
    let declaration = sj#GetMotion('gv')
  else
    echoerr "Unknown mode: ".a:mode
    return
  endif

  if declaration !~ declaration_pattern
    if a:mode == 'normal'
      let message = "Couldn't find a declaration on the current line"
    else
      let message = "Couldn't find a declaration in the selection"
    endif

    echohl WarningMsg | echo message | echohl None
    return
  endif

  let declaration_lines = split(declaration, "\n")

  let var_name  = s:ExtractRx(declaration, declaration_pattern, '\1')
  let body_start = s:ExtractRx(declaration_lines[0], declaration_pattern, '\2')

  let body_lines = [body_start]
  call extend(body_lines, declaration_lines[1:(len(declaration_lines) - 1)])
  let body = join(body_lines, "\r")

  let declaration_start_line = line('.')
  let [from, to] = GetScopeLimits()
  " only replace variables after the declaration (note: could just get the end
  " in that case?)
  let from = max([from, declaration_start_line])

  exe from
  normal! $
  let tick = b:changedtick
  while search('\<'.var_name.'\>', 'W', to)
    keeppatterns exe line('.').'s/\<'.var_name.'\>/'.escape(body, '\/&').'/gc'

    if tick != b:changedtick
      if len(body_lines) > 1
        exe 'normal! '.(len(body_lines) - 1).'k'.len(body_lines).'=='
        let to += (len(body_lines) - 1)
      endif

      let tick = b:changedtick
    endif
  endwhile

  " Remove the original declaration
  let delete_start = declaration_start_line
  let delete_end = declaration_start_line + (len(body_lines) - 1)
  silent exe delete_start.','.delete_end.'delete _'
endfunction

function! GetScopeLimits()
  let indent = indent(line('.'))

  " first, go upwards
  let current  = line('.')
  let previous = prevnonblank(current - 1)
  while current > 0 && indent(previous) >= indent
    let current  = previous
    let previous = prevnonblank(current - 1)
  endwhile

  let from = current

  " then, go downwards
  let current = line('.')
  let next    = nextnonblank(current + 1)
  let last    = line('$')
  while current < last && indent(next) >= indent
    let current = next
    let next    = nextnonblank(current + 1)
  endwhile

  let to = current

  return [from, to]
endfunction

" Extracts a regex match from a string.
" Original in autoload/lib.vim
function! s:ExtractRx(expr, pat, sub)
  let rx = a:pat

  if stridx(a:pat, '^') != 0
    let rx = '^.*'.rx
  endif

  if strridx(a:pat, '$') + 1 != strlen(a:pat)
    let rx = rx.'.*$'
  endif

  return substitute(a:expr, rx, a:sub, '')
endfunction
