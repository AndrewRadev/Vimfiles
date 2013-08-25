setlocal softtabstop=4
setlocal shiftwidth=4
setlocal expandtab

compiler python

setlocal foldmethod=indent

nmap <buffer> dh <Plug>CoffeeToolsDeleteAndDedent

RunCommand     !python3    % <args>
ConsoleCommand !python3 -i % <args>

let b:outline_pattern = '\v^\s*(def|class)(\s|$)'
