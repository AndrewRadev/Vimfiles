function! b:RubyDetectSplit()
  let line = getline('.')

  let hash_regex      = '\v\{\s*(([^,]+\s*\=\>\s*[^,]{-1,},?)+)\s*\}'
  let block_regex     = '\v\{(\s*\|.*\|)?\s*(.*)\}'
  let option_regex    = '\v,(([^,]+\s*\=\>\s*[^,]{-1,},?)+)(\s*do.*)?$'
  let if_clause_regex = '\v(.*\S.*) (if|unless) (.*)'

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
  elseif line =~ block_regex
    return {
          \ 'type':   'ruby_block',
          \ 'regex':  block_regex,
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
    return SplitRubyHash(regex, body)
  elseif type == 'ruby_options'
    return SplitRubyOptions(regex, body)
  elseif type == 'ruby_block'
    return SplitRubyBlock(regex, body)
  elseif type == 'ruby_if_clause'
    return substitute(body, regex, '\2 \3\n\1\nend', '')
  end

  return body
endfunction

function! b:SplitjoinDetectJoin()
  return {}
endfunction

if !exists('b:splitjoin_split_data') " don't mess up erb
  let b:splitjoin_split_data = [
        \ ['b:RubyDetectSplit', 'b:RubyReplaceSplit']
        \ ]
endif

function! b:RubyDetectJoin()
  " check if we're in an if statement
  let line  = getline('.')
  let pline = getline(line('.') - 1)

  let if_clause_regex = '\v^\s*(if|unless)'

  if line =~ if_clause_regex
    normal! jj

    if getline('.') =~ 'end'
      normal! Vkk"zy
      let body = @z

      return {
            \ 'type':   'ruby_if_clause',
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

function! b:RubyReplaceJoin(data)
  let type     = a:data.type
  let position = a:data.position
  let body     = a:data.body

  if type == 'ruby_if_clause'
    let [if_line, body, end_line] = split(body, '\n')

    let if_line = splitjoin#Trim(if_line)
    let body =    splitjoin#Trim(body)

    let replacement = body.' '.if_line

    return [replacement, position]
  endif
endfunction

if !exists('b:splitjoin_join_data') " don't mess up erb
  let b:splitjoin_join_data = [
        \ ['b:RubyDetectJoin', 'b:RubyReplaceJoin']
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
function! SplitRubyHash(regex, text)
  let body     = splitjoin#ExtractRx(a:text, a:regex, '\1')
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

  return SplitRubyHash('{\(.*\)}', text)
endfunction

" Bar.new { |b| puts b.to_s; puts 'foo' }
"
" becomes:
"
" Bar.new do |b|
"   puts b.to_s
"   puts 'foo'
" end
function! SplitRubyBlock(regex, text)
  let body   = splitjoin#ExtractRx(a:text, a:regex, '\2')
  let body   = join(split(body, '\s*;\s*'), "\n")
  let result = substitute(a:text, a:regex, 'do\1\n'.body.'\nend', '')

  return result
endfunction
