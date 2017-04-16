setlocal foldmethod=indent
setlocal foldenable

RunCommand CoffeePreviewToggle

set define=^\\s*\\ze\\k\\+:\\s*[-=]>

let b:surround_{char2nr('$')} = "$(\r)"
let b:outline_pattern = '^\s*\%(class\|\k\+\%(:\|\s*=\).*[-=]>$\)'

let b:match_words = '\<if\>:\<else\>'
let b:match_skip = 'R:^\s*'

onoremap <buffer> im :<c-u>call coffee_tools#FunctionTextObject('i')<cr>
onoremap <buffer> am :<c-u>call coffee_tools#FunctionTextObject('a')<cr>
xnoremap <buffer> im :<c-u>call coffee_tools#FunctionTextObject('i')<cr>
xnoremap <buffer> am :<c-u>call coffee_tools#FunctionTextObject('a')<cr>

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

autocmd Syntax * hi link coffeeSpecialVar Identifier

" Breaks snippets:
" inoremap <buffer> <bs> <bs><c-r>=<SID>HighlightMatchingIndent()<cr>
" inoremap <buffer> <tab> <tab><c-r>=<SID>HighlightMatchingIndent()<cr>

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
