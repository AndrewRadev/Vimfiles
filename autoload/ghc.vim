let s:scriptname = "ghc.vim"

function! ghc#StaticOptions()
  let b:ghc_staticoptions = input('GHC static options: ',b:ghc_staticoptions)
  execute 'setlocal makeprg=' . g:ghc . '\ ' . escape(b:ghc_staticoptions,' ') .'\ -e\ :q\ %'
  let b:my_changedtick -=1
endfunction

function! ghc#ShowType(addTypeDecl)
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [_,symb,qual,unqual] = namsym
  let name  = qual=='' ? unqual : qual.'.'.unqual
  let pname = ( symb ? '('.name.')' : name ) 
  call ghc#HaveTypes()
  if !has_key(b:ghc_types,name)
    redraw
    echo pname "type not known"
  else
    redraw
    for type in split(b:ghc_types[name],' -- ')
      echo pname "::" type
      if a:addTypeDecl
        call append( line(".")-1, pname . " :: " . type )
      endif
    endfor
  endif
endfunction

function! ghc#TypeBalloon()
  if exists("b:current_compiler") && b:current_compiler=="ghc" 
    let [line] = getbufline(v:beval_bufnr,v:beval_lnum)
    let namsym = haskellmode#GetNameSymbol(line,v:beval_col,0)
    if namsym==[]
      return ''
    endif
    let [start,symb,qual,unqual] = namsym
    let name  = qual=='' ? unqual : qual.'.'.unqual
    let pname = name " ( symb ? '('.name.')' : name )
    silent call ghc#HaveTypes()
    if has("balloon_multiline")
      return (has_key(b:ghc_types,pname) ? split(b:ghc_types[pname],' -- ') : '') 
    else
      return (has_key(b:ghc_types,pname) ? b:ghc_types[pname] : '') 
    endif
  else
    return ''
  endif
endfunction

function! ghc#ShowInfo()
  let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),0)
  if namsym==[]
    redraw
    echo 'no name/symbol under cursor!'
    return 0
  endif
  let [_,symb,qual,unqual] = namsym
  let name = qual=='' ? unqual : (qual.'.'.unqual)
  let output = ghc#Info(name)
  pclose | new 
  setlocal previewwindow
  setlocal buftype=nofile
  setlocal noswapfile
  put =output
  wincmd w
  "redraw
  "echo output
endfunction

" fill the type map, unless nothing has changed since the last attempt
function! ghc#HaveTypes()
  if b:ghc_types == {} && (b:my_changedtick != b:changedtick)
    let b:my_changedtick = b:changedtick
    return ghc#BrowseAll()
  endif
endfunction

function! ghc#BrowseAll()
  " let imports = haskellmode#GatherImports()
  " let modules = keys(imports[0]) + keys(imports[1])
  let imports = {} " no need for them at the moment
  let current = ghc#NameCurrent()
  let module = current==[] ? 'Main' : current[0]
  if ghc#VersionGE([6,8,1])
    return ghc#BrowseBangStar(module)
  else
    return ghc#BrowseMultiple(imports,['*'.module])
  endif
endfunction

function! ghc#VersionGE(target)
  let current = split(g:ghc_version, '\.' )
  let target  = a:target
  for i in current
    if ((target==[]) || (i>target[0]))
      return 1
    elseif (i==target[0])
      let target = target[1:]
    else
      return 0
    endif
  endfor
  return 1
endfunction

function! ghc#NameCurrent()
  let last = line("$")
  let l = 1
  while l<last
    let ml = matchlist( getline(l), '^module\s*\([^ (]*\)')
    if ml != []
      let [_,module;x] = ml
      return [module]
    endif
    let l += 1
  endwhile
  redraw
  echo "cannot find module header for file " . expand("%")
  return []
endfunction

function! ghc#BrowseBangStar(module)
  redraw
  echo "browsing module " a:module
  let command = ":browse! *" . a:module
  let orig_shellredir = &shellredir
  let &shellredir = ">" " ignore error/warning messages, only output or lack of it
  let output = system(g:ghc . ' ' . b:ghc_staticoptions . ' -v0 --interactive ' . expand("%") , command )
  let &shellredir = orig_shellredir
  return ghc#ProcessBang(a:module,output)
endfunction

function! ghc#BrowseMultiple(imports,modules)
  redraw
  echo "browsing modules " a:modules
  let command = ":browse " . join( a:modules, " \n :browse ") 
  let command = substitute(command,'\(:browse \(\S*\)\)','putStrLn "-- \2" \n \1','g')
  let output = system(g:ghc . ' ' . b:ghc_staticoptions . ' -v0 --interactive ' . expand("%") , command )
  return ghc#Process(a:imports,output)
endfunction

function! ghc#Info(what)
  " call ghc#HaveTypes()
  let output = system(g:ghc . ' ' . b:ghc_staticoptions . ' -v0 --interactive ' . expand("%"), ":i ". a:what)
  return output
endfunction

function! ghc#ProcessBang(module,output)
  let module      = a:module
  let b           = a:output
  let linePat     = '^\(.\{-}\)\n\(.*\)'
  let contPat     = '\s\+\(.\{-}\)\n\(.*\)'
  let typePat     = '^\(\)\(\S*\)\s*::\(.*\)'
  let commentPat  = '^-- \(\S*\)'
  let definedPat  = '^-- defined locally'
  let importedPat = '^-- imported via \(.*\)'
  if !(b=~commentPat)
    echo s:scriptname.": GHCi reports errors (try :make?)"
    return 0
  endif
  let b:ghc_types = {}
  let ml = matchlist( b , linePat )
  while ml != []
    let [_,l,rest;x] = ml
    let mlDecl = matchlist( l, typePat )
    if mlDecl != []
      let [_,indent,id,type;x] = mlDecl
      let ml2 = matchlist( rest , '^'.indent.contPat )
      while ml2 != []
        let [_,c,rest;x] = ml2
        let type .= c
        let ml2 = matchlist( rest , '^'.indent.contPat )
      endwhile
      let id   = substitute( id, '^(\(.*\))$', '\1', '')
      let type = substitute( type, '\s\+', " ", "g" )
      " using :browse! *<current>, we get both unqualified and qualified ids
      let qualified = (id =~ '\.') && (id =~ '[A-Z]')
      let b:ghc_types[id] = type
      if !qualified
        for qual in qualifiers
          let b:ghc_types[qual.'.'.id] = type
        endfor
      endif
    else
      let mlImported = matchlist( l, importedPat )
      let mlDefined  = matchlist( l, definedPat )
      if mlImported != []
        let [_,modules;x] = mlImported
        let qualifiers = split( modules, ', ' )
      elseif mlDefined != []
        let qualifiers = [module]
      endif
    endif
    let ml = matchlist( rest , linePat )
  endwhile
  return 1
endfunction

function! ghc#Process(imports,output)
  let b       = a:output
  let imports = a:imports
  let linePat = '^\(.\{-}\)\n\(.*\)'
  let contPat = '\s\+\(.\{-}\)\n\(.*\)'
  let typePat = '^\(\s*\)\(\S*\)\s*::\(.*\)'
  let modPat  = '^-- \(\S*\)'
  " add '-- defined locally' and '-- imported via ..'
  if !(b=~modPat)
    echo s:scriptname.": GHCi reports errors (try :make?)"
    return 0
  endif
  let b:ghc_types = {}
  let ml = matchlist( b , linePat )
  while ml != []
    let [_,l,rest;x] = ml
    let mlDecl = matchlist( l, typePat )
    if mlDecl != []
      let [_,indent,id,type;x] = mlDecl
      let ml2 = matchlist( rest , '^'.indent.contPat )
      while ml2 != []
        let [_,c,rest;x] = ml2
        let type .= c
        let ml2 = matchlist( rest , '^'.indent.contPat )
      endwhile
      let id   = substitute(id, '^(\(.*\))$', '\1', '')
      let type = substitute( type, '\s\+', " ", "g" )
      " using :browse *<current>, we get both unqualified and qualified ids
      if current_module " || has_key(imports[0],module) 
        if has_key(b:ghc_types,id) && !(matchstr(b:ghc_types[id],escape(type,'[].'))==type)
          let b:ghc_types[id] .= ' -- '.type
        else
          let b:ghc_types[id] = type
        endif
      endif
      if 0 " has_key(imports[1],module) 
        let qualid = module.'.'.id
        let b:ghc_types[qualid] = type
      endif
    else
      let mlMod = matchlist( l, modPat )
      if mlMod != []
        let [_,module;x] = mlMod
        let current_module = module[0]=='*'
        let module = current_module ? module[1:] : module
      endif
    endif
    let ml = matchlist( rest , linePat )
  endwhile
  return 1
endfunction
" count only error entries in quickfix list, ignoring warnings
function! ghc#CountErrors()
  let c=0
  for e in getqflist() | if e.type=='E' && e.text !~ "^[ \n]*Warning:" | let c+=1 | endif | endfor
  return c
endfunction

" use ghci :browse index for insert mode omnicompletion (CTRL-X CTRL-O)
function! ghc#CompleteImports(findstart, base)
  if a:findstart 
    let namsym   = haskellmode#GetNameSymbol(getline('.'),col('.'),-1) " insert-mode: we're 1 beyond the text
    if namsym==[]
      redraw
      echo 'no name/symbol under cursor!'
      return -1
    endif
    let [start,symb,qual,unqual] = namsym
    return (start-1)
  else " find keys matching with "a:base"
    let res = []
    let l   = len(a:base)-1
    call ghc#HaveTypes()
    for key in keys(b:ghc_types) 
      if key[0 : l]==a:base
        let res += [{"word":key,"menu":":: ".b:ghc_types[key],"dup":1}]
      endif
    endfor
    return res
  endif
endfunction

function! ghc#MkImportsExplicit()
  let save_cursor = getpos(".")
  let line   = getline('.')
  let lineno = line('.')
  let ml     = matchlist(line,'^import\(\s*qualified\)\?\s*\([^( ]\+\)')
  if ml!=[]
    let [_,q,mod;x] = ml
    silent make
    if getqflist()==[]
      if line=~"import[^(]*Prelude"
        call setline(lineno,substitute(line,"(.*","","").'()')
      else
        call setline(lineno,'-- '.line)
      endif
      silent write
      silent make
      let qflist = getqflist()
      call setline(lineno,line)
      silent write
      let ids = {}
      for d in qflist
        let ml = matchlist(d.text,'Not in scope: \([^`]*\)`\([^'']*\)''')
        if ml!=[]
          let [_,what,qid;x] = ml
          let id  = ( qid =~ "^[A-Z]" ? substitute(qid,'.*\.\([^.]*\)$','\1','') : qid )
          let pid = ( id =~ "[a-zA-Z0-9_']\\+" ? id : '('.id.')' )
          if what =~ "data"
            call ghc#HaveTypes()
            if has_key(b:ghc_types,id)
              let pid = substitute(b:ghc_types[id],'^.*->\s*\(\S*\).*$','\1','').'('.pid.')'
            else
              let pid = '???('.pid.')'
            endif
          endif
          let ids[pid] = 1
        endif
      endfor
      call setline(lineno,'import'.q.' '.mod.'('.join(keys(ids),',').')')
    else
      copen
    endif
  endif
  call setpos('.', save_cursor)
endfunction
function! ghc#CreateTagfile()
  redraw
  echo "creating tags file" 
  let output = system(g:ghc . ' ' . b:ghc_staticoptions . ' -e ":ctags" ' . expand("%"))
  " for ghcs older than 6.6, you would need to call another program 
  " here, such as hasktags
  echo output
endfunction
