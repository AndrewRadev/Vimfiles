function! b:ErbDetectSplit()
  let line = getline('.')

  let option_regex    = '\v((,[^,]+\s+\=\>\s+[^,]+)+)\%\>'
  let if_clause_regex = '\v\<\%(.*) (if|unless) (.*)\s*\%\>'

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
    return substitute(body, regex, '<% \2 \3 %>\n<%\1 %>\n<% end %>', '')
  end

  return body
endfunction

function! b:SplitjoinDetectJoin()
  return {}
endfunction

let b:splitjoin_data = [
      \ ['b:HtmlDetectSplit', 'b:HtmlReplaceSplit'],
      \ ['b:ErbDetectSplit', 'b:ErbReplaceSplit'],
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
  let text = substitute(a:text, a:regex, ', {\1} %>', '')

  return SplitRubyHashes('{\(.*\)}', text)
endfunction
