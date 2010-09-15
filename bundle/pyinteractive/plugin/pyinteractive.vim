" File:     pyinteractive.vim
" Brief:    Python read-eval-print loop inside Vim
" Autor:    clericJ (py.cleric at gmail.com)
" Version:  0.5.3

if v:version < 700
    echoerr 'PyInteractive does not work this version of Vim (' . v:version . ').'
    finish
elseif !has('python')
    echoerr "PyInteractive require vim compiled with +python"
    finish
elseif exists("g:loaded_PyInteractive")
  finish
endif

let g:loaded_PyInteractive = 1

let s:plugin_directory=fnamemodify(expand('<sfile>'), ':p:h:h')

python << EOF
import sys, os, vim

sys.path.append(os.path.join(vim.eval('s:plugin_directory'), os.path.normpath('plugin/python')))

import pyinteractive as _pyinteractive
EOF
command PyInteractiveREPL py _pyinteractive.run()
command -complete=customlist,pyinteractive#PythonAutoComplete -nargs=1 PyInteractiveEval exec 'py _pyinteractive.evaluate("""' . escape(<q-args>, "\"'\\"). '""")'
command -complete=file -nargs=* PyInteractiveHistory exec 'py _pyinteractive.show_history("' . escape(<q-args>, "\"'\\"). '")'


function! pyinteractive#PythonAutoComplete(begin, cmdline, cursorpos)
    exec 'py result = []'
    exec "py result = _pyinteractive.python_autocomplete('".a:begin."','".a:cmdline."'," a:cursorpos ")"
    "exec 'py vim.command("let candidates = split(\"%s\")" % "\n".join(result))'
    py vim.command('let candidates = %r' % result)
    "exec 'py vim.command("call confirm(\"%s\")" % str(result))'
    "call candidates(result)
    return candidates
endfunction

function! pyinteractive#PythonAutoCompleteInput(...)
    let candidates=call('pyinteractive#PythonAutoComplete', a:000)
    let [arglead, cmdline, position]=a:000
    let curwordstart=matchstr(cmdline[:(position-1)], '\%(\\.\|[^ ]\)*$')
    let start=position-len(curwordstart)
    if start
        let prefix=cmdline[:(start-1)]
    else
        let prefix=""
    endif
    return map(candidates, 'prefix . v:val')
endfunction


function! pyinteractive#EvaluateSelected(type)
    let reg_save = @@

    silent execute "normal! `<" . a:type . "`>y"
    execute "PyInteractiveEval " @

    let @@ = reg_save
endfunction


