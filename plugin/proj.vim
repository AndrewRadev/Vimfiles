" ============================================================================
" File:        proj.vim
" Description: Simple Vim project tool
" Maintainer:  Thomas Allen <tmallen at 703designs dot com>
" ============================================================================
let s:ProjVersion = '1.0'

function! s:Set(var, val)
    if !exists(a:var)
        exec 'let ' . a:var . ' = "' a:val . '"'
    end
endfunction

call s:Set('g:ProjFileBrowser', 'NERDTree')
call s:Set('g:ProjFile', '~/.vimproj')
call s:Set('g:ProjNoteFile', 'notes.txt')
call s:Set('g:ProjSplitMethod', 'vsp')

function! s:LoadProjects()
    try
        let s:Config = readfile(expand(g:ProjFile))
    catch /E484.*/
        exec s:echoError('Could not read project file "' . g:ProjFile . '"')
    endtry

    let projects = {}
    let title = ''

    for line in s:Config
        let line = s:strip(line)
        if strlen(line) > 0
            if match(line, '^\s*;') == 0
                continue
            elseif match(line, '[') == 0
                let title = strpart(split(line, ';')[0], 1, strlen(line) - 2)
                let projects[title] = {}
            else
                let option = map(split(line, '='), 's:strip(v:val)')
                let key = option[0]
                let projects[title][key] = split(option[1], ';')[0]
            end
        end
    endfor

    return projects
endfunction

function! s:Valid(project)
    " Built-in type ID for dict
    let s:DictType = 4

    if type(a:project) == s:DictType
        return 1
    else
        return 0
    end
endfunction

function! s:OpenProject(name)
    let project = s:GetProject(a:name)

    if s:Valid(project) == 1
        let s:Current = project
        call s:RefreshCurrent()
    end
endfunction

function! s:RefreshCurrent()
    if has_key(s:Current, 'path') == 1
        exec 'cd ' . s:Current['path']
        set path=./**
    end

    if has_key(s:Current, 'vim') == 1
        exec 'so ' . s:Current['vim']
    end

    if has_key(s:Current, 'browser') == 1
        if match(g:ProjFileBrowser, 'off') != 0 && match(s:Current['browser'], 'off') != 0
            exec s:Current['browser']
        else
            echo 'Browser disabled'
        end
    else
        exec g:ProjFileBrowser
    end
endfunction

function! s:GetProject(name)
    if has_key(g:Projects, a:name) == 1
        return g:Projects[a:name]
    else
        exec s:echoError('Project "' . a:name . '" not found in ' . g:ProjFile)
        return 0
    end
endfunction

function! s:echo(msg)
    redraw
    echomsg 'Proj: ' . a:msg
endfunction

function! s:echoError(msg)
    echohl errormsg
    call s:echo(a:msg)
    echohl normal
endfunction

function! s:strip(text)
    let text = substitute(a:text, '^[[:space:][:cntrl:]]\+', '', '')
    let text = substitute(text, '[[:space:][:cntrl:]]\+$', '', '')
    return text
endfunction

let g:Projects = s:LoadProjects()

function! s:Complete(A, L, P)
    return filter(keys(g:Projects), 'v:val =~ "^' . a:A . '"')
endfunction

function! s:OpenVimFile()
    if has_key(s:Current, 'vim') == 1
        exec join([g:ProjSplitMethod . s:Current['vim']], ' ')
    end
endfunction

function! s:OpenFile()
    exec join([g:ProjSplitMethod, g:ProjFile], ' ')
endfunction

function! s:DumpInfo()
    let output = ''

    for key in keys(s:Current)
        let output = output . key . '=' . s:Current[key] . '; '
    endfor

    echo output
endfunction

function! s:OpenNotes()
    if has_key(s:Current, 'notes') == 1
        let file = s:Current['notes']
    else
        let file = g:ProjNoteFile
    end

    exec join([g:ProjSplitMethod, file], ' ')
endfunction

" Commands
command! -complete=customlist,s:Complete -nargs=1 Proj :call s:OpenProject('<args>')
command! ProjReload :call s:LoadProjects()
command! ProjRefresh :call s:RefreshCurrent()
command! ProjVim :call s:OpenVimFile()
command! ProjFile :call s:OpenFile()
command! ProjInfo :call s:DumpInfo()
command! ProjNotes :call s:OpenNotes()

