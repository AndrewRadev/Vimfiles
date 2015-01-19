RunCommand RustRun
compiler rustc

let b:extract_var_template = 'let %s = %s'
let b:inline_var_pattern   = '\vlet (\k+)\s+\=\s+(.*)'

let b:outline_pattern = '\s*\%(pub\s*\)\=\(impl\|fn\)\(\s\|$\)'
