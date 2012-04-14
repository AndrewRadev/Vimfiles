" TODO (2012-04-05) Fix problems with #333
onoremap <buffer> w :<c-u>call <SID>OmapWordTextObject()<cr>
xnoremap <buffer> w :<c-u>call <SID>XmapWordTextObject()<cr>
onoremap <buffer> e :<c-u>call <SID>OmapWordTextObject()<cr>
xnoremap <buffer> e :<c-u>call <SID>XmapWordTextObject()<cr>

function! s:OmapWordTextObject()
  let line      = getline('.')
  let next_char = line[col('.')]
  let cword     = expand('<cword>')

  if cword =~ '^\d' && next_char =~ '\d\|\s'
    let next_non_number = matchstr(cword, '^\d\+\zs.\ze')
    exe 'normal! vt'.next_non_number
  else
    normal! ve
  endif
endfunction

function! s:XmapWordTextObject()
  normal! gv

  let line      = getline('.')
  let next_char = line[col('.')]
  let cword     = expand('<cword>')

  if cword =~ '^\d' && next_char =~ '\d\|\s'
    let next_non_number = matchstr(cword, '^\d\+\zs.\ze')
    exe 'normal! t'.next_non_number
  else
    normal! e
  endif
endfunction
