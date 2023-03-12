setlocal noexpandtab
setlocal tabstop=4
setlocal shiftwidth=4

let b:extract_var_template = '%s := %s'
let b:inline_var_pattern   = '\v(\k+)\s+:\=\s+(.*)'

let b:outline_pattern = '^\s*func'

RunCommand !go run %
