let g:lsp_auto_enable = 0
let g:lsp_use_native_client = 1
" let g:lsp_debug_servers = 1
let g:lsp_log_file = expand('~/.vim-lsp.log')
let g:lsp_document_highlight_enabled = 0
let g:lsp_document_highlight_delay = 50

augroup LspSetup
  autocmd!
  autocmd User lsp_setup call s:LspSetup()
augroup END

function! s:LspSetup() abort
  if executable('rust-analyzer')
    call lsp#register_server({
          \   'name': 'rust-analyzer',
          \   'cmd': { _server_info -> ['rust-analyzer'] },
          \   'allowlist': ['rust'],
          \ })
  endif
endfunction
