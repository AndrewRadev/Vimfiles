" Tagfiles:
set tags=./tags,tags
set tags+=~/tags/sdl.tags

"set makeprg=g++\ %\ -lSDL

command! RebuildTags !ctags -R .
