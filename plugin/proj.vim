" ============================================================================
" File:        proj.vim
" Description: Simple Vim project tool
" Maintainer:  Thomas Allen <thomasmallen@gmail.com>
" ============================================================================
let s:ProjVersion = '1.2'

" Section: Core functions {{{1
" Section: Utilities {{{2
function! s:echo(msg)
    " Args: a:msg (string)
    " Format a message with a prefix
    redraw
    echomsg 'Proj: ' . a:msg
endfunction

function! s:echoError(msg)
    " Args: a:msg (string)
    " Format a message as an error
    echohl errormsg
    call s:echo(a:msg)
    echohl normal
endfunction

function! s:strip(text)
    " Args: a:text (string)
    " Strips whitespace from left and right of string
    " Returns: string
    let text = substitute(a:text, '^[[:space:][:cntrl:]]\+', '', '')
    let text = substitute(text, '[[:space:][:cntrl:]]\+$', '', '')
    return text
endfunction

" Section: Project loading {{{2
function! s:GetFile()
    " Expands the ProjFile path
    " Returns: string
    return expand(g:ProjFile)
endfunction

function! s:FileReadable()
    " Checks if the listing file is available
    " Returns: boolean
    return filereadable(s:GetFile())
endfun

function! s:ReadFile(var)
    " Args: a:var (string)
    " Reads the listing file's contents as list and assigns it to a:var
    " Returns: boolean
    if(s:FileReadable())
        exec join(["let", a:var, "=", "readfile('" . s:GetFile() . "')"])
        return 1
    else
        return 0
    end
endfunction

function! s:ParseIni(ini)
    " Args: a:ini (list)
    " Turns the lines of an INI file into a list
    " Returns: list
    let parsed = {}

    for line in a:ini
        let line = s:strip(line)
        if strlen(line) > 0
            if match(line, '^\s*;') == 0
                " Comment
                continue
            elseif match(line, '[') == 0
                " Section name
                " Grab text up to first semicolon (comment)
                let header = split(line, ';')[0]
                " Remove one character from each side (brackets)
                let section = strpart(header, 1, strlen(line) - 2)
                let parsed[section] = {}

            else
                " Option (key/value pair)
                let option = map(split(line, '='), 's:strip(v:val)')
                let key = option[0]
                let parsed[section][key] = split(option[1], ';')[0]
            end
        end
    endfor

    return parsed
endfunction

function! s:LoadProjectsRaw()
    " Loads the listing file as the global project list
    if(s:ReadFile('s:Config'))
        let g:Projects = s:ParseIni(s:Config)
    else
        let g:Projects = {}
    end
endfunction

function! s:LoadProjects()
    " Loads the listing file as the global project list, showing an error
    " message if it's not present.
    if(s:ReadFile('s:Config'))
        let g:Projects = s:ParseIni(s:Config)
    else
        exec s:echoError('Could not read project file "' . s:GetFile() . '"')
    end
endfunction

function! s:Valid(project)
    " Args: a:project (string)
    " Checks if a project is available in the project list
    " Returns: boolean
    " Built-in type ID for dict is 4
    return type(a:project) == 4
endfunction

function! s:GetProject(name)
    " Args: a:name (string)
    " Checks if a project is avaialable and assigns it to a:name
    " Returns: boolean
    if has_key(g:Projects, a:name) == 1 && type(g:Projects[a:name]) == 4
        exec join(['let', 's:Current', '=', 'g:Projects["' . a:name . '"]'], ' ')
        return 1
    else
        exec s:echoError('Project "' . a:name . '" not found in ' . s:GetFile())
        return 0
    end
endfunction

function! s:OpenProject(name)
    " Args: a:name (string)
    " Loads the project and refreshes
    if(s:GetProject(a:name))
        call s:RefreshCurrent()
    end
endfunction

function! s:IsOpen()
    " Checks if a project is open
    " Returns: boolean
    return exists('s:Current')
endfunction

function! s:RefreshCurrent()
    " Opens the filebrowser and cds to the base path
    if(s:IsOpen())
        if has_key(s:Current, 'path') == 1
            exec 'cd ' . s:Current['path']
        end

        if has_key(s:Current, 'vim') == 1
            exec 'so ' . s:Current['vim']
        end

        if match(g:ProjFileBrowser, 'off') != 0
            if has_key(s:Current, 'browser') == 1
                if match(s:Current['browser'], 'off') != 0
                    exec s:Current['browser']
                else
                    echo 'Browser disabled'
                end
            else
                exec g:ProjFileBrowser
            end
        else
            echo 'Browser disabled'
        end
    end
endfunction

" Section: Miscellaneous actions {{{2
function! s:AddProject(name)
    " Adds a new project to the project file
    let item = ['', '[' . a:name . ']', 'path = ' . getcwd()]
    if(s:ReadFile('s:CurrentFile'))
        let lines = s:CurrentFile + item
    else
        let lines = item
    end
    call writefile(lines, s:GetFile())
    call s:LoadProjects()
endfunction

function! s:OpenVimFile()
    " Opens the project's vim file if it exists
    if(s:IsOpen())
        if has_key(s:Current, 'vim') == 1
            exec join([g:ProjSplitMethod . s:Current['vim']], ' ')
        end
    end
endfunction

function! s:OpenFile()
    " Opens the project listing file if it exists
    if(s:FileReadable())
        exec join([g:ProjSplitMethod, s:GetFile()], ' ')
    end
endfunction

function! s:DumpInfo()
    " Echoes a project's settings in the cmd if a project is open
    if(s:IsOpen())
        let output = ''
        for key in keys(s:Current)
            let output = output . key . '=' . s:Current[key] . '; '
        endfor
        echo output
    end
endfunction

function! s:OpenNotes()
    " Opens the project notes file if a project is open
    if(s:IsOpen())
        if has_key(s:Current, 'notes') == 1
            let noteFile = s:Current['notes']
        else
            let noteFile = g:ProjNoteFile
        end

        if expand('%') == noteFile
            quit
        else
            exec join([g:ProjSplitMethod, noteFile], ' ')
        end
    end
endfunction

" Section: Initialization {{{1
function! s:Set(var, val)
    " Args: a:var (string), a:val (string)
    " Assigns a:val to a:var unless a:var is already defined
    if !exists(a:var)
        exec 'let ' . a:var . ' = "' a:val . '"'
    end
endfunction

" Section: Global variables {{{2
call s:Set('g:ProjFileBrowser', 'NERDTree')
call s:Set('g:ProjFile', '~/.vimproj')
call s:Set('g:ProjNoteFile', 'notes.txt')
call s:Set('g:ProjSplitMethod', 'vsp')

call s:Set('g:ProjDisableMappings', 0)
call s:Set('g:ProjMapLeader', '<Leader>p')
call s:Set('g:ProjOpenMap', g:ProjMapLeader . 'o')
call s:Set('g:ProjNotesMap', g:ProjMapLeader . 'n')
call s:Set('g:ProjInfoMap', g:ProjMapLeader . 'i')

call s:LoadProjectsRaw()

" Section: Mappings {{{1
function! s:Map(type, key, cmd)
    exec join([a:type, a:key, a:cmd], ' ')
endfunction

function! s:NormalMap(key, cmd)
    exec s:Map('nnoremap', a:key, a:cmd)
endfunction

if g:ProjDisableMappings != 1
    call s:NormalMap(g:ProjOpenMap, ':Proj ')
    call s:NormalMap(g:ProjInfoMap, ':ProjInfo<CR>')
    call s:NormalMap(g:ProjNotesMap, ':ProjNotes<CR>')
end

" Section: Commands {{{1
function! s:Complete(A, L, P)
    if(exists('g:Projects'))
        return filter(keys(g:Projects), 'v:val =~ "^' . a:A . '"')
    end
endfunction

command! -complete=customlist,s:Complete -nargs=1 Proj :call s:OpenProject('<args>')
command! -nargs=1 ProjAdd :call s:AddProject('<args>')
command! ProjReload :call s:LoadProjects()
command! ProjRefresh :call s:RefreshCurrent()
command! ProjVim :call s:OpenVimFile()
command! ProjFile :call s:OpenFile()
command! ProjInfo :call s:DumpInfo()
command! ProjNotes :call s:OpenNotes()

" vim: set foldmethod=marker :
