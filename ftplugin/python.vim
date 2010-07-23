setlocal tabstop=4
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal expandtab

compiler python

RunCommand     !python3    % <args>
ConsoleCommand !python3 -i % <args>
