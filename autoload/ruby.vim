function! ruby#call(f, ...)
  let result = ''
  ruby << RUBY
    f    = VIM::evaluate('a:f')
    args = VIM::evaluate('a:000') #.split /\n+/

    result = method(f).call(*args)
    VIM::command "let result = '#{result}'"
RUBY
  return result
endfunction
