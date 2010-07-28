if !has('ruby')
  finish
endif

ruby << RUBY
require 'net/http'
require 'cgi'

begin
  require 'json'
rescue LoadError
  require 'rubygems'
  require 'json'
end

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

	" Place last selected text in 'z' register
  normal! gv"zd

	" Replace 'z' register
  let @z = ruby#call('google_translate', @z, from, to)

	" Replace selected text with 'z' register
  normal! "zgp
endfunction
