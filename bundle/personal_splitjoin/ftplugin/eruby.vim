function! b:ErbDetectSplit()
  let line = getline('.')

  let option_regex    = '\v((,[^,]+\s+\=\>\s+[^,]{-1,})+)(\s*do)?\s*\%\>'
  let if_clause_regex = '\v\<\%(.*\S.*) (if|unless) (.*)\s*\%\>'

  if line =~ if_clause_regex
    return {
          \ 'type':   'erb_if_clause',
          \ 'regex':  if_clause_regex,
          \ 'body':   line
          \ }
  elseif line =~ option_regex
    return {
          \ 'type':   'erb_options',
          \ 'regex':  option_regex,
          \ 'body':   line
          \ }
  end

  return {}
endfunction

function! b:ErbReplaceSplit(data)
  let type  = a:data.type
  let regex = a:data.regex
  let body  = a:data.body

  if type == 'erb_options'
    return SplitErbOptions(regex, body)
  elseif type == 'erb_if_clause'
    return substitute(body, regex, '<% \2 \3%>\n<%\1 %>\n<% end %>', '')
  end

  return body
endfunction

function! b:SplitjoinDetectJoin()
  return {}
endfunction

let b:splitjoin_split_data = [
      \ ['b:HtmlDetectSplit', 'b:HtmlReplaceSplit'],
      \ ['b:ErbDetectSplit', 'b:ErbReplaceSplit'],
      \ ]

function! b:ErbDetectJoin()
  " check if we're in an if statement
  let line  = getline('.')
  let pline = getline(line('.') - 1)

  let if_clause_regex = '\v^\s*\<\%\s*(if|unless)'

  if line =~ if_clause_regex
    normal! jj

    if getline('.') =~ 'end'
      normal! Vkk"zy
      let body = @z

      return {
            \ 'type':   'erb_if_clause',
            \ 'position': {
            \    'from': line('.') - 2,
            \    'to':   line('.')
            \   },
            \ 'body':   body
            \ }
    endif
  endif

  return {}
endfunction

function! b:ErbReplaceJoin(data)
  let type     = a:data.type
  let position = a:data.position
  let body     = a:data.body

  if type == 'erb_if_clause'
    let [if_line, body, end_line] = split(body, '\n')

    let if_line = splitjoin#ExtractRx(if_line, '<%\s*\(.\{-}\)\s*%>', '\1')
    let body    = splitjoin#ExtractRx(body,    '\(<%=\?\s*.\{-}\)\s*%>', '\1')

    let replacement = body.' '.if_line.' %>'

    return [replacement, position]
  endif
endfunction

let b:splitjoin_join_data = [
      \ ['b:ErbDetectJoin', 'b:ErbReplaceJoin']
      \ ]

" ---------------------
" Replacement functions
" ---------------------

" <%= link_to 'foo', bar_path, :id => 'foo', :class => 'bar' %>
"
" becomes:
"
" <%= link_to 'foo', bar_path, {
"   :id => 'foo',
"   :class => 'bar'
" } %>
function! SplitErbOptions(regex, text)
  let text = substitute(a:text, a:regex, ', {\1}\3 %>', '')

  return SplitRubyHashes('{\(.*\)}', text)
endfunction
