set noexpandtab
set tabstop=4
set shiftwidth=4
set makeprg=go\ run\ %

nmap <buffer> gm <Plug>(godoc-keyword)

let b:outline_pattern = '^\s*func'

RunCommand !go run %
