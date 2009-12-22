" trag.vim -- Jump to a file registered in your tags
" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2007-09-29.
" @Last Change: 2009-12-20.
" @Revision:    593
" GetLatestVimScripts: 2033 1 trag.vim

if &cp || exists("loaded_trag")
    finish
endif
if !exists('g:loaded_tlib') || g:loaded_tlib < 32
    runtime plugin/02tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 32
        echoerr 'tlib >= 0.32 is required'
        finish
    endif
endif
let loaded_trag = 7

let s:save_cpo = &cpo
set cpo&vim


" :nodoc:
TLet g:trag_kinds = {}
" :nodoc:
TLet g:trag_filenames = {}
" :nodoc:
TLet g:trag_keyword_chars = {}

" 0 ... use the built-in search.
" 1 ... use vimgrep.
" 2 ... use vimgrep but set 'ei' to all; this means special file 
"       encodings won't be detected
" Please not, this is only in effect with simple searches (as for 0.3 
" all searches are simple). For more complex multi-line patterns, the 
" built-in search will be used (some day in the future).
TLet g:trag_search_mode = 2

" If no project files are defined, evaluate this expression as 
" fallback-strategy.
TLet g:trag_get_files = 'split(glob("*"), "\n")'
TLet g:trag_get_files_java = 'split(glob("**/*.java"), "\n")'
TLet g:trag_get_files_c = 'split(glob("**/*.[ch]"), "\n")'
TLet g:trag_get_files_cpp = 'split(glob("**/*.[ch]"), "\n")'

" " If non-empty, display signs at matching lines.
" TLet g:trag_sign = has('signs') ? '>' : ''
" if !empty(g:trag_sign)
"     exec 'sign define TRag text='. g:trag_sign .' texthl=Special'
" 
"     " Clear all trag-related signs.
"     command! TRagClearSigns call tlib#signs#ClearAll('TRag')
" endif


" :nodoc:
function! s:TRagDefKind(args) "{{{3
    " TLogVAR a:args
    " TLogDBG string(matchlist(a:args, '^\(\S\+\)\s\+\(\S\+\)\s\+/\(.\{-}\)/$'))
    let [match, kind, filetype, regexp; rest] = matchlist(a:args, '^\(\S\+\)\s\+\(\S\+\)\s\+/\(.\{-}\)/$')
    let var = ['g:trag_rxf', kind]
    if filetype != '*' && filetype != '.'
        call add(var, filetype)
    endif
    let varname = join(var, '_')
    let {varname} = substitute(regexp, '\\/', '/', 'g')
    if has_key(g:trag_kinds, kind)
        call add(g:trag_kinds[kind], filetype)
    else
        let g:trag_kinds[kind] = [filetype]
    endif
endf


" :display: :TRagDefKind KIND FILETYPE /REGEXP_FORMAT/
" The regexp argument is no real regexp but a format string. % thus have 
" to be escaped with % (see |printf()| for details). The REGEXP_FORMAT 
" should contain at least one %s.
" Examples: >
"   TRagDefKind v * /\C\<%s\>\s*=[^=~<>]/
"   TRagDefKind v ruby /\C\<%s\>\(\s*,\s*[[:alnum:]_@$]\+\s*\)*\s*=[^=~<>]/
command! -nargs=1 TRagDefKind call s:TRagDefKind(<q-args>)


" :display: TRagKeyword FILETYPE KEYWORD_CHARS
" Override 'iskeyword' for a certain filetype. See also |trag#CWord()|.
command! -nargs=+ TRagKeyword if len([<f-args>]) == 2
            \ | let g:trag_keyword_chars[[<f-args>][0]] = [<f-args>][1]
            \ | else
                \ | echoerr 'Expected "FILETYPE KEYWORDRX", but got: <q-args>'
                \ | endif


" :display: TRagDefFiletype FILETYPE EXTENSION ... FILENAME ...
" In order to recognize files based on their extension, you have to 
" declare filetypes first.
" If a file has no extension, the whole filename is used.
" Examples: >
"   TRagDefFiletype html html htm xhtml
command! -nargs=+ TRagDefFiletype for e in [<f-args>][1:-1] | let g:trag_filenames[e] = [<f-args>][0] | endfor


TRagDefKind identity * /\C%s/

" Left hand side value in an assignment.
" Examples:
" l foo =~ foo = 1
TRagDefKind l * /\C%s\s*[^=]*=[^=~<>]/
" TRagDefKind l * /\C\<%s\>\s*=[^=~<>]/
" L foo =~ fufoo0 = 1
" TRagDefKind L * /\C%s[^=]*=[^=~<>]/

" Right hand side value in an assignment.
" Examples:
" r foo =~ bar = foo
TRagDefKind r * /\C[^!=~<>]=.\{-}%s/
" L foo =~ bar = fufoo0
" TRagDefKind r * /\C[^!=~<>]=.\{-}\<%s\>/
" TRagDefKind R * /\C[^!=~<>]=.\{-}%s/

" Markers: TODO, TBD, FIXME, OPTIMIZE
TRagDefKind todo * /\C\(TBD\|TODO\|FIXME\|OPTIMIZE\)/

" A mostly general rx format string for function calls.
TRagDefKind f * /\C%s\S*\s*(/
" TRagDefKind f * /\C\<%s\>\s*(/
" TRagDefKind F * /\C%s\S*\s*(/

" A mostly general rx format string for words.
TRagDefKind w * /\C\<%s\>/
TRagDefKind W * /\C.\{-}%s.\{-}/

TRagDefKind fuzzy * /\c%{fuzzyrx}/


TRagDefFiletype java java
let s:java_mod = '\(\<\(final\|public\|protected\|private\|synchronized\|volatile\|abstract\)\s\+\)*'
let s:java_type = '\(boolean\|byte\|short\|int\|long\|float\|double\|char\|void\|\u[[:alnum:]_.]*\)\s\+'
exec 'TRagDefKind c java /\C^\s*'. s:java_mod .'class\s\+%s/'
exec 'TRagDefKind d java /\C^\s*'. s:java_mod .'\(\w\+\(\[\]\)*\)\s\+%s\s*(/'
exec 'TRagDefKind f java /\(\(;\|{\|^\)\s*'. s:java_mod . s:java_type .'\)\@<!%s\s*\([(;]\|$\)/'
TRagDefKind i java /\C^\s*\(\/\/\|\/\*\).\{-}%s/
TRagDefKind x java /\C^.\{-}\<\(interface\|class\)\s\+.\{-}\s\+\(extends\|implements\)\s\+%s/
unlet s:java_mod s:java_type



TRagDefFiletype ruby rb
TRagDefKind w ruby /\C[:@]\?\<%s\>/
TRagDefKind W ruby /\C[^;()]\{-}%s[^;()]\{-}/
TRagDefKind c ruby /\C\<class\s\+\(\u\w*::\)*%s\>/
" TRagDefKind d ruby /\C\<\(def\s\+\(\u\w*\.\)*\|attr\(_\w\+\)\?\s\+\(:\w\+,\s\+\)*:\)%s\>/
" TRagDefKind D ruby /\C\<\(def\s\+\(\u\w*\.\)*\|attr\(_\w\+\)\?\s\+\(:\w\+,\s\+\)*:\).\{-}%s/
TRagDefKind d ruby /\C\<\(def\s\+\(\u\w*\.\)*\|attr\(_\w\+\)\?\s\+\(:\w\+,\s\+\)*:\)%s/
" TRagDefKind f ruby /\C\(\<def\s\+\(\u\w*\.\)*\|:\)\@<!\<%s\>\s*\([(;]\|$\)/
" TRagDefKind f ruby /\(;\|^\)\s*\<%s\>\s*\([(;]\|$\)/
" TRagDefKind f ruby /\(;\|^\)\s*[^();]\{-}%s\s*\([(;]\|$\)/
" TRagDefKind f ruby /\(;\|^\)\s*%s\s*\([(;]\|$\)/
TRagDefKind f ruby /\(\<def\s\+\)\@<!%s\s*\([(;]\|$\)/
" TRagDefKind i ruby /\C^\s*#.\{-}%s/
TRagDefKind i ruby /\C^\s*#%s/
TRagDefKind m ruby /\C\<module\s\+\(\u\w*::\)*%s/
" TRagDefKind l ruby /\C\<%s\>\(\s*,\s*[[:alnum:]_@$]\+\s*\)*\s*=[^=~<>]/
TRagDefKind l ruby /\C%s\(\s*,\s*[[:alnum:]_@$]\+\s*\)*\s*=[^=~<>]/
TRagDefKind x ruby /\C\s\*class\>.\{-}<\s*%s/


TRagDefFiletype vim vim .vimrc _vimrc
TRagKeyword vim [:alnum:]_:#
TRagDefKind W vim /\C[^|]\{-}%s[^|]\{-}/
" TRagDefKind d vim /\C\<\(fu\%%[nction]!\?\|com\%%[mand]!\?\(\s\+-\S\+\)*\)\s\+\<%s\>/
" TRagDefKind D vim /\C\<\(fu\%%[nction]!\?\|com\%%[mand]!\?\(\s\+-\S\+\)*\)\.+%s/
" TRagDefKind d vim /\C\<\(fu\%%[nction]!\?\|com\%%[mand]!\?\(\s\+-\S\+\)*\)[^|]\{-}%s/
TRagDefKind d vim /\C\<\(fu\%%[nction]!\?\s\+\|com\%%[mand]!\?\s\+\(-\S\+\s\+\)*\)%s/
" TRagDefKind f vim /\C\(\(^\s*\<fu\%%[nction]!\?\s\+\(s:\)\?\|com\%%[mand]!\?\(\s\+-\S\+\)*\s\+\)\@<!\<%s\>\s*(\|\(^\||\)\s*\<%s\>\)/
" TRagDefKind F vim /\C\(\(^\s*\<fu\%%[nction]!\?\s\+\(s:\)\?\|com\%%[mand]\(\s\+-\S\+\)*\s\+\)\@<!\S\{-}%s\S\{-}(\|\(^\||\)\s*%s\)/
TRagDefKind f vim /\C\(\(^\s*\<fu\%%[nction]!\?\s\+\(s:\)\?\|com\%%[mand]\(\s\+-\S\+\)*\s\+\)\@<!\S\{-}%s\S\{-}(\|\(^\||\)\s*%s\)/
" TRagDefKind i vim /\C^\s*".\{-}%s/
" This isn't correct. It doesn't find in-line comments.
TRagDefKind i vim /\C^\s*"%s/
" TRagDefKind r vim /\C^\s*let\s\+\S\+\s*=.\{-}\<%s\>/
" TRagDefKind R vim /\C^\s*let\s\+\S\+\s*=.\{-}%s/
TRagDefKind r vim /\C^\s*let\s\+\S\+\s*=[^|]\{-}%s/
" TRagDefKind l vim /\C^\s*let\s\+\<%s\>/
" TRagDefKind L vim /\C^\s*let\s.\{-}%s/
TRagDefKind l vim /\C^\s*let\s\+[^=|]\{-}%s/


TRagDefFiletype viki txt viki dpl
TRagDefKind i viki /\C^\s\+%%%s/
TRagDefKind d viki /\C^\s*#\u\w*\s\+.\{-}\(id=%s\|%s=\)/
TRagDefKind h viki /\C^\*\+\s\+%s/
TRagDefKind l viki /\C^\s\+%s\s\+::/
TRagDefKind r viki /\C^\s\+\(.\{-}\s::\|[-+*#]\|[@?].\)\s\+%s/
TRagDefKind todo viki /\C\(TODO:\?\|FIXME:\?\|+++\|!!!\|###\|???\)\s\+%s/


" :nodoc:
TLet g:trag_edit_world = {
            \ 'type': 's',
            \ 'query': 'Select file',
            \ 'pick_last_item': 1,
            \ 'scratch': '__TRagEdit__',
            \ 'return_agent': 'tlib#agent#ViewFile',
            \ }


" :nodoc:
TLet g:trag_qfl_world = {
            \ 'type': 'mi',
            \ 'query': 'Select entry',
            \ 'pick_last_item': 0,
            \ 'resize_vertical': 0,
            \ 'resize': 20,
            \ 'scratch': '__TRagQFL__',
            \ 'tlib_UseInputListScratch': 'syn match TTagedFilesFilename / \zs.\{-}\ze|\d\+| / | syn match TTagedFilesLNum /|\d\+|/ | hi def link TTagedFilesFilename Directory | hi def link TTagedFilesLNum LineNr',
            \ 'key_handlers': [
                \ {'key':  5, 'agent': 'trag#AgentWithSelected', 'key_name': '<c-e>', 'help': 'Run a command on selected lines'},
                \ {'key':  6, 'agent': 'trag#AgentRefactor',     'key_name': '<c-f>', 'help': 'Run a refactor command'},
                \ {'key': 16, 'agent': 'trag#AgentPreviewQFE',   'key_name': '<c-p>', 'help': 'Preview'},
                \ {'key': 60, 'agent': 'trag#AgentGotoQFE',      'key_name': '<',     'help': 'Jump (don''t close the list)'},
                \ {'key': 19, 'agent': 'trag#AgentSplitBuffer',  'key_name': '<c-s>', 'help': 'Show in split buffer'},
                \ {'key': 20, 'agent': 'trag#AgentTabBuffer',    'key_name': '<c-t>', 'help': 'Show in tab'},
                \ {'key': 22, 'agent': 'trag#AgentVSplitBuffer', 'key_name': '<c-v>', 'help': 'Show in vsplit buffer'},
                \ {'key': "\<c-insert>", 'agent': 'trag#SetFollowCursor', 'key_name': '<c-ins>', 'help': 'Toggle trace cursor'},
            \ ],
            \ 'return_agent': 'trag#AgentEditQFE',
            \ }
                " \ {'key': 23, 'agent': 'trag#AgentOpenBuffer',   'key_name': '<c-w>', 'help': 'View in window'},


" :display: :TRag[!] KIND [REGEXP]
" Run |:TRagsearch| and instantly display the result with |:TRagcw|.
" See |trag#Grep()| for help on the arguments.
" If the kind rx doesn't contain %s (e.g. todo), you can skip the 
" regexp.
"
" Examples: >
"     " Find any matches
"     TRag . foo
" 
"     " Find variable definitions (word on the left-hand): foo = 1
"     TRag l foo
" 
"     " Find variable __or__ function/method definitions
"     TRag d,l foo
" 
"     " Find function calls like: foo(a, b)
"     TRag f foo
"
"     " Find TODO markers
"     TRag todo
command! -nargs=1 -bang -bar TRag TRagsearch<bang> <args> | TRagcw
command! -nargs=1 -bang -bar Trag TRag<bang> <args>


" :display: :TRagfile
" Edit a file registered in your tag files.
command! TRagfile call trag#Edit()
command! Tragfile call trag#Edit()


" :display: :TRagcw
" Display a quick fix list using |tlib#input#ListD()|.
command! -nargs=? TRagcw call trag#QuickList()
command! -nargs=? Tragcw call trag#QuickList()

" :display: :Traglw
" Display a |location-list| using |tlib#input#ListD()|.
command! -nargs=? Traglw call trag#LocList()


" :display: :TRagsearch[!] KIND REGEXP
" Scan the files registered in your tag files for REGEXP. Generate a 
" quickfix list. With [!], append to the given list. The quickfix list 
" can be viewed with commands like |:cw| or |:TRagcw|.
"
" The REGEXP has to match a single line. This uses |readfile()| and the 
" scans the lines. This is an alternative to |:vimgrep|.
" If you choose your identifiers wisely, this should guide you well 
" through your sources.
" See |trag#Grep()| for help on the arguments.
command! -nargs=1 -bang -bar TRagsearch call trag#Grep(<q-args>, empty("<bang>"))
command! -nargs=1 -bang -bar Tragsearch TRagsearch<bang> <args>


" :display: :TRaggrep REGEXP [GLOBPATTERN]
" A 99%-replacement for grep. The glob pattern is optional.
"
" Example: >
"   :TRaggrep foo *.vim
"   :TRaggrep bar
command! -nargs=+ -bang -bar -complete=file TRaggrep
            \ let g:trag_grepargs = ['.', <f-args>]
            \ | call trag#Grep(g:trag_grepargs[0] .' '. g:trag_grepargs[1], empty("<bang>"), split(glob(get(g:trag_grepargs, 2, '')), "\n"))
            \ | unlet g:trag_grepargs
            \ | TRagcw
command! -nargs=+ -bang -bar -complete=file Traggrep TRaggrep<bang> <args>


" :doc:
" The following variables provide alternatives to collecting 
" your project's file list on the basis of you tags files.
"
" These variables are tested in the order as listed here. If the value 
" of a variable is non-empty, this one will be used instead of the other 
" methods.
"
" The tags file is used as a last ressort.

" 1. A list of files. Can be buffer local.
TLet g:trag_files = []

" 2. A glob pattern -- this should be an absolute path and may contain ** 
" (see |glob()| and |wildcards|). Can be buffer local.
TLet g:trag_glob = ''

" 3. Filetype-specific project files.
TLet g:trag_project_ruby = 'Manifest.txt'

" 4. The name of a file containing the projects file list. This file could be 
" generated via make. Can be buffer local.
TLet g:trag_project = ''

" 5. The name of a git repository that includes all files of interest. 
" If the value is "*", trag will search from the current directory 
" (|getcwd()|) upwards for a .git directory.
" If the value is "finddir", use |finddir()| to find a .git directory.
" Can be buffer local.
TLet g:trag_git = ''

" :display: :TRagsetfiles [FILELIST]
" The file list is set only once per buffer. If the list of the project 
" files has changed, you have to run this command on order to reset the 
" per-buffer list.
"
" If no filelist is given, collect the files in your tags files.
"
" Examples: >
"   :TRagsetfiles
"   :TRagsetfiles split(glob('foo*.txt'), '\n')
command! -nargs=? -bar -complete=file TRagsetfiles call trag#SetFiles(<args>)

" :display: :TRagaddfiles FILELIST
" Add more files to the project list.
command! -nargs=1 -bar -complete=file TRagaddfiles call trag#AddFiles(<args>)

" :display: :TRagclearfiles
" Remove any files from the project list.
command! TRagclearfiles call trag#ClearFiles()

" :display: :TRagGitFiles GIT_REPOS
command! -nargs=1 -bar -complete=dir TRagGitFiles call trag#SetGitFiles(<q-args>)


let &cpo = s:save_cpo
unlet s:save_cpo


finish
CHANGES:
0.1
- Initial release

0.2
- Quite a few things have changed and I haven't had the time yet to test 
these changes thorougly. There is a chance that nested patterns thus 
don't work as described (please report).
- Enable search for more than one kinds at once (as comma-separated 
list)
- Enabled <c-e>: Run ex-command on selected lines (e.g. for refactoring 
purposes)
- Enabled <c-s>, <c-v>, <c-t>: Open selected lines in (vertically) split 
windows or tabs.
- Renamed vV kinds to lL (~ let)
- New kind: r/R (right hand side arguemnt of an assignment/let, i.e. 
value)
- New kind: fuzzy (typo-tolerant search)
- INCOMPATIBLE CHANGE: Renamed "mode" to "kind"
- TRag now has some idea of negation. E.g., "TRag !i,w call" will search 
for the word "call" but ignore matches in comments (if defined for the 
    current filetype)
- Alternative methods to define project files: g:trag_files, 
g:trag_glob, g:trag_project.
- Improved support for ruby, vim
- TRagKeyword, trag#CWord(): Customize keyword rx.
- g:trag_get_files
- [bg]:trag_project_{&filetype}: Name of the filetype-specific project 
files catalog (overrides [bg]:trag_project if defined)
- trag#Edit() will now initally select files with the same "basename 
root" (^\w\+) as the current buffer (the command is thus slightly more 
useful and can be used as an ad-hoc alternative file switcher)
- FIX: Match a line only once
- FIX: Caching of regexps

0.3
- Use vimgrep with set ei=all as default search mode (can be configured 
via g:trag_search_mode); by default trag now is a wrapper around vimgrep 
that does the handling of project-related file-sets and regexp builing 
for you.
- FIX: ruby/f regexp

0.4
- trag_proj* variables were renamed to trag_project*.
- Traggrep: Arguments have changed for conformity with grep commands (an 
implicit .-argument is prepended)
- Make sure tlib is loaded even if it is installed in a different 
rtp-directory.
- Post-process lines (strip whitespace) collected by vimgrep
- tlib#Edit(): for list input, set pick_last_item=0, show_empty=1
- Aliases for some commands: Trag, Traggrep ...

0.5
- Update the qfl when running a command on selected lines
- Enable certain operations for multiple choices
- Java, Ruby: x ... find subclasses (extends/implements)
- Experimental rename command for refactoring (general, java)
- NEW: [bg]:trag_get_files_{&filetype}
- Traggrep: If the second argument (glob pattern) is missing, the 
default file list will be used.

0.6
- trag#viki#Rename()
- Generalized trag#rename#Rename()
- Enabled "trace cursor" functionality (mapped to the <c-insert> key).
- :Traglw
- TRagGitFiles, trag#SetGitFiles(), g:trag_git

0.7
- trag#QuickList(): Accept a dict as optional argument.
- trag#Grep(): rx defaults to '\.{-}'
- trag#Grep(): use :g (instead of search()) for non-vimgrep mode

