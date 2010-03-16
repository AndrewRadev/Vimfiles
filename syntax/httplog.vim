" Vim syntax file
" FileType:     Access log of Apache, nginx, etc
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010年3月9日
" ---------------------------------------------------------------------

syntax clear
syntax case match

syn match httplogIP	/\v^[[:xdigit:].:]+/ contains=httplogLocal,httplogLAN
syn match httplogTime	/\v\s\zs\[[^]]+\]\ze\s/
syn match httplogPage	/\v\s\zs"(GET|POST|HEAD) [^"]+"\ze\s/
syn match httplogResult	/\v\s\zs[2-4]\d{2}\ze\s\d+/
syn match httplogError	/\v\s\zs5\d{2}\ze\s\d+/
syn match httplogRef	/\v\s\zs"(http[^"]+|-)"\ze\s/
syn match httplogUA	/\v\s\zs"[^"]+"$/ contains=httplogBrowser
syn keyword httplogogBrowser	Firefox MSIE Konqueror Chrome Safari Opera w3m W3C_Validator Jigsaw Lynx Epiphany Links contained
syn match httplogLAN	/\v(192\.168\.\d+\.\d+)/ contained
syn match httplogLocal	/\v(::1|127\.0\.0\.1|192\.168\.1\.11)\s/ contained

hi link httplogIP	Identifier
hi link httplogTime	Constant
hi link httplogPage	Underlined
hi link httplogResult	Number
hi link httplogError	ErrorMsg
hi link httplogRef	Statement
hi link httplogUA	Type
hi link httplogBrowser	String
hi link httplogLocal	Special
hi link httplogLAN	PreProc

let b:current_syntax = "httplog"
