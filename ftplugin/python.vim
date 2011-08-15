setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal expandtab

compiler python

setlocal foldmethod=indent

RunCommand     !python3    % <args>
ConsoleCommand !python3 -i % <args>

command! -buffer Outline call lib#Outline('\v^\s*(def|class)(\s|$)')
