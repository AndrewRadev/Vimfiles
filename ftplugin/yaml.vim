setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

setlocal foldmethod=indent
setlocal nofoldenable

setlocal commentstring=#\ %s

RunCommand %!yaml2json
