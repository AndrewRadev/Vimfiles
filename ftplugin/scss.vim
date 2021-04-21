runtime! ftplugin/css.vim
runtime! ftplugin/css_folding.vim

set comments=s1:/*,mb:*,ex:*/,://

" Go to manual
nnoremap gm :Doc css<cr>

" Don't consider "-" a keyword character
set iskeyword-=-
