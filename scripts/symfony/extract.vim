command! -range -nargs=1 Sfextract call s:Sfextract(<f-args>)
function! s:Sfextract(path)
  normal! gv"zd

  let [module, template] = symfony#ParsePartialPath(a:path)
  exe "normal i<?php echo include_partial('".module."/".template."') ?>\<cr>\<esc>==zz"

  exe "split ".symfony#TemplatePath(module, '_'.template)
  normal! "zP
  normal! zR
  wincmd w
endfunction
