" Tagfiles:
set tags=./tags,tags
set tags+=~/tags/sdl.tags

set makeprg=g++\ %\ -lSDL

" Autotag settings:
"let g:autotagCtagsCmd = "ctags "

command! RebuildTags !ctags -R .
command! RebuildExe !g++ -o %:r %
