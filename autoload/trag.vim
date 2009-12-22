" trag.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-29.
" @Last Change: 2009-12-21.
" @Revision:    0.0.743

if &cp || exists("loaded_trag_autoload")
    finish
endif
let loaded_trag_autoload = 1

    
let s:grep_rx = ''


function! s:GetFiles() "{{{3
    if !exists('b:trag_files_')
        call trag#SetFiles()
    endif
    if empty(b:trag_files_)
        " echohl Error
        " echoerr 'TRag: No project files'
        " echohl NONE
        let trag_get_files = tlib#var#Get('trag_get_files_'. &filetype, 'bg', '')
        " TLogVAR trag_get_files
        if empty(trag_get_files)
            let trag_get_files = tlib#var#Get('trag_get_files', 'bg', '')
            " TLogVAR trag_get_files
        endif
        echom 'TRag: No project files ... use: '. trag_get_files
        let b:trag_files_ = eval(trag_get_files)
    endif
    " TLogVAR b:trag_files_
    return b:trag_files_
endf


function! trag#ClearFiles() "{{{3
    let b:trag_files_ = []
endf


function! trag#AddFiles(files) "{{{3
    if tlib#type#IsString(a:files)
        let files_ = eval(a:files)
    else
        let files_ = a:files
    endif
    if !tlib#type#IsList(files_)
        echoerr 'trag_files must result in a list: '. string(a:files)
    elseif exists('b:trag_files_')
        let b:trag_files_ += files_
    else
        let b:trag_files_ = files_
    endif
    unlet files_
endf


function! trag#GetProjectFiles(manifest) "{{{3
    if filereadable(a:manifest)
        " TLogVAR a:manifest
        let files = readfile(a:manifest)
        let cwd   = getcwd()
        try
            call tlib#dir#CD(fnamemodify(a:manifest, ':h'), 1)
            call map(files, 'fnamemodify(v:val, ":p")')
            return files
        finally
            call tlib#dir#CD(cwd, 1)
        endtry
    endif
    return []
endf


function! trag#GetGitFiles(repos) "{{{3
    let repos   = tlib#dir#PlainName(a:repos)
    let basedir = substitute(repos, '[\/]\.git\([\/]\)\?$', '', '')
    " TLogVAR repos, basedir
    " TLogVAR getcwd()
    call tlib#dir#Push(basedir)
    " TLogVAR getcwd()
    try
        let files = split(system('git ls-files'), '\n')
        " TLogVAR files
        call map(files, 'basedir . g:tlib_filename_sep . v:val')
        return files
    finally
        call tlib#dir#Pop()
    endtry
    return []
endf


" Set the files list from the files included in a given git repository.
function! trag#SetGitFiles(repos) "{{{3
    let files = trag#GetGitFiles(a:repos)
    if !empty(files)
        call trag#ClearFiles()
        let b:trag_files_ = files
        echom len(files) ." files from the git repository."
    endif
endf


" :def: function! trag#SetFiles(?files=[])
function! trag#SetFiles(...) "{{{3
    TVarArg ['files', []]
    call trag#ClearFiles()
    if empty(files)
        unlet! files
        let files = tlib#var#Get('trag_files', 'bg', [])
        " TLogVAR files, empty(files)
        if empty(files)
            let glob = tlib#var#Get('trag_glob', 'bg', '')
            if !empty(glob)
                " TLogVAR glob
                let files = split(glob(glob), '\n')
            else
                let proj = tlib#var#Get('trag_project_'. &filetype, 'bg', tlib#var#Get('trag_project', 'bg', ''))
                " TLogVAR proj
                if !empty(proj)
                    " let proj = fnamemodify(proj, ':p')
                    let proj = findfile(proj, '.;')
                    let files = trag#GetProjectFiles(proj)
                else
                    let git_repos = tlib#var#Get('trag_git', 'bg', '')
                    if git_repos == '*'
                        let git_repos = trag#FindGitRepos()
                    elseif git_repos == "finddir"
                        let git_repos = finddir('.git')
                    endif
                    if !empty(git_repos)
                        let files = trag#GetGitFiles(git_repos)
                    end
                endif
            endif
        endif
    endif
    " TLogVAR files
    if !empty(files)
        call map(files, 'fnamemodify(v:val, ":p")')
        " TLogVAR files
        call trag#AddFiles(files)
    endif
    " TLogVAR b:trag_files_
    if empty(b:trag_files_)
        let files0 = taglist('.')
        " Filter bogus entry?
        call filter(files0, '!empty(v:val.kind)')
        call map(files0, 'v:val.filename')
        call sort(files0)
        let last = ''
        try
            call tlib#progressbar#Init(len(files0), 'TRag: Collect files %s', 20)
            let fidx = 0
            for f in files0
                call tlib#progressbar#Display(fidx)
                let fidx += 1
                " if f != last && filereadable(f)
                if f != last
                    call add(b:trag_files_, f)
                    let last = f
                endif
            endfor
        finally
            call tlib#progressbar#Restore()
        endtry
    endif
endf


function! trag#FindGitRepos() "{{{3
    let dir = fnamemodify(getcwd(), ':p')
    let git = tlib#file#Join([dir, '.git'])
    while !isdirectory(git)
        let dir1 = fnamemodify(dir, ':h')
        if dir == dir1
            break
        else
            let dir = dir1
        endif
        let git = tlib#file#Join([dir, '.git'])
    endwh
    if isdirectory(git)
        return git
    else
        return ''
    endif
endf


" Edit a file from the project catalog. See |g:trag_project| and 
" |:TRagfile|.
function! trag#Edit() "{{{3
    let w = tlib#World#New(copy(g:trag_edit_world))
    let w.base = s:GetFiles()
    let w.show_empty = 1
    let w.pick_last_item = 0
    call w.SetInitialFilter(matchstr(expand('%:t:r'), '^\w\+'))
    call w.Set_display_format('filename')
    " TLogVAR w.base
    call tlib#input#ListW(w)
endf


" Test j trag
" Test n tragfoo
" Test j trag(foo)
" Test n tragfoo(foo)
" Test j trag
" Test n tragfoo

" TODO: If the use of regular expressions alone doesn't meet your 
" demands, you can define the functions trag#Process_{kind}_{filesuffix} 
" or trag#Process_{kind}, which will be run on every line with the 
" arguments: match, line, quicklist, filename, lineno. This function 
" returns [match, line]. If match != -1, the line will be added to the 
" quickfix list.
" If such a function is defined, it will be called for every line.

" :def: function! trag#Grep(args, ?replace=1, ?files=[])
" args: A string with the format:
"   KIND REGEXP
"   KIND1,KIND2 REGEXP
"
" If the variables [bg]:trag_rxf_{kind}_{&filetype} or 
" [bg]:trag_rxf_{kind} exist, these will be taken as format string (see 
" |printf()|) to format REGEXP.
"
" EXAMPLE:
" trag#Grep('v foo') will find by default take g:trag_rxf_v and find 
" lines that looks like "\<foo\>\s*=[^=~]", which most likely is a 
" variable definition in many programming languages. I.e. it will find 
" lines like: >
"   foo = 1
" < but not: >
"   def foo(bar)
"   call foo(bar)
"   if foo == 1
function! trag#Grep(args, ...) "{{{3
    TVarArg ['replace', 1], ['files', []]
    " TLogVAR replace, files
    let [kindspos, kindsneg, rx] = s:SplitArgs(a:args)
    " TLogVAR kindspos, kindsneg, rx, a:args
    if empty(rx)
        let rx = '.\{-}'
        " throw 'Malformed arguments (should be: "KIND REGEXP"): '. string(a:args)
    endif
    " TAssertType rx, 'string'
    let s:grep_rx = rx
    " TLogVAR kindspos, kindsneg, rx, files
    if empty(files)
        let files = s:GetFiles()
        " TLogVAR files
    endif
    " TAssertType files, 'list'
    call tlib#progressbar#Init(len(files), 'TRag: Grep %s', 20)
    if replace
        call setqflist([])
    endif
    let search_mode = g:trag_search_mode
    " TLogVAR search_mode
    let scratch = {}
    try
        if search_mode == 2
            let ei = &ei
            set ei=all
        endif
        let fidx  = 0
        let strip = 0
        " TLogVAR files
        for f in files
            call tlib#progressbar#Display(fidx, ' '. pathshorten(f))
            let rxpos = s:GetRx(f, kindspos, rx, '.')
            " let rxneg = s:GetRx(f, kindsneg, rx, '')
            let rxneg = s:GetRx(f, kindsneg, '', '')
            " TLogVAR kindspos, kindsneg, rx, rxpos, rxneg
            let fidx += 1
            if !filereadable(f) || empty(rxpos)
                " TLogDBG f .': continue '. filereadable(f) .' '. empty(rxpos)
                continue
            endif
            " TLogVAR f
            let fext = fnamemodify(f, ':e')
            let prcacc = []
            " TODO: This currently doesn't work.
            " for kindand in kinds
            "     for kind in kindand
            "         let prc = 'trag#Process_'. kind .'_'. fext
            "         if exists('*'. prc)
            "             call add(prcacc, prc)
            "         else
            "             let prc = 'trag#Process_'. kind
            "             if exists('*'. prc)
            "                 call add(prcacc, prc)
            "             endif
            "         endif
            "     endfor
            " endfor
            " When we don't have to process every line, we slurp the file 
            " into a buffer and use search(), which should be faster than 
            " running match() on every line.
            if empty(prcacc)
                if search_mode == 0 || !empty(rxneg)
                    if empty(scratch)
                        let scratch = {'scratch': '__TRagFileScratch__'}
                        call tlib#scratch#UseScratch(scratch)
                        resize 1
                        let lazyredraw = &lazyredraw
                        set lazyredraw
                    endif
                    norm! ggdG
                    exec 'silent 0read '. tlib#arg#Ex(f)
                    let qfl = {}
                    silent exec 'g/'. escape(rxpos, '/') .'/ call s:AddCurrentLine(f, qfl, rxneg)'
                    norm! ggdG
                    " TLogVAR qfl
                    call setqflist(values(qfl), 'a')
                else
                    " TLogDBG 'vimgrepadd /'. escape(rxpos, '/') .'/j '. tlib#arg#Ex(f)
                    " TLogVAR len(getqflist())
                    " silent! exec 'vimgrepadd /'. escape(rxpos, '/') .'/gj '. tlib#arg#Ex(f)
                    silent! exec 'vimgrepadd /'. escape(rxpos, '/') .'/j '. tlib#arg#Ex(f)
                    let strip = 1
                endif
            else
                let qfl = []
                let lnum = 0
                for line in readfile(f)
                    let lnum += 1
                    let m = match(line, rxpos)
                    for prc in prcacc
                        let [m, line] = call(prc, [m, line, qfl, f, lnum])
                    endfor
                    if m != -1
                        call add(qfl, {
                                    \ 'filename': f,
                                    \ 'lnum': lnum,
                                    \ 'text': tlib#string#Strip(line),
                                    \ })
                    endif
                endfor
                call setqflist(qfl, 'a')
            endif
        endfor
        if strip
            call setqflist(map(getqflist(), 's:StripText(v:val)'), 'r')
        endif
        " TLogDBG 'qfl:'. string(getqflist())
    finally
        if search_mode == 2
            let &ei = ei
        endif
        if !empty(scratch)
            call tlib#scratch#CloseScratch(scratch)
            let &lazyredraw = lazyredraw
        endif
        call tlib#progressbar#Restore()
    endtry
endf


function! s:AddCurrentLine(file, qfl, rxneg) "{{{3
    let lnum = line('.')
    let text = getline(lnum)
    if empty(a:rxneg) || text !~ a:rxneg
        let a:qfl[lnum] = {"filename": a:file, "lnum": lnum, "text": tlib#string#Strip(text)}
    endif
endf


function! s:StripText(rec) "{{{3
    let a:rec['text'] = tlib#string#Strip(a:rec['text'])
    return a:rec
endf


function! s:SplitArgs(args) "{{{3
    let kind = matchstr(a:args, '^\S\+')
    if kind == '.' || kind == '*'
        let kind = ''
    endif
    let rx = matchstr(a:args, '\s\zs.*')
    if stridx(kind, '#') != -1
        let kind = substitute(kind, '#', '', 'g')
        let rx = tlib#rx#Escape(rx)
    endif
    let kinds = split(kind, '[!-]', 1)
    let kindspos = s:SplitArgList(get(kinds, 0, ''), [['identity']])
    let kindsneg = s:SplitArgList(get(kinds, 1, ''), [])
    " TLogVAR a:args, kinds, kind, rx, kindspos, kindsneg
    return [kindspos, kindsneg, rx]
endf


function! s:SplitArgList(string, default) "{{{3
    let rv = map(split(a:string, ','), 'reverse(split(v:val, ''\.'', 1))')
    if empty(rv)
        return a:default
    else
        return rv
    endif
endf


function! trag#ClearCachedRx() "{{{3
    let s:rx_cache = {}
endf
call trag#ClearCachedRx()


function! s:GetRx(filename, kinds, rx, default) "{{{3
    if empty(a:kinds)
        return a:default
    endif
    let rxacc = []
    let ext   = fnamemodify(a:filename, ':e')
    if empty(ext)
        let ext = a:filename
    endif
    let filetype = get(g:trag_filenames, ext, '')
    let id = filetype .'*'.string(a:kinds).'*'.a:rx
    " TLogVAR ext, filetype, id
    if has_key(s:rx_cache, id)
        let rv = s:rx_cache[id]
    else
        for kindand in a:kinds
            let rx= a:rx
            for kind in kindand
                let rxf = tlib#var#Get('trag_rxf_'. kind, 'bg')
                " TLogVAR rxf
                if !empty(filetype)
                    let rxf = tlib#var#Get('trag_rxf_'. kind .'_'. filetype, 'bg', rxf)
                endif
                " TLogVAR rxf
                if empty(rxf)
                    if &verbose > 1
                        if empty(filetype)
                            echom 'Unknown kind '. kind .' for unregistered filetype; skip files like '. ext
                        else
                            echom 'Unknown kind '. kind .' for ft='. filetype .'; skip files like '. ext
                        endif
                    endif
                    return ''
                else
                    " TLogVAR rxf
                    " If the expression is no word, ignore word boundaries.
                    if rx =~ '\W$' && rxf =~ '%\@<!%s\\>'
                        let rxf = substitute(rxf, '%\@<!%s\\>', '%s', 'g')
                    endif
                    if rx =~ '^\W' && rxf =~ '\\<%s'
                        let rxf = substitute(rxf, '\\<%s', '%s', 'g')
                    endif
                    " TLogVAR rxf, rx
                    let rx = tlib#string#Printf1(rxf, rx)
                endif
            endfor
            call add(rxacc, rx)
        endfor
        let rv = s:Rx(rxacc, a:default)
        let s:rx_cache[id] = rv
    endif
    " TLogVAR rv
    return rv
endf


function! s:Rx(rxacc, default) "{{{3
    if empty(a:rxacc)
        let rx = a:default
    elseif len(a:rxacc) == 1
        let rx = a:rxacc[0]
    else
        let rx = '\('. join(a:rxacc, '\|') .'\)'
    endif
    return rx
endf


function! s:GetFilename(qfe) "{{{3
    let filename = get(a:qfe, 'filename')
    if empty(filename)
        let filename = bufname(get(a:qfe, 'bufnr'))
    endif
    return filename
endf

function! s:FormatQFLE(qfe) "{{{3
    let filename = s:GetFilename(a:qfe)
    " let err = get(v:val, "type") . get(v:val, "nr")
    " return printf("%20s|%d|%s: %s", filename, v:val.lnum, err, get(v:val, "text"))
    return printf("%s|%d| %s", filename, a:qfe.lnum, get(a:qfe, "text"))
endf


" :display: trag#QuickList(?world={})
" Display the |quickfix| list with |tlib#input#ListW()|.
function! trag#QuickList(...) "{{{3
    TVarArg ['world', {}]
    " TVarArg ['sign', 'TRag']
    " if !empty(sign) && !empty(g:trag_sign)
    "     " call tlib#signs#ClearAll(sign)
    "     " call tlib#signs#Mark(sign, getqflist())
    " endif
    let w = extend(copy(g:trag_qfl_world), world)
    let w = tlib#World#New(w)
    let w.qfl  = copy(getqflist())
    " TLogVAR w.qfl
    call s:FormatBase(w)
    " TLogVAR w.base
    call tlib#input#ListW(w)
endf


" Display the |location-list| with |tlib#input#ListW()|.
function! trag#LocList(...) "{{{3
    " TVarArg ['sign', 'TRag']
    " if !empty(sign) && !empty(g:trag_sign)
    "     " call tlib#signs#ClearAll(sign)
    "     " call tlib#signs#Mark(sign, getqflist())
    " endif
    let w = tlib#World#New(copy(g:trag_qfl_world))
    let w.qfl  = copy(getloclist())
    " TLogVAR w.qfl
    call s:FormatBase(w)
    " TLogVAR w.base
    call tlib#input#ListW(w)
endf


function! s:FormatBase(world) "{{{3
    let a:world.base = map(copy(a:world.qfl), 's:FormatQFLE(v:val)')
endf

function! trag#AgentEditQFE(world, selected, ...) "{{{3
    TVarArg ['cmd_edit', 'edit'], ['cmd_buffer', 'buffer']
    " TLogVAR a:selected
    if empty(a:selected)
        call a:world.RestoreOrigin()
        " call a:world.ResetSelected()
    else
        call a:world.RestoreOrigin()
        for idx in a:selected
            let idx -= 1
            " TLogVAR idx
            if idx >= 0
                " TLogVAR a:world.qfl
                " call tlog#Debug(string(map(copy(a:world.qfl), 's:GetFilename(v:val)')))
                " call tlog#Debug(string(map(copy(a:world.qfl), 'v:val.bufnr')))
                " TLogVAR idx, a:world.qfl[idx]
                let qfe = a:world.qfl[idx]
                " let back = a:world.SwitchWindow('win')
                " TLogVAR cmd_edit, cmd_buffer, qfe
                call tlib#file#With(cmd_edit, cmd_buffer, [s:GetFilename(qfe)], a:world)
                " TLogDBG bufname('%')
                call tlib#buffer#ViewLine(qfe.lnum)
                " call a:world.SetOrigin()
                " exec back
            endif
        endfor
    endif
    return a:world
endf 


function! trag#AgentPreviewQFE(world, selected) "{{{3
    " TLogVAR a:selected
    let back = a:world.SwitchWindow('win')
    call trag#AgentEditQFE(a:world, a:selected[0:0])
    exec back
    redraw
    let a:world.state = 'redisplay'
    return a:world
endf


function! trag#AgentGotoQFE(world, selected) "{{{3
    if !empty(a:selected)
        if a:world.win_wnr != winnr()
            let world = tlib#agent#Suspend(a:world, a:selected)
            exec a:world.win_wnr .'wincmd w'
        endif
        call trag#AgentEditQFE(a:world, a:selected[0:0])
    endif
    return a:world
endf


function! trag#AgentWithSelected(world, selected) "{{{3
    let cmd = input('Ex command: ', '', 'command')
    if !empty(cmd)
        call trag#RunCmdOnSelected(a:world, a:selected, cmd)
    else
        let a:world.state = 'redisplay'
    endif
    return a:world
endf


function! trag#RunCmdOnSelected(world, selected, cmd) "{{{3
    call a:world.CloseScratch()
    " TLogVAR a:cmd
    for entry in a:selected
        " TLogVAR entry, a:world.GetBaseItem(entry)
        call trag#AgentEditQFE(a:world, [entry])
        " TLogDBG bufname('%')
        exec a:cmd
        " let item = a:world.qfl[a:world.GetBaseIdx(entry - 1)]
        " <+TODO+>
        let item = a:world.qfl[entry - 1]
        " TLogVAR entry, item, getline('.')
        let item['text'] = tlib#string#Strip(getline('.'))
    endfor
    call s:FormatBase(a:world)
    call a:world.RestoreOrigin()
    let a:world.state = 'reset'
    return a:world
endf


function! trag#AgentSplitBuffer(world, selected) "{{{3
    call a:world.CloseScratch()
    return trag#AgentEditQFE(a:world, a:selected, 'split', 'sbuffer')
endf


function! trag#AgentTabBuffer(world, selected) "{{{3
    call a:world.CloseScratch()
    return trag#AgentEditQFE(a:world, a:selected, 'tabedit', 'tab sbuffer')
endf


function! trag#AgentVSplitBuffer(world, selected) "{{{3
    call a:world.CloseScratch()
    return trag#AgentEditQFE(a:world, a:selected, 'vertical split', 'vertical sbuffer')
endf


" function! trag#AgentOpenBuffer(world, selected) "{{{3
" endf


" Invoke an refactor command.
" Currently only one command is supported: rename
function! trag#AgentRefactor(world, selected) "{{{3
    call a:world.CloseScratch()
    let cmds = ['Rename']
    let cmd = tlib#input#List('s', 'Select command', cmds)
    if !empty(cmd)
        return trag#Refactor{cmd}(a:world, a:selected)
    endif
    let a:world.state = 'reset'
    return a:world
endf


function! trag#CWord() "{{{3
    if has_key(g:trag_keyword_chars, &filetype)
        let line  = getline('.')
        let chars = g:trag_keyword_chars[&filetype]
        let rx    = '['. chars .']\+'
        let pre   = matchstr(line[0 : col('.') - 2],  rx.'$')
        let post  = matchstr(line[col('.') - 1 : -1], '^'.rx)
        let word  = pre . post
        " TLogVAR word, pre, post, chars, line
    else
        let word  = expand('<cword>')
    endif
    " TLogVAR word
    return word
endf


function! trag#RefactorRename(world, selected) "{{{3
    " TLogVAR a:selected
    let from = input('Rename ', s:grep_rx)
    if !empty(from)
        let to = input('Rename '. from .' to: ', from)
        if !empty(to)
            let ft = a:world.filetype
            let fn = 'trag#'. ft .'#Rename'
            " TLogVAR ft, exists('*'. fn)
            try
                return call(fn, [a:world, a:selected, from, to])
            catch /^Vim\%((\a\+)\)\=:E117/
                " TLogDBG "General"
                return trag#general#Rename(a:world, a:selected, from, to)
            endtry
        endif
    endif
    let a:world.state = 'reset'
    return a:world
endf


function! trag#SetFollowCursor(world, selected) "{{{3
    if empty(a:world.follow_cursor)
        let a:world.follow_cursor = 'trag#AgentPreviewQFE'
    else
        let a:world.follow_cursor = ''
    endif
    let a:world.state = 'redisplay'
    return a:world
endf


