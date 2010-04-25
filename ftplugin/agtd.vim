" Only do this when not done yet for this buffer
if exists ("b:did_ftplugin_agtd")
   finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin_agtd = 1

setlocal foldexpr=Gtd_foldLevel(v:lnum)
setlocal fdm=expr
setlocal fdi=0
setlocal formatoptions=
setlocal foldminlines=0
setlocal nowrap
setlocal cindent

exe "call Gtd_setMarks()"
