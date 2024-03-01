finish

" call ch_logfile('logfile', 'w')

func CommandEntered(text)
  let output = systemlist('systemctl ' .. a:text .. ' httpd')
  if v:shell_error
    let label = 'ERR'
  else
    let label = 'Out'
  endif

  for line in output
    call GotJobOutput(0, $"[Command: {label}] {line}")
  endfor
endfunc

func GotJobOutput(channel, msg)
  call append(line("$") - 1, a:msg)
  set nomodified
endfunc

" Start a shell in the background.
let g:shell_job = job_start(['journalctl', '-f', '-u', 'httpd'], #{
      \ out_cb: function('GotJobOutput'),
      \ err_cb: function('GotJobOutput'),
      \ })

new
set buftype=prompt
setlocal nowrap

let buf = bufnr('')
call prompt_setcallback(buf, function("CommandEntered"))
eval prompt_setprompt(buf, "> ")

autocmd QuitPre <buffer> call job_stop(g:shell_job)

" start accepting shell commands
startinsert
