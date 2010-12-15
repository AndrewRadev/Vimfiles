function! b:RubyDetectSplit()
  let line = getline('.')

  let hash_regex      = '{\(.*\)}'
  let option_regex    = '\v,(([^,]+\s*\=\>\s*[^,]{-1,},?)+)(\s*do.*)?$'
  let if_clause_regex = '\v(.*) (if|unless) (.*)'

  if line =~ if_clause_regex
    return {
          \ 'type':   'ruby_if_clause',
          \ 'regex':  if_clause_regex,
          \ 'body':   line
          \ }
  elseif line =~ hash_regex
    return {
          \ 'type':   'ruby_hash',
          \ 'regex':  hash_regex,
          \ 'body':   line
          \ }
  elseif line =~ option_regex
    return {
          \ 'type':   'ruby_options',
          \ 'regex':  option_regex,
          \ 'body':   line
          \ }
  end

  return {}
endfunction

function! b:RubyReplaceSplit(data)
  let type  = a:data.type
  let regex = a:data.regex
  let body  = a:data.body

  if type == 'ruby_hash'
    return SplitRubyHashes(regex, body)
  elseif type == 'ruby_options'
    return SplitRubyOptions(regex, body)
  elseif type == 'ruby_if_clause'
    return substitute(body, regex, '\2 \3\n\1\nend', '')
  end

  return body
endfunction

function! b:SplitjoinDetectJoin()
  return {}
endfunction

if !exists('b:splitjoin_data') " don't mess up erb
  let b:splitjoin_data = [
        \ ['b:RubyDetectSplit', 'b:RubyReplaceSplit']
        \ ]
endif

" ---------------------
" Replacement functions
" ---------------------

" { :one => 'two', :three => 'four' }
"
" becomes:
"
" {
"   :one => 'two',
"   :three => 'four,
" }
function! SplitRubyHashes(regex, text)
  let body     = lib#ExtractRx(a:text, a:regex, '\1')
  let new_body = join(split(body, ','), ",\n")

  return substitute(a:text, a:regex, "{\n".new_body."\n}", '')
endfunction

" link_to 'foo', bar_path, :id => 'foo', :class => 'bar'
"
" becomes:
"
" link_to 'foo', bar_path, {
"   :id => 'foo',
"   :class => 'bar'
" }
function! SplitRubyOptions(regex, text)
  let text = substitute(a:text, a:regex, ', {\1}\3', '')

  return SplitRubyHashes('{\(.*\)}', text)
endfunction
