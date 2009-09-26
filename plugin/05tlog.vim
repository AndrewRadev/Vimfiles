" tLog.vim
" @Author:      Tom Link (micathom AT gmail com?subject=vim-tLog)
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2006-12-15.
" @Last Change: 2009-03-07.
" @Revision:    0.3.159

if &cp || exists('loaded_tlog')
    finish
endif
let loaded_tlog = 100


" One of: echo, echom, file, Decho
" Format: type:args
" E.g. file:/tmp/foo.log
if !exists('g:tlogDefault')   | let g:tlogDefault = 'echom'   | endif
if !exists('g:TLOG')          | let g:TLOG = g:tlogDefault    | endif
if !exists('g:tlogBacktrace') | let g:tlogBacktrace = 2       | endif


" :display: :TLog MESSAGE
command! -nargs=+ TLog call tlog#Log(<args>)

" :display: :TLogTODO MESSAGE
" Mark as "Not yet implemented".
command! -nargs=* -bar TLogTODO call tlog#Debug(expand('<sfile>').': Not yet implemented '. <q-args>)

" :display: :TLogDBG EXPRESSION
" Expression must evaluate to a string.
command! -nargs=1 TLogDBG call tlog#Debug(expand('<sfile>').': '. <args>)

" :display: :TLogStyle STYLE EXPRESSION
" Expression must evaluate to a string.
command! -nargs=+ TLogStyle call tlog#Style(<args>)

" :display: :TLogVAR VAR1, VAR2 ...
" Display variable names and their values.
" This command doesn't work with script-local variables.
command! -nargs=+ TLogVAR call tlog#Var(expand('<sfile>'), <q-args>, <args>)
" command! -nargs=+ TLogVAR if !TLogVAR(expand('<sfile>').': ', <q-args>, <f-args>) | call tlog#Debug(expand('<sfile>').': Var doesn''t exist: '. <q-args>) | endif

" Enable logging.
command! -bar -nargs=? TLogOn let g:TLOG = empty(<q-args>) ? g:tlogDefault : <q-args>

" Disable logging.
command! -bar -nargs=? TLogOff let g:TLOG = ''

" Enable logging for the current buffer.
command! -bar -nargs=? TLogBufferOn let b:TLOG = empty(<q-args>) ? g:tlogDefault : <q-args>

" Disable logging for the current buffer.
command! -bar -nargs=? TLogBufferOff let b:TLOG = ''

" Comment out all tlog-related lines in the current buffer which should 
" contain a vim script.
command! -range=% -bar TLogComment call tlog#Comment(<line1>, <line2>)

" Re-enable all tlog-related statements.
command! -range=% -bar TLogUncomment call tlog#Uncomment(<line1>, <line2>)


finish

CHANGE LOG {{{1
see 07tAssert.vim

