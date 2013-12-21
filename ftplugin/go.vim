set noexpandtab
set tabstop=4
set shiftwidth=4

let &l:makeprg = 'go build -o '.tempname().' '.shellescape(expand('%'))

nmap <buffer> gm <Plug>(godoc-keyword)

let b:extract_var_template = '%s := %s'
let b:inline_var_pattern   = '\v(\k+)\s+:\=\s+(.*)'

let b:outline_pattern = '^\s*func'

RunCommand !go run %
