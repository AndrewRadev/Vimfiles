function! b:ErbDetectSplit()
  let line = getline('.')

  let option_regex = '\v((,[^,]+\s+\=\>\s+[^,]+)+)\%\>'

  if line =~ option_regex
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
