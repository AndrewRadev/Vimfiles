if !has('ruby')
  finish
endif

ruby << RUBY
require 'net/http'
require 'json'
require 'cgi'

def google_translate(text, from, to)
  q        = CGI::escape(text)
  lang     = CGI::escape("#{from}|#{to}")
  uri      = "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=#{q}&langpair=#{lang}"
  response = Net::HTTP.get URI.parse(uri)

  data = JSON.parse(response)['responseData']
  return data['translatedText'] if data
end
RUBY

command! -nargs=* -range Translate call Translate(<f-args>)
function! Translate(...)
  if a:0 == 1 " Default to english
    let from = 'en'
    let to   = a:1
  elseif a:0 == 2
    let from = a:1
    let to   = a:2
  else
    echo "You need to enter at least one language."
    return
  endif

  normal gv"zd
  let text = @z

  let result = ''

  ruby << RUBY
  result = google_translate(
  VIM::evaluate('text'),
  VIM::evaluate('from'),
  VIM::evaluate('to')
  )
  VIM::command("let result = '#{result}'")
RUBY

  let @z = result
  normal "zgP
endfunction
