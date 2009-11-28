" ttags.vim
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-09.
" @Last Change: 2009-04-11.
" @Revision:    316

if &cp || exists("loaded_ttags_autoload")
    finish
endif
let loaded_ttags_autoload = 1

let s:tags = {}


function! ttags#Kinds(...) "{{{3
    TVarArg ['tags', []]
    if empty(tags)
        let tags = taglist('.')
    end
    let kinds = {}
    for t in tags
        let k = t.kind
        if !empty(k)
            if has_key(kinds, k)
                let kinds[k].n += 1
            else
                let kinds[k] = {'n': 0, 'sample': t}
            endif
        else
            " TLogDBG 'Empty kind: '. string(t)
        endif
    endfor
    return kinds
endf


function! ttags#Highlight(tags) "{{{3
    let kinds = sort(keys(ttags#Kinds(a:tags)))
    let acc = []
    let hv = tlib#var#Get('ttags_highlighting_'. &filetype, 'bg', tlib#var#Get('ttags_highlighting', 'bg'))
    " TLogVAR hv
    for kind in kinds
        let hi = get(hv, kind)
        " TLogVAR hi
        if !empty(hi)
            if kind ==# toupper(kind)
                let kindg = kind.kind
            else
                let kindg = kind
            end
            call add(acc, 'syn match TTags_'. kindg .' /\C'. kind .': \zs.\{-}\ze\($\|\s|\s\)/')
            call add(acc, 'hi def link TTags_'. kindg .' '. hi)
        endif
    endfor
    let acc += [
                \ 'syn match TTags_source_dir / |.\{-}\s\zs(.*$/',
                \ 'hi def link TTags_source_dir Directory'
                \ ]
    " TLogVAR acc
    return join(acc, ' | ')
endf


" :def: function! ttags#List(use_extra, ?kind='', ?rx='', ?file_rx='')
" Calls |ttags#SelectTags()|.
function! ttags#List(use_extra, ...) "{{{3
    TVarArg ['kind', tlib#var#Get('ttags_kinds', 'wbg')],
                \ ['rx', tlib#var#Get('ttags_name_rx', 'wbg')],
                \ ['file_rx', tlib#var#Get('ttags_filename_rx', 'wbg')]
    " TLogVAR rx, file_rx
    call ttags#SelectTags(a:use_extra, {'name': rx, 'kind': kind, 'filename': file_rx})
endf


" Calls |ttags#SelectTags()|.
function! ttags#Select(use_extra, keyargs_as_string) "{{{3
    let constraints = s:ParseArgs(a:keyargs_as_string)
    call ttags#SelectTags(a:use_extra, constraints)
endf


function! s:ParseArgs(keyargs_as_string) "{{{3
    let constraints = tlib#var#Get('ttags_constraints', 'wbg', {})
    let constraints = extend(constraints, tlib#arg#StringAsKeyArgs(a:keyargs_as_string))
    return constraints
endf


" Arguments:
"   use_extra: Use extra tags (see |g:tlib_tags_extra|).
"   constraints: A dictionary of fields and corresponding regexps
"     kind     :: The tag letter ID ("*" = match all tags)
"     name     :: A rx matching the tag ("*" = match all tags)
"     filename :: A rx matching the filename ('.' = match the current 
"                 file only)
function! ttags#SelectTags(use_extra, constraints) "{{{3
    if get(a:constraints, 'filename', '') == '.'
        let a:constraints.filename = substitute(substitute(expand('%:p'), '[\\/]', '[\\\\/]', 'g'), '^[^:]\+:', '', '')
        " TLogVAR a:constraints.filename
    endif
    " TLogVAR a:use_extra, a:constraints
    let world      = copy(g:ttags_world)
    let world.tags = tlib#tag#Collect(a:constraints, a:use_extra,
                \ tlib#var#Get('ttags_match_end', 'bg'),
                \ tlib#var#Get('ttags_match_front', 'bg'))
    " TLogVAR world.tags
    if !empty(world.tags)
        let display = tlib#var#Get('ttags_display', 'bg')
        if display == 'locations'
            call setloclist(0, s:MakeQFL(world.tags))
            lwindow
        elseif display == 'quickfix'
            call setqflist(s:MakeQFL(world.tags))
            cwindow
        else
            let world.base = map(copy(world.tags), 's:FormatTag(v:val)')
            " TLogVAR world.base
            if tlib#cmd#UseVertical('TTags')
                let world.scratch_vertical = 1
            endif
            let world.tlib_UseInputListScratch = ttags#Highlight(world.tags)
            let world = tlib#World#New(world)
            call world.SetOrigin()
            call tlib#input#ListW(world)
        endif
    else
        call s:NoTags()
    endif
endf


function! s:NoTags() "{{{3
    echohl Error
    echom 'ttags: No tags'
    echohl NONE
endf


function! s:FormatTag(tag) "{{{3
    let name = tlib#tag#Format(a:tag)
    return printf('%s: %-20s | %s (%s)', a:tag.kind, name, fnamemodify(a:tag.filename, ":t"), pathshorten(fnamemodify(a:tag.filename, ":p:h")))
endf


function! s:MakeQFL(tags) "{{{3
    return map(copy(a:tags), 's:MakeQFE(v:val)')
endf


function! s:MakeQFE(tag) "{{{3
    let rv = {}
    for [o, n] in [['filename', 'filename'], ['cmd', 'pattern'], ['kind', 'type']]
        let v = get(a:tag, o)
        if !empty(v)
            if o == 'cmd'
                if v =~ '^/.\{-}/$'
                    let v = v[1:-2]
                elseif v[0] == '/'
                    let v = v[1:-1]
                else
                    let v = matchstr(v, '^\d\+')
                    let n = 'lnum'
                endif
            endif
            let rv[n] = v
        endif
        unlet v
    endfor
    return rv
endf


function! s:GetTag(world, id) "{{{3
    return a:world.tags[a:world.GetBaseIdx0(a:id)]
endf


function! s:ShowTag(world, tagline) "{{{3
    let tag = s:GetTag(a:world, a:tagline)
    " TLogVAR tag.filename
    let rewriter = tlib#var#Get('ttags_rewrite', 'bg')
    let filename = tag.filename
    if !empty(rewriter)
        let filename = call(rewriter, [filename])
    endif
    call tlib#file#With('edit', 'buffer', [filename], a:world)
    " TLogVAR tag.cmd, filename, bufname('%')
    let magic = &magic
    try
        set nomagic
        exec tag.cmd
    finally
        let &magic = magic
    endtry
    call tlib#buffer#HighlightLine(line('.'))
    norm! zz
    redraw
endf


function! ttags#PreviewTag(world, selected) "{{{3
    let back = a:world.SwitchWindow('win')
    call s:ShowTag(a:world, a:selected[0])
    exec back
    let a:world.state = 'redisplay'
    return a:world
endf


function! ttags#GotoTag(world, selected) "{{{3
    if empty(a:selected)
        call a:world.RestoreOrigin()
    else
        if a:world.win_wnr != winnr()
            let world = tlib#agent#Suspend(a:world, a:selected)
            exec a:world.win_wnr .'wincmd w'
        endif
        call s:ShowTag(a:world, a:selected[0])
        call a:world.SetOrigin()
    endif
    return a:world
endf


function! ttags#InsertTemplate(world, selected) "{{{3
    let back = a:world.SwitchWindow('win')
    for tagid in a:selected
        let tag = s:GetTag(a:world, tagid)
        if exists('g:loaded_tskeleton') && g:loaded_tskeleton > 301
            call tskeleton#ExpandBitUnderCursor('n', tag.name)
        else
            call tlib#buffer#InsertText(tag.name)
        endif
    endfor
    exec back
    let a:world.state = 'exit'
    return a:world
endf


function! ttags#RewriteCygwinTag(filename) "{{{3
    return substitute(a:filename, '^.\{-}[\/]cygdrive[\/]\(.\)', '\1:', '')
endf


