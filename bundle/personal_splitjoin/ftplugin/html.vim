function! b:HtmlDetectSplit()
  let line = getline('.')

  let tag_regex = '\(<.\{-}>\)\(.*\)\(<\/.\{-}>\)'

  if line =~ tag_regex
    return {
          \ 'type':   'html_tag',
          \ 'regex':  tag_regex,
          \ 'body':   line
          \ }
	endif

  return {}
endfunction

function! b:HtmlReplaceSplit(data)
  let type  = a:data.type
  let regex = a:data.regex
  let body  = a:data.body

  if type == 'html_tag'
    return substitute(body, regex, '\1\n\2\n\3', '')
	endif

  return body
endfunction

function! b:SplitjoinDetectJoin()
  return {}
endfunction

" List of pairs [detection function, replacement function]
if !exists('b:splitjoin_data') " don't mess up erb
	let b:splitjoin_data = [
				\ ['b:HtmlDetectSplit', 'b:HtmlReplaceSplit']
				\ ]
endif
