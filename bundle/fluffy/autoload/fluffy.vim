function! fluffy#Run(mods)
  if !executable('rg')
    echoerr "Fluffy requires ripgrep (the `rg` executable)"
    return
  endif

  exe a:mods .. ' new'
  set buftype=prompt

  let b:buffer = fluffy#buffer#New()
  let b:worker = fluffy#worker#New(#{ callback: { params -> b:buffer.Update(params) }})

  setlocal statusline=%{b:buffer.Statusline()}

  call prompt_setcallback(bufnr(), function('s:TextEntered'))
  call prompt_setprompt(bufnr(), "> ")
  call prop_type_add('score_text', { 'bufnr': bufnr(), 'highlight': 'fluffyScore' })

  startinsert

  autocmd TextChangedI <buffer> call b:buffer.Update({})
  autocmd QuitPre <buffer> call b:worker.Stop()

  inoremap <buffer> <c-c> <esc>:quit!<cr>
  inoremap <buffer> <c-d> <esc>:quit!<cr>
endfunction

function! s:TextEntered(_text)
  if line('$') <= 2
    quit
  elseif filereadable(getline(1))
    exe 'edit ' .. getline(1)
  else
    quit
  endif
endfunction
