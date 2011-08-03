function! ruby_tools#parser#Construct()
  return {
        \ 'tokens': [],
        \
        \ 'AddToken': function('ruby_tools#parser#AddToken')
        \ }
endfunction

function! ruby_tools#parser#AddToken(token, line) dict
  call add(self.tokens, [a:token, a:line])
endfunction
