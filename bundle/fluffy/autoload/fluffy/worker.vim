function! fluffy#worker#New(params) abort
  let worker = #{
        \   paths: [],
        \   last_update: reltime(),
        \
        \   Callback: a:params['callback'],
        \
        \   AddPath:  function('s:AddPath'),
        \   Finish:   function('s:Finish'),
        \   Stop:     function('s:Stop'),
        \ }

  let job = job_start('slow_rg', #{
        \   out_cb: { _job, line -> worker.AddPath(line) },
        \   exit_cb: { -> worker.Finish() },
        \ })

  let worker.job = job

  return worker
endfunction

function! s:AddPath(line) dict abort
  call add(self.paths, a:line)

  if reltimefloat(reltime(self.last_update)) > 0.1
    call self.Callback(#{ new_paths: self.paths })
    let self.paths = []
    let self.last_update = reltime()
  endif
endfunction

function! s:Finish() dict abort
  call self.Callback(#{ new_paths: self.paths, finished: 1 })
endfunction

function s:Stop() dict abort
  call job_stop(self.job)
endfunction
