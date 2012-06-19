runtime! ftplugin/css_folding.vim

call SetupPreview('css', 'lessc %s')
RunCommand Preview

nnoremap <buffer> gf :call <SID>GotoFile()<cr>
if !exists('*s:GotoFile')
  function s:GotoFile()
    normal! gf

    if exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) > 0
      NERDTreeFind
      wincmd w
    endif
  endfunction
endif
