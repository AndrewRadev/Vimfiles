command! -nargs=* -range Translate call Translate(<f-args>)
function! Translate(...)
  if a:0 == 1 " Default to english
    let from = 'en'
    let to   = a:1
  elseif a:0 == 2
    let from = a:1
    let to   = a:2
  else
    echo "You need to enter at least one language"
    return
  endif

  normal gv"zd
  let text = @z

  let result = ''

  ruby << RUBY
    require 'net/http'
    require 'json'
    require 'cgi'

    q        = CGI::escape(VIM::evaluate('text'))
    lang     = CGI::escape("#{VIM::evaluate('from')}|#{VIM::evaluate('to')}")
    uri      = "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=#{q}&langpair=#{lang}"
    response = Net::HTTP.get URI.parse(uri)

    data = JSON.parse(response)['responseData']
    result = data['translatedText'] if data

    VIM::command("let result = '#{result}'")
RUBY

  let @z = lib#UrlDecode(result)
  normal "zgP
endfunction

command! -range Delete call Delete()
function! Delete()
  normal gvd
endfunction
