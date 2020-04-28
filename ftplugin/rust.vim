RunCommand RustRun
compiler cargo

setlocal tags+=Cargo.tags

nnoremap <buffer> gm :call <SID>Doc()<cr>

let b:extract_var_template = 'let %s = %s;'
let b:inline_var_pattern   = 'let \%(\s*mut\s\+\)\=\(\k\+\)\%(: [^=]\+\)\=\s\+=\s\+\(.*\);'

let b:outline_pattern = '\s*\%(pub\s*\)\=\(impl\|fn\|struct\|macro_rules!\)\(\s\|$\)'

cmap <buffer><script><expr> <Plug><ctag> substitute(<SID>RustCursorTag(),'^$',"\<c-c>",'')

nmap <buffer> <c-]>       :<c-u>exe v:count1."tag <Plug><ctag>"<cr>
nmap <buffer> g<c-]>      :<c-u>exe          "tjump <Plug><ctag>"<cr>
nmap <buffer> g]          :<c-u>exe          "tselect <Plug><ctag>"<cr>
nmap <buffer> <c-w>]      :<c-u>exe v:count1."stag <Plug><ctag>"<cr>
nmap <buffer> <c-w><c-]>  :<c-u>exe v:count1."stag <Plug><ctag>"<cr>
nmap <buffer> <c-w>g<c-]> :<c-u>exe          "stjump <Plug><ctag>"<cr>
nmap <buffer> <c-w>g]     :<c-u>exe          "stselect <Plug><ctag>"<cr>
nmap <buffer> <c-w>}      :<c-u>exe v:count1."ptag <Plug><ctag>"<cr>
nmap <buffer> <c-w>g}     :<c-u>exe v:count1."ptjump <Plug><ctag>"<cr>

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

command! Emain edit src/main.rs

let s:wrap_types = ['Result', 'Option', 'Rc']

command! -buffer -complete=customlist,s:WrapComplete -nargs=+
      \ Wrap call s:Wrap(<f-args>)

" TODO (2020-04-11) Unwrap

function! s:Wrap(type, ...)
  let wrap_type = a:type

  if wrap_type == 'Result'
    " TODO (2020-04-11) custom error type
    let wrap_left = 'Result<'
    let wrap_right = ', TODOError>'
  else
    let wrap_left = wrap_type.'<'
    let wrap_right = '>'
  endif

  if wrap_type == 'Result'
    let value_wrapper = 'Ok'
  elseif wrap_type == 'Option'
    let value_wrapper = 'Some'
  else
    let value_wrapper = wrap_type
  endif

  let saved_view = winsaveview()
  let skip_syntax = sj#SkipSyntax(['String', 'Comment'])

  try
    " to the end of the line, so it works on the first line of the function
    normal! $

    " Handle return type:
    if sj#SearchSkip(')\_s\+->\_s\+\zs.\{-}\ze\s*\%(where\|{\)', skip_syntax, 'Wbc') > 0
      " there's a return type, match it, wrap it:
      call sj#Keeppatterns('s/\%#.\{-}\ze\s*\%(where\|{\)/'.wrap_left.'\0'.wrap_right.'/')
    elseif sj#SearchSkip(')\_s*\%(where\|{\)', skip_syntax, 'Wbc') > 0
      " no return type, so consider it ():
      call sj#Keeppatterns('s/)\_s*\%(where\|{\)/'.wrap_left.'()'.wrap_right.'/')
    endif

    " Find start and end of function:
    let start_line = line('.')
    call sj#SearchSkip('{$', skip_syntax, 'Wc')
    normal! %
    let end_line = line('.')
    exe start_line

    " Handle return statements:
    while search('\<return\s\+.*;', 'W', end_line) > 0
      let syntax_group = synIDattr(synID(line('.'),col('.'),1),'name')
      if syntax_group == 'rustKeyword'
        call sj#Keeppatterns('s/\%#return \zs.*\ze;/'.value_wrapper.'(\0)/')
      end
    endwhile

    " Handle end expression
    let last_line = prevnonblank(end_line - 1)
    call s:WrapExpression(last_line, value_wrapper, start_line)
  finally
    call winrestview(saved_view)
  endtry
endfunction

function! s:WrapExpression(last_lineno, wrapper, limit)
  let last_lineno       = a:last_lineno
  let expr_start_lineno = a:last_lineno
  let current_lineno    = a:last_lineno

  let wrapper     = a:wrapper
  let limit       = a:limit
  let prev_lineno = prevnonblank(last_lineno - 1)

  let skip_syntax = sj#SkipSyntax(['String', 'Comment'])
  let operator_pattern = '[,*/%+\-|.]'

  " jump to the line
  exe last_lineno
  normal! $

  if sj#SearchSkip('}$', skip_syntax, 'bWc', last_lineno) > 0
    " TODO it's a block, check contents
    normal! %
    let expr_start_lineno = line('.')
    let current_lineno = expr_start_lineno
    let prev_lineno = prevnonblank(current_lineno - 1)
  endif

  while sj#SearchSkip('^\s*'.operator_pattern, skip_syntax, 'Wbc', current_lineno) > 0 ||
        \ sj#SearchSkip(operator_pattern.'\s*$', skip_syntax, 'Wb', prev_lineno) > 0
    let expr_start_lineno = prev_lineno
    let current_lineno    = prev_lineno
    let prev_lineno       = prevnonblank(prev_lineno - 1)

    normal! k

    if prev_lineno <= limit
      " we've gone past the start of the function, bail out
      return
    endif
  endwhile

  let body = sj#Trim(join(getbufline('%', expr_start_lineno, last_lineno), "\n"))
  let body = wrapper.'('.body.')'
  call sj#ReplaceLines(expr_start_lineno, last_lineno, body)
endfunction

function! s:WrapComplete(argument_lead, _command_line, _cursor_position)
  let types = copy(s:wrap_types)
  call filter(types, {_, t -> t =~? a:argument_lead})
  call sort(types)
  return types
endfunction

function! s:Doc()
  let term = expand('<cword>')
  let [imported_symbols, aliases] = s:ParseImports()
  let namespaces = values(imported_symbols)
  let packages = map(namespaces, {_, ns -> split(ns, '::')[0]})
  let url = ""

  if getline('.') =~ 'extern crate '.term.';'
    call Open('https://docs.rs/'.term)
  elseif term == 'std'
    call Open('https://doc.rust-lang.org/std')
  elseif index(packages, term) >= 0
    call Open('https://docs.rs/'.term)
  elseif has_key(imported_symbols, term)
    let namespace = imported_symbols[term]
    if namespace =~ 'std::'
      let path = substitute(namespace, '::', '/', 'g')
      call Open('https://doc.rust-lang.org/'.path.'/?search='.term)
    else
      if has_key(aliases, term)
        let term = aliases[term]
      endif

      let path = substitute(namespace, '::', '/', 'g')
      let package = split(namespace, '::')[0]
      call Open('https://docs.rs/'.package.'/latest/'.path.'/?search='.term)
    endif
  else
    echomsg "Don't know how to open docs for '".term."' in this context"
  endif
endfunction

function! s:ParseImports()
  let imported_symbols = {}
  let aliases = {}

  for line in filter(getline(1, '$'), {_, l -> l =~ '^\s*use'})
    let namespace = matchstr(line, '^\s*use \zs.\+\ze::')
    let symbols = []

    if line =~ '::\k\+ as \k\+;'
      let real_name      = matchstr(line, '::\zs\k\+\ze as \k\+;')
      let alias          = matchstr(line, '::\k\+ as \zs\k\+\ze;')
      let symbols        = [alias]
      let aliases[alias] = real_name
    endif

    if symbols == []
      let symbols = [matchstr(line, '::\zs\k\+\ze;')]
    endif
    if symbols == [""]
      let symbols = split(matchstr(line, '::{\zs.*\ze};'), ',\s*')
    endif
    if symbols == []
      continue
    endif

    for symbol in symbols
      let imported_symbols[symbol] = namespace
    endfor
  endfor

  return [imported_symbols, aliases]
endfunction

function! s:RustCursorTag() abort
  let [_, aliases] = s:ParseImports()
  let identifier = expand('<cword>')

  if has_key(aliases, identifier)
    return aliases[identifier]
  else
    return identifier
  endif
endfunction
