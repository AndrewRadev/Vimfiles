RunCommand RustRun
compiler cargo

setlocal tags+=Cargo.tags

nnoremap <buffer> gm :call <SID>Doc()<Cr>

let b:extract_var_template = 'let %s = %s;'
let b:inline_var_pattern   = '\vlet (\k+)%(: [^=]+)?\s+\=\s+(.*);'

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
