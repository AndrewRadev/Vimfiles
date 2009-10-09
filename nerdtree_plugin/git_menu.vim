" Put this in ~/.vim/nerdtree_plugin/git_menu.vim
"
" Adds a "g" submenu to the NERD tree menu.
"
" Note: this plugin assumes that the current tree root has a .git dir under
" it, and that the working tree and the .git repo are in the same place
"
if exists("g:loaded_nerdtree_git_menu")
    finish
endif
let g:loaded_nerdtree_git_menu = 1

call NERDTreeAddMenuSeparator({'isActiveCallback': 'NERDTreeGitMenuEnabled'})
let s:menu = NERDTreeAddSubmenu({
            \ 'text': '(g)it menu',
            \ 'shortcut': 'g',
            \ 'isActiveCallback': 'NERDTreeGitMenuEnabled' })

call NERDTreeAddMenuItem({
            \ 'text': 'git (a)dd',
            \ 'shortcut': 'a',
            \ 'callback': 'NERDTreeGitAdd',
            \ 'parent': s:menu })

call NERDTreeAddMenuItem({
            \ 'text': 'git (c)heckout',
            \ 'shortcut': 'c',
            \ 'callback': 'NERDTreeGitCheckout',
            \ 'parent': s:menu })

call NERDTreeAddMenuItem({
            \ 'text': 'git (m)v',
            \ 'shortcut': 'm',
            \ 'callback': 'NERDTreeGitMove',
            \ 'parent': s:menu })

call NERDTreeAddMenuItem({
            \ 'text': 'git (r)m',
            \ 'shortcut': 'r',
            \ 'callback': 'NERDTreeGitRemove',
            \ 'parent': s:menu })

function! NERDTreeGitMenuEnabled()
    return isdirectory(s:GitRepoPath())
endfunction

function! s:GitRepoPath()
    return b:NERDTreeRoot.path.str() . "/.git"
endfunction

function! NERDTreeGitMove()
    let node = g:NERDTreeFileNode.GetSelected()
    let path = node.path
    let p = path.str({'escape': 1})

    let newPath = input("==========================================================\n" .
                          \ "Enter the new path for the file:                          \n" .
                          \ "", node.path.str())
    if newPath ==# ''
        call s:echo("git mv aborted.")
        return
    endif

    call s:execGitCmd('mv ' . p . ' ' . newPath)
endfunction

function! NERDTreeGitAdd()
    let node = g:NERDTreeFileNode.GetSelected()
    let path = node.path
    call s:execGitCmd('add ' . path.str({'escape': 1}))
endfunction

function! NERDTreeGitRemove()
    let node = g:NERDTreeFileNode.GetSelected()
    let path = node.path
    call s:execGitCmd('rm ' . path.str({'escape': 1}))
endfunction

function! NERDTreeGitCheckout()
    let node = g:NERDTreeFileNode.GetSelected()
    let path = node.path
    call s:execGitCmd('checkout ' . path.str({'escape': 1}))
endfunction

function! s:execGitCmd(sub_cmd)
    let extra_options  = '--git-dir=' . s:GitRepoPath() . ' '
    let extra_options .= '--work-tree=' . b:NERDTreeRoot.path.str()
    let cmd = "git" . ' ' . extra_options . ' ' . a:sub_cmd

    let output = system(cmd)
    redraw!
    if v:shell_error == 0
        let node = g:NERDTreeFileNode.GetSelected()
        if !node.isRoot()
            call node.parent.refresh()
            call NERDTreeRender()
        endif
    else
        echomsg output
    endif
endfunction

