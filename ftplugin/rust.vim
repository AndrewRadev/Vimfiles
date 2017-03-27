RunCommand RustRun
compiler cargo

let b:extract_var_template = 'let %s = %s;'
let b:inline_var_pattern   = '\vlet (\k+)\s+\=\s+(.*);'

let b:outline_pattern = '\s*\%(pub\s*\)\=\(impl\|fn\|struct\|macro_rules!\)\(\s\|$\)'

nmap <buffer> gd <Plug>(rust-def)
nmap <buffer> gm <Plug>(rust-doc)
