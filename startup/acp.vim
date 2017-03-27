let g:acp_enableAtStartup    = 1 " Enable
let g:acp_ignorecaseOption   = 0 " Don't ignore case, that's annoying
let g:acp_behaviorFileLength = 2 " Speed up?

" Custom behaviour here in order not to disturb normal plugin behaviour
let g:acp_behavior = {
      \ 'php':    [],
      \ 'ruby':   [],
      \ 'python': [],
      \ 'less':   [],
      \ 'scss':   [],
      \ 'go':     [],
      \ 'rust':   [],
      \ }

call add(g:acp_behavior.php, {
      \   'command'      : "\<C-x>\<C-u>",
      \   'completefunc' : 'htmlcomplete#CompleteTags',
      \   'meets'        : 'AcpMeetsForPhpHtmlTag',
      \   'repeat'       : 1,
      \ })
call add(g:acp_behavior.php, {
      \   'command' : "\<C-n>",
      \   'meets'   : 'acp#meetsForKeyword',
      \   'repeat'  : 0,
      \ })
call add(g:acp_behavior.php, {
      \   'command' : "\<C-x>\<C-f>",
      \   'meets'   : 'acp#meetsForFile',
      \   'repeat'  : 1,
      \ })

call add(g:acp_behavior.ruby, {
      \   'command' : "\<C-n>",
      \   'meets'   : 'acp#meetsForKeyword',
      \   'repeat'  : 0,
      \ })
call add(g:acp_behavior.ruby, {
      \   'command' : "\<C-x>\<C-f>",
      \   'meets'   : 'acp#meetsForFile',
      \   'repeat'  : 1,
      \ })

call add(g:acp_behavior.python, {
      \   'command' : "\<C-n>",
      \   'meets'   : 'acp#meetsForKeyword',
      \   'repeat'  : 0,
      \ })
call add(g:acp_behavior.python, {
      \   'command' : "\<C-x>\<C-f>",
      \   'meets'   : 'acp#meetsForFile',
      \   'repeat'  : 1,
      \ })

call add(g:acp_behavior.less, {
      \   'command' : "\<C-x>\<C-o>",
      \   'meets'   : 'acp#meetsForCssOmni',
      \   'repeat'  : 0,
      \ })

call add(g:acp_behavior.scss, {
      \   'command' : "\<C-x>\<C-o>",
      \   'meets'   : 'acp#meetsForCssOmni',
      \   'repeat'  : 0,
      \ })

call add(g:acp_behavior.go, {
      \   'command' : "\<C-x>\<C-o>",
      \   'meets'   : 'AcpMeetsForGo',
      \   'repeat'  : 0,
      \ })

call add(g:acp_behavior.rust, {
      \   'command' : "\<C-x>\<C-o>",
      \   'meets'   : 'AcpMeetsForRust',
      \   'repeat'  : 0,
      \ })

" Added the condition that the tag does not contain '?'
function! AcpMeetsForPhpHtmlTag(context)
  return g:acp_behaviorHtmlOmniLength >= 0 &&
        \ a:context =~ '\(<\|<\/\|<[^?>]\+ \|<[^>]\+=\"\)\k\{' .
        \              g:acp_behaviorHtmlOmniLength . ',}$'
endfunction

function! AcpMeetsForGo(context)
  return &omnifunc != '' && a:context =~ '\k\.\k*$'
endfunction

function! AcpMeetsForRust(context)
  return &omnifunc != '' && a:context =~ '\k::\k*$'
endfunction
