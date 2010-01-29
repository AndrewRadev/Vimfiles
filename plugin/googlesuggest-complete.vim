"=============================================================================
" File: googlesuggest-complete.vim
" Author: Yasuhiro Matsumoto <mattn.jp@gmail.com>
" Last Change: 29-Jan-2010.
" Version: 0.2
" WebPage: http://github.com/mattn/googlesuggest-complete-vim
" Usage:
"
"   Lesson1:
"
"     takasu<c-x><c-u>
"           +----------------+
"     takasu|高杉晋作========|
"           |高須クリニック  |
"           |高須            |
"           |高鈴            |
"           |高鷲スノーパーク|
"           |高杉さと美      |
"           |高杉良          |
"           |高須光聖        |
"           |高須克弥        |
"           |高須 ブログ     |
"           +----------------+
"     * perhaps, you can see the candidates above.
"
"   Lesson2:
"
"     watasinonamaeha<c-x><c-u>
"
"     => 私の名前はキムサムスン
"     * who is kim samsoon?
"
"   Etc:
"
"     naitu<c-x><c-u>
"     => ナイツ お笑い
"
"     www<c-x><c-u>
"     => www.yahoo.co.jp
"
"     gm<c-x><c-u>
"     => gmailへようこそ
"
"     vimp<c-x><c-u>
"     => vimperator
"
"     puri<c-x><c-u>
"     => プリキュア
"

if !exists('g:googlesuggest_language')
  let g:googlesuggest_language = 'ja'
endif

function! s:nr2byte(nr)
  if a:nr < 0x80
    return nr2char(a:nr)
  elseif a:nr < 0x800
    return nr2char(a:nr/64+192).nr2char(a:nr%64+128)
  else
    return nr2char(a:nr/4096%16+224).nr2char(a:nr/64%64+128).nr2char(a:nr%64+128)
  endif
endfunction

function! s:nr2enc_char(charcode)
  if &encoding == 'utf-8'
    return nr2char(a:charcode)
  endif
  let char = s:nr2byte(a:charcode)
  if strlen(char) > 1
    let char = strtrans(iconv(char, 'utf-8', &encoding))
  endif
  return char
endfunction

function! s:nr2hex(nr)
  let n = a:nr
  let r = ""
  while n
    let r = '0123456789ABCDEF'[n % 16] . r
    let n = n / 16
  endwhile
  return r
endfunction

function! s:encodeURIComponent(instr)
  let instr = iconv(a:instr, &enc, "utf-8")
  let len = strlen(instr)
  let i = 0
  let outstr = ''
  while i < len
    let ch = instr[i]
    if ch =~# '[0-9A-Za-z-._~!''()*]'
      let outstr = outstr . ch
    elseif ch == ' '
      let outstr = outstr . '+'
    else
      let outstr = outstr . '%' . substitute('0' . s:nr2hex(char2nr(ch)), '^.*\(..\)$', '\1', '')
    endif
    let i = i + 1
  endwhile
  return outstr
endfunction

function! s:item2query(items, sep)
  let ret = ''
  if type(a:items) == 4
    for key in keys(a:items)
      if strlen(ret) | let ret .= a:sep | endif
      let ret .= key . "=" . s:encodeURIComponent(a:items[key])
    endfor
  elseif type(a:items) == 3
    for item in a:items
      if strlen(ret) | let ret .= a:sep | endif
      let ret .= item
    endfor
  else
    let ret = a:items
  endif
  return ret
endfunction

function! s:do_http(url, getdata, postdata, cookie, returnheader)
  let url = a:url
  let getdata = s:item2query(a:getdata, '&')
  let postdata = s:item2query(a:postdata, '&')
  let cookie = s:item2query(a:cookie, '; ')
  if strlen(getdata)
    let url .= "?" . getdata
  endif
  let command = "curl -s -k"
  if a:returnheader
    let command .= " -i"
  endif
  if strlen(cookie)
    let command .= " -H \"Cookie: " . cookie . "\""
  endif
  let command .= " \"" . url . "\""
  if strlen(postdata)
    let file = tempname()
    exec 'redir! > '.file
    silent echo postdata
    redir END
    let quote = &shellxquote == '"' ?  "'" : '"'
    let res = system(command . " -d @" . quote.file.quote)
    call delete(file)
  else
    let res = system(command)
  endif
  return res
endfunction

function! GoogleSuggest(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    " find months matching with "a:base"
    let res = []
    let g:hoge =  a:base
    let str = s:do_http('http://google.com/complete/search', {"output" : "json", "q" : a:base, "hl" : g:googlesuggest_language, "ie" : "UTF8", "oe" : "UTF8" }, {}, {}, 0)
    let str = iconv(str, "utf-8", &encoding)
    let str = substitute(str, '\\u\(\x\x\x\x\)', '\=s:nr2enc_char("0x".submatch(1))', 'g')
    let str = substitute(str, '^window\.google\.ac\.h', '', '')
    let l:true = 1
    let l:false = 0
    let lst = eval(str)
    for m in lst[1]
      call add(res, m[0])
    endfor
    return res
  endif
endfunction

set completefunc=GoogleSuggest
