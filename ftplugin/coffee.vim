setlocal foldmethod=indent
setlocal foldenable

RunCommand CoffeePreviewToggle

let b:outline_pattern = '^\s*\%(class\|\k\+\%(:\|\s*=\).*[-=]>$\)'

nnoremap s; :call <SID>ToggleFunctionDefinition()<cr>
function! s:ToggleFunctionDefinition()
  let line = getline('.')

  let saved_cursor = getpos('.')

  if line =~ '^\s*\%(\k\|\.\)\+:'
    s/:/ =/
  elseif line =~ '^\s*\%(\k\|\.\)\+\s\+='
    s/\s*=\s*/: /
  endif

  call setpos('.', saved_cursor)
endfunction

nnoremap <buffer> gm :Doc js<cr>

xmap <buffer> sO <Plug>CoffeeToolsOpenLineAndIndent
nmap <buffer> dh <Plug>CoffeeToolsDeleteAndDedent

autocmd Syntax * hi link coffeeSpecialVar Identifier

inoremap <buffer> <bs> <bs><c-r>=<SID>HighlightMatchingIndent()<cr>
inoremap <buffer> <tab> <tab><c-r>=<SID>HighlightMatchingIndent()<cr>

autocmd InsertLeave <buffer> match none

function! s:HighlightMatchingIndent()
  let indent = indent(line('.'))

  if indent == -1
    return ''
  endif

  let whitespace = repeat(' ', indent)
  exe 'match MatchParen /^'.whitespace.'\zs\S/'

  return ''
endfunction
