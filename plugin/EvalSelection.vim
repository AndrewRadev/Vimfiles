" EvalSelection.vim -- evaluate selected vim/ruby/... code
" @Author:      Thomas Link (samul AT web.de)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     29-Jän-2004.
" @Last Change: 2007-06-08.
" @Revision:    0.16.850
" 
" vimscript #889
" 
" TODO:
" - find & fix compilation errors
" - fix interaction errors
"

""" Basic Functionality {{{1

if &cp || exists("s:loaded_evalselection") "{{{2
    finish
endif
let s:loaded_evalselection = 16

" Parameters {{{2
if !exists("g:evalSelectionLeader")         | let g:evalSelectionLeader         = '<Leader>e' | endif "{{{2
if !exists("g:evalSelectionRegisterLeader") | let g:evalSelectionRegisterLeader = '<Leader>E' | endif "{{{2
if !exists("g:evalSelectionAutoLeader")     | let g:evalSelectionAutoLeader     = '<Leader>x' | endif "{{{2
if !exists("g:evelSelectionEvalExpression") | let g:evelSelectionEvalExpression = '<LocalLeader>r' | endif "{{{2

if !exists("g:evalSelectionLogCommands")  | let g:evalSelectionLogCommands = 1  | endif "{{{2
if !exists("g:evalSelectionLogTime")      | let g:evalSelectionLogTime = 0      | endif "{{{2
if !exists("g:evalSelectionSeparatedLog") | let g:evalSelectionSeparatedLog = 1 | endif "{{{2
" if !exists("g:evalSelectionDebugLog")     | let g:evalSelectionDebugLog = 1     | endif
if !exists("g:evalSelectionDebugLog")     | let g:evalSelectionDebugLog = 0     | endif "{{{2
if !exists("g:evalSelectionSaveLog")      | let g:evalSelectionSaveLog = ""     | endif "{{{2
if !exists("g:evalSelectionSaveLog_r") "{{{2
    let g:evalSelectionSaveLog_r = "EvalSelection_r.log"
endif

autocmd BufRead EvalSelection_*.log setf EvalSelectionLog

if !exists("g:evalSelectionMenuSize")     | let g:evalSelectionMenuSize = &lines | endif "{{{2
if !exists("g:evalSelectionPluginMenu") "{{{2
    let g:evalSelectionPluginMenu = "Plugin.EvalSelection."
endif

if !exists("g:evalSelectionPager") "{{{2
    let g:evalSelectionPager = "gvim --servername GVIMPAGER --remote-silent"
endif

if !exists("g:evalSelection_SPSS_DraftOutput") "{{{2
    let g:evalSelection_SPSS_DraftOutput = 0
endif

let s:evalSelLogBufNr  = -1
let s:evalSelModes     = "xeparl"
let g:evalSelLastCmd   = ""
let g:evalSelLastCmdId = ""


" Main functions {{{2
" EvalSelection(id, proc, cmd, ?pre, ?post, ?newsep, ?recsep, ?postprocess)
fun! EvalSelection(id, proc, cmd, ...) "{{{3
    let pre     = a:0 >= 1 ? a:1 : ""
    let post    = a:0 >= 2 ? a:2 : ""
    let newsep  = a:0 >= 3 ? a:3 : "\n"
    let recsep  = a:0 >= 4 ? (a:4 == ""? "\n" : a:4) : "\n"
    let process = a:0 >= 5 ? a:4 : ""
    let e = substitute(@e, '\('. recsep .'\)\+$', "", "g")
    if newsep != "" && newsep != recsep
        let e = substitute(e, recsep, newsep, "g")
    endif
    if exists("g:evalSelectionPRE".a:id)
        exe "let pre = g:evalSelectionPRE".a:id.".'".newsep.pre."'"
    endif
    if exists("g:evalSelectionPOST".a:id)
        exe "let post = g:evalSelectionPOST".a:id.".'".newsep.post."'"
    endif
    let e = pre .e. post
    " echomsg "DBG: ". a:cmd ." ". e
    redir @e
    " exe a:cmd ." ". e
    " echom "DBG ". a:cmd ." ". e
    silent exec a:cmd ." ". e
    redir END
    let @e = substitute(@e, "\<c-j>$", "", "")
    if @e != ""
        if process != ""
            exec "let @e = ". escape(process, '"\')
        endif
        if a:proc != ""
            let g:evalSelLastCmdId = a:id
            exe a:proc . ' "' . escape(strpart(@e, 1), '"\') . '"'
        endif
    endif
endf

fun! EvalSelectionSystem(txt) "{{{3
    let rv=system(a:txt)
    return substitute(rv, "\n\\+$", "", "")
endf

fun! EvalSelectionEcho(txt, ...)
    " echo "\r"
    redraw
    exec "echo ". a:txt
endf

command! -nargs=* EvalSelectionEcho call EvalSelectionEcho(<q-args>)

fun! <SID>EvalSelectionLogAppend(txt, ...) "{{{3
    " If we search for ^@ right away, we will get a *corrupted* viminfo-file 
    " -- at least with the version of vim, I use.
    call append(0, substitute(a:txt, "\<c-j>", "\<c-m>", "g"))
    exe "1,.s/\<c-m>/\<cr>/ge"
endf

fun! EvalSelectionLog(txt, ...) "{{{3
    let currWin = winnr()
    let dbg     = a:0 >= 1 ? a:1 : 0
    exe "let txt = ".a:txt
    if g:evalSelectionSeparatedLog
        let logID = g:evalSelLastCmdId
    else
        let logID = ""
    endif
    
    let logfile = exists("g:evalSelectionSaveLog_". logID) ? 
                \ g:evalSelectionSaveLog_{logID} : g:evalSelectionSaveLog

    "Adapted from Yegappan Lakshmanan's scratch.vim
    if !exists("s:evalSelLog{logID}_BufNr") || 
                \ s:evalSelLog{logID}_BufNr == -1 || 
                \ bufnr(s:evalSelLog{logID}_BufNr) == -1
        if logfile != ""
            exec "edit ". logfile
            exec "saveas ". escape(logfile, '\')
        else
            if logID == ""
                split _EvalSelectionLog_
            else
                exec "split _EvalSelection_".logID."_"
            endif
            setlocal buftype=nofile
            setlocal bufhidden=hide
            setlocal noswapfile
        endif
        let s:evalSelLog{logID}_BufNr = bufnr("%")
    else
        let bwn = bufwinnr(s:evalSelLog{logID}_BufNr)
        if bwn > -1
            exe bwn . "wincmd w"
        else
            exe "sbuffer ".s:evalSelLog{logID}_BufNr
        endif
    endif

    " if logfile != ""
    "     setlocal buftype=nofile
    "     " setlocal bufhidden=delete
    "     setlocal bufhidden=hide
    "     setlocal noswapfile
    "     " setlocal buflisted
    " endif
    setlocal ft=EvalSelectionLog

    if dbg
        let @d = txt
        exe 'norm! $"dp'
    else
        call <SID>EvalSelectionLogAppend("")
        go 1
        if g:evalSelectionLogCommands && g:evalSelLastCmd != ""
            let evalSelLastCmd = "|| ". substitute(g:evalSelLastCmd, '\n\ze.', '|| ', 'g')
            if evalSelLastCmd =~ "\n$"
                " let sep = "=> "
                let sep = ""
            else
                " let sep = "\n=> "
                let sep = "\n"
            endif
            call <SID>EvalSelectionLogAppend(evalSelLastCmd . sep . txt, 1)
        else
            call <SID>EvalSelectionLogAppend(txt, 1)
        endif
        if g:evalSelectionLogTime
            let t = "|| -----".strftime("%c")."-----"
            if !g:evalSelectionSeparatedLog
                let t = t. g:evalSelLastCmdId
            endif
            call <SID>EvalSelectionLogAppend(t)
        endif
        go 1
        let g:evalSelLastCmd   = ""
        let g:evalSelLastCmdId = ""
        redraw!
    endif
    exe currWin . "wincmd w"
endf
command! -nargs=* EvalSelectionLog call EvalSelectionLog(<q-args>)

fun! EvalSelectionCmdLine(lang) "{{{3
    let lang = tolower(a:lang)
    while 1
        let @e = input(a:lang." (exit with ^D+Enter):\n")
        if @e == ""
            break
        elseif @e == ""
            let g:evalSelLastCmdId = lang
            call EvalSelectionLog("''")
        else
            let g:evalSelLastCmd = substitute(@e, "\n$", "", "")
            call EvalSelection_{lang}("EvalSelectionLog")
        endif
    endwh
    echo
endf
command! -nargs=1 EvalSelectionCmdLine call EvalSelectionCmdLine(<q-args>)


fun! EvalSelectionGenerateBindingsHelper(mapmode, mapleader, lang, modes, eyank, edelete) "{{{3
    let es   = "call EvalSelection_". a:lang
    let eslc = ':let g:evalSelLastCmd = substitute(@e, "\n$", "", "")<CR>'
    if a:modes =~# "x"
        exe a:mapmode .'noremap <silent> '. a:mapleader ."x ".
                    \ a:eyank . eslc.':'.es.'("")<CR>'
    endif
    if a:modes =~# "e"
        exe a:mapmode .'noremap <silent> '. a:mapleader ."e ".
                    \ a:eyank . eslc.':silent '.es.'("")<CR>'
    endif
    if a:modes =~# "p"
        exe a:mapmode .'noremap <silent> '. a:mapleader ."p ".
                    \ a:eyank . eslc.':'.es.'("echomsg")<CR>'
    endif
    if a:modes =~# "a"
        exe a:mapmode .'noremap <silent> '. a:mapleader ."a ".
                    \ a:eyank .' `>'.eslc.':silent '.es. "('exe \"norm! a\".')<CR>"
    endif
    if a:modes =~# "r"
        exe a:mapmode .'noremap <silent> '. a:mapleader ."r ".
                    \ a:edelete .eslc.':silent '.es. "('exe \"norm! i\".')<CR>"
    endif
    if a:modes =~# "l"
        exe a:mapmode .'noremap <silent> '. a:mapleader ."l ".
                    \ a:eyank . eslc.':silent '.es. "('EvalSelectionLog')<CR>"
    endif
endf

fun! EvalSelectionGenerateBindings(shortcut, lang, ...) "{{{3
    let modes = a:0 >= 1 ? a:1 : s:evalSelModes
    call EvalSelectionGenerateBindingsHelper("v", g:evalSelectionLeader . a:shortcut, a:lang, modes,
                \ '"ey', '"ed')
    call EvalSelectionGenerateBindingsHelper("", g:evalSelectionRegisterLeader . a:shortcut, a:lang, modes,
                \ "", "")
endf
call EvalSelectionGenerateBindingsHelper("v", g:evalSelectionAutoLeader, "{&ft}", s:evalSelModes,
                \ '"ey', '"ed')

" EvalSelectionParagraphMappings(log, ?select=vip)
fun! EvalSelectionParagraphMappings(log, ...) "{{{3
    let select = a:0 >= 1 ? a:1 : "vip"
    let op = a:log ? "l" : "x"
    exec "nmap <buffer> ". g:evelSelectionEvalExpression ." ". select . g:evalSelectionAutoLeader . op
    exec "vmap <buffer> ". g:evelSelectionEvalExpression ." ". g:evalSelectionAutoLeader . op
endf

fun! EvalSelection_vim(cmd) "{{{3
    let @e = substitute("\n". @e ."\n", '\n\s*".\{-}\ze\n', "", "g")
    " let @e = substitute(@e, "^\\(\n*\\s\\+\\)\\+\\|\\(\\s\\+\n*\\)\\+$", "", "g")
    let @e = substitute(@e, "\n\\s\\+\\\\", " ", "g")
    " let @e = substitute(@e, "\n\\s\\+", "\n", "g")
    call EvalSelection("vim", a:cmd, "normal", ":", "\n", "\n:")
    " call EvalSelection("vim", a:cmd, "")
endf
if !hasmapto("EvalSelection_vim(") "{{{2
    call EvalSelectionGenerateBindings("v", "vim")
endif

if has("ruby") "{{{2
    if !exists("*EvalSelectionCalculate")
        fun! EvalSelectionCalculate(formula) "{{{3
            exec "ruby p ". a:formula
        endf
    endif
    fun! EvalSelection_ruby(cmd) "{{{3
        let @e = substitute(@e, '\_^#.*\_$', "", "g")
        call EvalSelection("ruby", a:cmd, "ruby")
    endf
    if !hasmapto("EvalSelection_ruby(")
        call EvalSelectionGenerateBindings("r", "ruby")
    endif
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."Ruby:\\ Command\\ Line :EvalSelectionCmdLine ruby<cr>"
    end
    command! EvalSelectionCmdLineRuby :EvalSelectionCmdLine ruby
endif

if has("python") "{{{2
    if !exists("*EvalSelectionCalculate")
        fun! EvalSelectionCalculate(formula) "{{{3
            exec "python print ". a:formula
        endf
    endif
    fun! EvalSelection_python(cmd) "{{{3
        call EvalSelection("python", a:cmd, "python")
    endf
    if !hasmapto("EvalSelection_python(")
        call EvalSelectionGenerateBindings("y", "python")
    endif
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."Python:\\ Command\\ Line :EvalSelectionCmdLine python<cr>"
    end
    command! EvalSelectionCmdLinePython :EvalSelectionCmdLine python
endif

if has("perl") "{{{2
    if !exists("*EvalSelectionCalculate")
        fun! EvalSelectionCalculate(formula) "{{{3
            exec "perl VIM::Msg(". a:formula .")"
        endf
    endif
    fun! EvalSelection_perl(cmd) "{{{3
        call EvalSelection("perl", a:cmd, "perl")
    endf
    if !hasmapto("EvalSelection_perl(")
        call EvalSelectionGenerateBindings("p", "perl")
    endif
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."Perl:\\ Command\\ Line :EvalSelectionCmdLine perl<cr>"
    end
    command! EvalSelectionCmdLinePerl :EvalSelectionCmdLine perl
endif

if has("tcl") "{{{2
    if !exists("*EvalSelectionCalculate")
        fun! EvalSelectionCalculate(formula) "{{{3
            call EvalSelection_mz_helper("puts [expr ". a:formula ."]")
        endf
    endif
    fun! EvalSelection_tcl(cmd) "{{{3
        call EvalSelection("tcl", a:cmd, "call", "EvalSelection_tcl_helper('", "')")
    endf
    fun! EvalSelection_tcl_helper(text) "{{{3
        redir @e
        exe "tcl ". a:text
        redir END
        let @e = substitute(@e, '\^M$', '', '')
    endf
    if !hasmapto("EvalSelection_tcl(")
        call EvalSelectionGenerateBindings("t", "tcl")
    endif
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."TCL:\\ Command\\ Line :EvalSelectionCmdLine tcl<cr>"
    end
    command! EvalSelectionCmdLineTcl :EvalSelectionCmdLine tcl
endif

if has("mzscheme") "{{{2
    if !exists("*EvalSelectionCalculate")
        fun! EvalSelectionCalculate(formula) "{{{3
            call EvalSelection_mz_helper("(display (". a:formula ."))")
        endf
    endif
    fun! EvalSelection_mz(cmd) "{{{3
        call EvalSelection("mz", a:cmd, "call", "EvalSelection_mz_helper('", "')")
    endf
    fun! EvalSelection_mz_helper(text) "{{{3
        redir @e
        exe "mz ". a:text
        redir END
        let @e = substitute(@e, '\^M$', '', '')
    endf
    if !hasmapto("EvalSelection_mzscheme(")
        call EvalSelectionGenerateBindings("z", "mz")
    endif
    if g:evalSelectionPluginMenu != ''
        exec 'amenu '. g:evalSelectionPluginMenu .'MzScheme:\ Command\ Line :EvalSelectionCmdLine mz<cr>'
    end
    command! EvalSelectionCmdLineMz :EvalSelectionCmdLine mz
endif

fun! EvalSelection_sh(cmd) "{{{3
    let @e = substitute(@e, '\_^#.*\_$', "", "g")
    let @e = substitute(@e, "\\_^\\s*\\|\\s*\\_$\\|\n$", "", "g")
    let @e = substitute(@e, "\n\\+", "; ", "g")
    call EvalSelection("sh", a:cmd, "", "echo EvalSelectionSystem('", "')", "; ")
endf
if !hasmapto("EvalSelection_sh(") "{{{2
    call EvalSelectionGenerateBindings("s", "sh")
endif
if g:evalSelectionPluginMenu != ""
    exec "amenu ". g:evalSelectionPluginMenu ."Shell:\\ Command\\ Line :EvalSelectionCmdLine sh<cr>"
end
command! EvalSelectionCmdLineSh :EvalSelectionCmdLine sh


" Use vim as a fallback for performing calculations
if !exists("*EvalSelectionCalculate") "{{{2
    fun! EvalSelectionCalculate(formula) "{{{3
        exec "echo ". a:formula
    endf    
endif

fun! EvalSelection_calculate(cmd) "{{{3
    if @e =~ '\s*=\s*$'
        let @e = substitute(@e, '\s*=\s*$', '', '')
    endif
    call EvalSelection("calculate", a:cmd, "", "call EvalSelectionCalculate('", "')")
endf
if !hasmapto("EvalSelection_calculate(") "{{{2
    call EvalSelectionGenerateBindings("e", "calculate")
endif
if g:evalSelectionPluginMenu != ""
    exec "amenu ". g:evalSelectionPluginMenu ."Calculator:\\ Command\\ Line :EvalSelectionCmdLine calculate<cr>"
    exec "amenu ". g:evalSelectionPluginMenu ."--SepEvalSelectionMenu-- :"
end
command! EvalSelectionCmdLineCalculator :EvalSelectionCmdLine calculate



""" Interaction with an interpreter {{{1

if !has("ruby") "{{{2
    finish
endif

let s:windows = has("win32") || has("win64") || has("win16")

""" Parameters {{{1
if !exists("g:evalSelectionRubyDir") "{{{2
    let g:evalSelectionRubyDir = ""
    " if s:windows
    "     if exists('$HOME')
    "         let g:evalSelectionRubyDir = $HOME."/vimfiles/ruby/"
    "     else
    "         let g:evalSelectionRubyDir = $VIM."/vimfiles/ruby/"
    "     endif
    " else
    "     let g:evalSelectionRubyDir = "~/.vim/ruby/"
    " endif
endif


""" Code {{{1

command! -nargs=1 EvalSelectionQuit ruby EvalSelection.tear_down(<q-args>)

fun! EvalSelectionCompleteCurrentWord(...) "{{{3
    if a:0 >= 1 && a:1 != ""
        " call EvalSelectionCompleteCurrentWordInsert(a:1, 0)
        exec "norm! a". a:1
    elseif has("menu")
        let e = @e
        try
            norm! viw"ey
            if exists("*EvalSelectionCompleteCurrentWord_". &filetype)
                try
                    aunmenu PopUp.EvalSelection
                catch
                endtry
                call EvalSelectionCompleteCurrentWord_{&filetype}(@e)
                popup PopUp.EvalSelection
            else
                echom "Unknown filetype"
            end
        finally
            let @e = e
        endtry
    else
        echom "No +menu support. Please use :EvalSelectionCompleteCurrentWord from the command line."
    endif
endf

fun! EvalSelectionCompleteCurrentWordInsert(word, remove_menu) "{{{3
    exec "norm! viwda". a:word
    if has("menu") && a:remove_menu
        aunmenu PopUp.EvalSelection
    endif
endf

command! -nargs=? -complete=custom,EvalSelectionGetWordCompletions 
            \ EvalSelectionCompleteCurrentWord call EvalSelectionCompleteCurrentWord(<q-args>)

if has("menu") "{{{2
    amenu PopUp.--SepEvalSelection-- :
    amenu PopUp.Complete\ Word :EvalSelectionCompleteCurrentWord<cr>
endif

fun! EvalSelectionGetWordCompletions(ArgLead, CmdLine, CursorPos) "{{{3
    if exists("*EvalSelectionGetWordCompletions_". &filetype)
        return EvalSelectionGetWordCompletions_{&filetype}(a:ArgLead, a:CmdLine, a:CursorPos)
    else
        return a:ArgLead
    endif
endf

fun! EvalSelectionTalk(id, body) "{{{3
    " let id   = escape(a:id, '"\')
    " let body = escape(a:body, '"\')
    let id   = escape(a:id, '\')
    let body = escape(a:body, '\')
    ruby EvalSelection.talk(VIM::evaluate("id"), VIM::evaluate("body"))
endf

try
    if empty(g:evalSelectionRubyDir)
        exec "rubyfile ". findfile('ruby/EvalSelection.rb', &rtp)
    else
        exec "rubyfile ".g:evalSelectionRubyDir."EvalSelection.rb"
    endif
catch /EvalSelection.rb/
    echom 'Please redefine g:evalSelectionRubyDir: '. g:evalSelectionRubyDir
endtry

autocmd VimLeave * ruby EvalSelection.tear_down_all


"Lisp
if exists("g:evalSelectionLispInterpreter") "{{{2
    if g:evalSelectionLispInterpreter ==? "CLisp"
        if !exists("g:evalSelectionLispCmdLine")
            let g:evalSelectionLispCmdLine = 'clisp --quiet'
        endif
    
        ruby << EOR
        class EvalSelectionLisp < EvalSelectionInterpreter
            def setup
                @iid            = VIM::evaluate("g:evalSelectionLispInterpreter")
                @interpreter    = VIM::evaluate("g:evalSelectionLispCmdLine")
                @printFn        = ":q(let ((rv (list (ignore-errors %{BODY})))) (if (= (length rv) 1) (car rv) rv))"
                @quitFn         = "(quit)"
                @recPromptRx    = "\n(Break \\d\\+ )?\\[\\d+\\]\\> "
                @recSkip        = 1
                @useNthRec      = 1
            end

            def postprocess(text)
                text.sub(/^\n/, "")
            end
        end
EOR
    endif

    fun! EvalSelection_lisp(cmd) "{{{3
        let @e = escape(@e, '\"')
        call EvalSelection("lisp", a:cmd, "",  
                    \ 'call EvalSelectionTalk(g:evalSelectionLispInterpreter, "', '")')
    endf
    
    if !hasmapto("EvalSelection_lisp(")
        call EvalSelectionGenerateBindings("l", "lisp")
    endif
    
    command! EvalSelectionSetupLisp ruby EvalSelection.setup(VIM::evaluate("g:evalSelectionLispInterpreter"), EvalSelectionLisp)
    command! EvalSelectionQuitLisp  ruby EvalSelection.tear_down(VIM::evaluate("g:evalSelectionLispInterpreter"))
    command! EvalSelectionCmdLineLisp call EvalSelectionCmdLine("lisp")
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."Lisp.Setup :EvalSelectionSetupLisp<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."Lisp.Command\\ Line :EvalSelectionCmdLineLisp<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."Lisp.Quit  :EvalSelectionQuitLisp<cr>"
    end
endif


" OCaml
if exists("g:evalSelectionOCamlInterpreter") "{{{2
    if !exists("g:evalSelectionOCamlCmdLine")
        let g:evalSelectionOCamlCmdLine = 'ocaml'
    endif

    fun! EvalSelection_ocaml(cmd) "{{{3
        let @e = escape(@e, '\"')
        call EvalSelection("ocaml", a:cmd, "",  
                    \ 'call EvalSelectionTalk(g:evalSelectionOCamlInterpreter, "', '")')
    endf
    if !hasmapto("EvalSelection_ocaml(")
        call EvalSelectionGenerateBindings("o", "ocaml")
    endif

    command! EvalSelectionSetupOCaml   ruby EvalSelection.setup("OCaml", EvalSelectionOCaml)
    command! EvalSelectionQuitOCaml    ruby EvalSelection.tear_down("OCaml")
    command! EvalSelectionCmdLineOCaml call EvalSelectionCmdLine("ocaml")
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."OCaml.Setup :EvalSelectionSetupOCaml<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."OCaml.Command\\ Line :EvalSelectionCmdLineOCaml<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."OCaml.Quit  :EvalSelectionQuitOCaml<cr>"
    end

    ruby << EOR
    class EvalSelectionOCaml < EvalSelectionInterpreter
        def setup
            @iid            = "OCaml"
            @interpreter    = VIM::evaluate("g:evalSelectionOCamlCmdLine")
            @printFn        = "%{BODY}"
            @quitFn         = "exit 0;;"
            @bannerEndRx    = "\n"
            @markFn         = "\n745287134.536216736;;"
            @recMarkRx      = "\n# - : float = 745287134\\.536216736"
            @recPromptRx    = "\n# "
        end
        
        if VIM::evaluate("g:evalSelectionOCamlInterpreter") == "OCamlClean"
            def postprocess(text)
                text.sub(/^\s*- : .+? = /, "")
            end
        end
    end
EOR
endif


" Php
if exists("g:evalSelectionPhpInterpreter") "{{{2
    if !exists("g:evalSelectionPhpCmdLine")
        let g:evalSelectionPhpCmdLine = 'php -a'
    endif

    ruby << EOR
    class EvalSelectionPhp < EvalSelectionInterpreter
        def setup
            @iid            = VIM::evaluate("g:evalSelectionPhpInterpreter")
            @interpreter    = VIM::evaluate("g:evalSelectionPhpCmdLine")
            @printFn        = "<?php %{BODY} ?>\n"
            @bannerEndRx    = "Interactive mode enabled";
            @quitFn         = "<?php exit; ?>\n"
            @markFn         = "<?php echo '745287134.5362\\n'; ?>\n"
            @recMarkRx      = "745287134.5362\n"
            @recPromptRx    = ""
        end
    end
EOR

    fun! EvalSelection_php(cmd) "{{{3
        let @e = escape(@e, '\"')
        call EvalSelection("php", a:cmd, "",  
                    \ 'call EvalSelectionTalk(g:evalSelectionPhpInterpreter, "', '")')
    endf
    
    if !hasmapto("EvalSelection_php(")
        call EvalSelectionGenerateBindings("P", "php")
    endif
    
    command! EvalSelectionSetupPhp ruby EvalSelection.setup(VIM::evaluate("g:evalSelectionPhpInterpreter"), EvalSelectionPhp)
    command! EvalSelectionQuitPhp  ruby EvalSelection.tear_down(VIM::evaluate("g:evalSelectionPhpInterpreter"))
    command! EvalSelectionCmdLinePhp call EvalSelectionCmdLine("php")
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."Php.Setup :EvalSelectionSetupPhp<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."Php.Command\\ Line :EvalSelectionCmdLinePhp<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."Php.Quit  :EvalSelectionQuitPhp<cr>"
    end
endif


" R
if exists("g:evalSelectionRInterpreter") "{{{2
    if !exists("g:evalSelectionRCmdLine")
        if s:windows
            let g:evalSelectionRCmdLine = 'Rterm.exe --no-save --vanilla --ess'
        else
            let g:evalSelectionRCmdLine = 'R --no-save --vanilla --ess'
        endif
    endif

    command! EvalSelectionSetupR   ruby EvalSelection.setup("R", EvalSelectionR)
    command! EvalSelectionQuitR    ruby EvalSelection.tear_down("R")
    command! EvalSelectionCmdLineR call EvalSelectionCmdLine("r")
    autocmd FileType r call EvalSelectionParagraphMappings(1)
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."R.Setup :EvalSelectionSetupR<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."R.Command\\ Line :EvalSelectionCmdLineR<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."R.Quit  :EvalSelectionQuitR<cr>"
    end

    fun! EvalSelection_r(cmd) "{{{3
        let @e = escape(@e, '\"')
        call EvalSelection("r", a:cmd, "", 'call EvalSelectionTalk("R", "', '")')
    endf

    if !hasmapto("EvalSelection_r(")
        call EvalSelectionGenerateBindings("R", "r")
    endif

    ruby <<EOR
    def escape_menu(text)
        text.gsub(/([-. &|\\"])/, "\\\\\\1")
        # text.gsub(/(\W)/, "\\\\\\1")
    end
EOR

    fun! EvalSelectionGetWordCompletions_r(ArgLead, CmdLine, CursorPos) "{{{3
        let ls = ""
        ruby <<EOR
        i = $EvalSelectionTalkers["R"]
        if i and i.respond_to?(:complete_word)
            ls = i.complete_word(VIM::evaluate("a:ArgLead"))
            if ls
                ls = ls.join("\n")
                ls.gsub(/"/, '\\\\"')
                VIM::command(%{let ls="#{ls}"})
            end
        end
EOR
        return ls
    endf

    fun! EvalSelectionCompleteCurrentWord_r(bit) "{{{3
        ruby <<EOR
        i = $EvalSelectionTalkers["R"]
        if i
            if i.respond_to?(:complete_word)
                ls = i.complete_word(VIM::evaluate("a:bit"))
                if ls
                    i.build_vim_menu("PopUp.EvalSelection", ls, 
                                   lambda {|x| %{:call EvalSelectionCompleteCurrentWordInsert("#{x}", 1)<CR>}},
                                   :extra => true)
                end
            else
                VIM::command(%Q{echoerr "EvalSelection: Wrong or incapable interpreter!"})
            end
        else
            VIM::command(%Q{echoerr "EvalSelection CCW: Set up interaction with R first!"})
        end
EOR
    endf
       
    ruby <<EOR
    module EvalSelectionRExtra
        if VIM::evaluate("g:evalSelectionRInterpreter") =~ /Clean$/
            def postprocess(text)
                text.sub(/^.*?\n([>+] .*?\n)*(\[\d\] )?/m, "")
            end
        else
            def postprocess(text)
                text.sub(/^.*?\n([>+] .*?\n)*/m, '')
            end
        end
    end
EOR
    if g:evalSelectionRInterpreter =~ '^RDCOM' && s:windows
        ruby << EOR
        require 'win32ole'
        require 'tmpdir'
        class EvalSelectionAbstractR < EvalSelectionOLE
            def setup
                @iid         = "R"
                @interpreter = "rdcom"
            end

            def build_menu(initial)
                ls = @ole_server.Evaluate(%{ls()})
                if ls
                    build_vim_menu("R", ls, 
                                   lambda {|x| %{a#{x}}}, 
                                   :exit   => %{:EvalSelectionQuitR<CR>},
                                   :update => %{:ruby EvalSelection.update_menu("R")<CR>},
                                   :remove_menu => %{:ruby EvalSelection.remove_menu("R")<cr>}
                                  )
                end
            end

            def complete_word(bit)
                bit = nil if bit == "\n"
                @ole_server.Evaluate(%{apropos("^#{Regexp.escape(bit) if bit}")})
            end

            def ole_tear_down
                begin
                    @ole_server.EvaluateNoReturn(%{q()})
                rescue
                end
                begin
                    @ole_server.Close
                rescue
                end
                return true
            end
            
            def clean_result(text)
                text.sub(/^\s*\[\d+\]\s*/, '')
            end

            if VIM::evaluate("g:evalSelectionRInterpreter") =~ /Clean$/
                def postprocess(result)
                    case result
                    when Array
                        result.collect {|l| clean_result(l)}
                    when String
                        clean_result(result)
                    else
                        result
                    end
                end
            end
        end
EOR
        if g:evalSelectionRInterpreter =~ 'Commander'
            ruby << EOR
            class EvalSelectionR < EvalSelectionAbstractR
                def ole_setup
                    @ole_server = WIN32OLE.new("StatConnectorSrv.StatConnector")
                    @ole_server.Init("R")
                    @ole_server.EvaluateNoReturn(%{options(chmhelp=TRUE)})
                    @ole_server.EvaluateNoReturn(%{library(Rcmdr)})
                end
                
                def ole_evaluate(text)
                    text.gsub!(/"/, '\\\\"')
                    text.gsub!(/\\/, '\\\\\\\\')
                    @ole_server.Evaluate(%{capture.output(doItAndPrint("#{text}"))})
                end
            end
EOR
        else
            ruby << EOR
            class EvalSelectionR < EvalSelectionAbstractR
                def ole_setup
                    @ole_server = WIN32OLE.new("StatConnectorSrv.StatConnector")
                    @ole_server.Init("R")
                    if VIM::evaluate("has('gui')")
                        @ole_server.EvaluateNoReturn(%{options(chmhelp=TRUE)})
                        @ole_server.EvaluateNoReturn(%{EvalSelectionPager <- function(f, hd, ti, del) {
    system(paste("cmd /c start #{VIM::evaluate("g:evalSelectionPager")} ", gsub(" ", "\\\\ ", f)))
    if (del) {
        Sys.sleep(5)
        unlink(f)
    }
}})
                        @ole_server.EvaluateNoReturn(%{options(pager=EvalSelectionPager)})
                        @ole_server.EvaluateNoReturn(%{options(show.error.messages=TRUE)})
                    end
                    d = VIM::evaluate(%{expand("%:p:h")})
                    d.gsub!(/\\/, "/")
                    @ole_server.EvaluateNoReturn(%{setwd("#{d}")})
                    rdata = File.join(d, ".Rdata")
                    if File.exist?(rdata)
                        @ole_server.EvaluateNoReturn(%{sys.load.image("#{rdata}", TRUE)})
                    end
                end
                
                def ole_evaluate(text)
                    @ole_server.EvaluateNoReturn(%{evalSelection.out <- textConnection("evalSelection.log", "w")})
                    @ole_server.EvaluateNoReturn(%{sink(evalSelection.out)})
                    @ole_server.EvaluateNoReturn(%{print(tryCatch({#{text}}, error=function(e) e))})
                    @ole_server.EvaluateNoReturn(%{sink()})
                    @ole_server.EvaluateNoReturn(%{close(evalSelection.out)})
                    @ole_server.EvaluateNoReturn(%{rm(evalSelection.out)})
                    @ole_server.Evaluate(%{if (is.character(evalSelection.log) & length(evalSelection.log) == 0) NULL else evalSelection.log})
                end
            end
EOR
        endif
    elseif g:evalSelectionRInterpreter =~ '^RFO'
        ruby << EOR
        require "tmpdir"
        class EvalSelectionR < EvalSelectionStdInFileOut
            include EvalSelectionRExtra
            def setup
                @iid            = "R"
                @interpreter    = VIM::evaluate("g:evalSelectionRCmdLine")
                @outfile        = File.join(Dir.tmpdir, "EvalSelection.Rout")
                @printFn        = <<EOFN
sink('#@outfile');
%{BODY};
sink();
EOFN
                @quitFn         = "q()"
            end
        end
EOR
    else
        ruby << EOR
        class EvalSelectionR < EvalSelectionInterpreter
            include EvalSelectionRExtra
            def setup
                @iid            = "R"
                @interpreter    = VIM::evaluate("g:evalSelectionRCmdLine")
                @printFn        = "%{BODY}"
                @quitFn         = "q()"
                @bannerEndRx    = "\n"
                @markFn         = "\nc(31983689, 32682634, 23682638)" 
                @recMarkRx      = "\n?\\> \\[1\\] 31983689 32682634 23682638"
                @recPromptRx    = "\n\\> "
            end
            
        end
EOR
    endif

endif


if exists("g:evalSelectionSchemeInterpreter") "{{{2
    if g:evalSelectionSchemeInterpreter ==? 'Gauche'
        if !exists("g:evalSelectionSchemeCmdLine")
            let s:evalSelectionSchemeCmdLine = 'gosh'
        endif
        let s:evalSelectionSchemePrint = '(display (begin %{BODY})) (display #\escape) (flush)'
    elseif g:evalSelectionSchemeInterpreter ==? 'Chicken'
        if !exists("g:evalSelectionSchemeCmdLine")
            let g:evalSelectionSchemeCmdLine = 'csi -quiet'
        endif
        let s:evalSelectionSchemePrint = 
                    \ '(display (begin %{BODY})) (display (integer->char 27)) (flush-output)'
    endif

    fun! EvalSelection_scheme(cmd) "{{{3
        let @e = escape(@e, '\"')
        call EvalSelection("scheme", a:cmd, "", 
                    \ 'call EvalSelectionTalk(g:evalSelectionSchemeInterpreter, "', '")')
    endf
    
    if !hasmapto("EvalSelection_scheme(")
        call EvalSelectionGenerateBindings("c", "scheme")
    endif

    command! EvalSelectionSetupScheme   ruby EvalSelection.setup(VIM::evaluate("g:evalSelectionSchemeInterpreter"), EvalSelectionScheme)
    command! EvalSelectionQuitScheme    ruby EvalSelection.tear_down(VIM::evaluate("g:evalSelectionSchemeInterpreter"))
    command! EvalSelectionCmdLineScheme call EvalSelectionCmdLine("scheme")
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."Scheme.Setup :EvalSelectionSetupScheme<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."Scheme.Command\\ Line :EvalSelectionCmdLineScheme<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."Scheme.Quit  :EvalSelectionQuitScheme<cr>"
    end

    ruby << EOR
    class EvalSelectionScheme < EvalSelectionInterpreter
        def setup
            @iid            = VIM::evaluate("g:evalSelectionSchemeInterpreter")
            @interpreter    = VIM::evaluate("g:evalSelectionSchemeCmdLine")
            @printFn        = VIM::evaluate("s:evalSelectionSchemePrint")
            @quitFn         = "(exit)"
            @recEndChar     = 27
        end
    end
EOR
endif


if exists("g:evalSelectionSpssInterpreter") "{{{2
    command! EvalSelectionSetupSPSS   ruby EvalSelection.setup("SPSS", EvalSelectionSPSS)
    command! EvalSelectionQuitSPSS    ruby EvalSelection.tear_down("SPSS")
    command! EvalSelectionCmdLineSPSS call EvalSelectionCmdLine("sps")
    autocmd FileType sps call EvalSelectionParagraphMappings(0, "$(v)")
    if g:evalSelectionPluginMenu != ""
        exec "amenu ". g:evalSelectionPluginMenu ."SPSS.Setup :EvalSelectionSetupSPSS<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."SPSS.Command\\ Line :EvalSelectionCmdLineSPSS<cr>"
        exec "amenu ". g:evalSelectionPluginMenu ."SPSS.Quit  :EvalSelectionQuitSPSS<cr>"
    end

    fun! EvalSelection_sps(cmd) "{{{3
        let @e = escape(@e, '\"')
        call EvalSelection("sps", a:cmd, "", 
                    \ 'call EvalSelectionTalk(g:evalSelectionSpssInterpreter, "', '")')
    endf

    if !hasmapto("EvalSelection_sps(")
        call EvalSelectionGenerateBindings("S", "sps")
    endif

    if !exists("g:evalSelectionSpssCmdLine") && s:windows
        fun! EvalSelectionRunSpssMenu(menuEntry) "{{{3
            echo "Be careful with this. Some menu entries simply don't work this way.\n".
                        \ "Press the <OK> button when finished, not the <Insert> button."
            let formatoptions = &formatoptions
            " let smartindent   = &smartindent
            let autoindent    = &autoindent
            set formatoptions&
            " set nosmartindent&
            set noautoindent
            try
                ruby <<EOR
                i = $EvalSelectionTalkers["SPSS"]
                if i
                    m = VIM::evaluate("a:menuEntry")
                    begin
                        # i.data.InvokeDialogAndExecuteSyntax(m, 1, false)
                        rv = i.data.InvokeDialogAndReturnSyntax(m, 1)
                        if rv and rv != ""
                            # VIM::command(%{echom "#{rv}"})
                            VIM::command(%{norm! a #{rv}})
                        end
                    rescue WIN32OLERuntimeError => e
                        VIM::command(%{echohl Error})
                        for l in e.to_s
                            VIM::command(%{echo "#{l.gsub(/"/, '\\\\"')}"})
                        end
                        VIM::command(%{echohl None})
                    end
                else
                    VIM::command(%Q{echoerr "EvalSelection RSM: Set up interaction with SPSS first!"})
                end
EOR
            finally
                let &formatoptions = formatoptions
                " let &smartindent   = smartindent
                let &autoindent    = autoindent
            endtry
        endf
        
        fun! EvalSelectionBuildMenu_sps() "{{{3
            if has("menu")
                ruby <<EOR
                i = $EvalSelectionTalkers["SPSS"]
                if i
                end
EOR
            endif
        endf
    
        ruby << EOR
        require 'win32ole'
        class EvalSelectionSPSS < EvalSelectionOLE
            attr :data
            
            def setup
                @iid         = "SPSS"
                @interpreter = "ole"
                @spss_syntax_menu   = false
            end

            def ole_setup
                @ole_server = WIN32OLE.new("spss.application")
                @options    = @ole_server.Options
                # 0	SPSSObjectOutput
                # 1	SPSSDraftOutput
                # if VIM::evaluate(%{exists("g:evalSelection_SPSS_DraftOutput")})
                #     @options.OutputType = VIM::evaluate(%{g:evalSelection_SPSS_DraftOutput})
                # end
                # if VIM::evaluate(%{g:evalSelection_SPSS_DraftOutput}) == "1"
                #     @output = @ole_server.NewDraftDoc
                # else
                #     @output = @ole_server.NewOutputDoc
                # end
                # @output.visible = true
                @data         = @ole_server.NewDataDoc
                @data.visible = true
            end

            def ole_tear_down
                @ole_server.Quit
                return true
            end

            def ole_evaluate(text)
                # run commands asynchronously as long as I don't know how to 
                # retrieve the output
                @ole_server.ExecuteCommands(text, false)
                if VIM::evaluate(%{g:evalSelection_SPSS_DraftOutput}) == "1"
                    @output = @ole_server.GetDesignatedDraftDoc
                else
                    @output = @ole_server.GetDesignatedOutputDoc
                end
                @output.visible = true
                nil
            end

            # this doesn't quite work yet
            def build_spss_syntax_menu
                if !@spss_syntax_menu and VIM::evaluate(%{has("menu")})
                    menu = @data.GetMenuTable
                    VIM::command(%{amenu SPSS\\ Syntax.Some\\ menus\\ cause\\ vim\\ to\\ hang :})
                    VIM::command(%{amenu SPSS\\ Syntax.Press\\ the\\ *OK*\\ button\\ to\\ insert\\ the\\ syntax :})
                    VIM::command(%{amenu SPSS\\ Syntax.--Sep-SPSS-- :})
                    for e in menu
                        if e =~ /\>/ and !menu.any? {|m| m =~ /^#{Regexp.escape(e)}\>/}
                            m = e.gsub(/([.\\ ])/, '\\\\\\1')
                            m.gsub!(/\>/, '.')
                            VIM::command(%{amenu SPSS\\ Syntax.#{m} :call EvalSelectionRunSpssMenu('#{e}')<CR>})
                        end
                    end
                    @spss_syntax_menu = true
                end
            end
            
            def build_menu(initial=false)
                variables = initial ? [] : @data.GetVariables(true)
                if variables
                    variables.each {|v| v.gsub!(/\t/, " - ")}
                    build_vim_menu("SPSS", variables, 
                                   lambda {|x| "a" + x.gsub(/^(\S+) - .*$/, "\\1")},
                                   :exit   => %{:EvalSelectionQuitSPSS<CR>},
                                   :update => %{:ruby EvalSelection.update_menu("SPSS")<CR>},
                                   :remove_menu => %{:ruby EvalSelection.remove_menu("SPSS")<cr>}
                                  )
                end
                build_spss_syntax_menu
            end

            def remove_menu
                if VIM::evaluate(%{has("menu")})
                    if @spss_syntax_menu
                        VIM::command(%{aunmenu SPSS\\ Syntax})
                        @spss_syntax_menu = false
                    end
                    super
                end
            end
        end
EOR
    endif
endif

finish

CHANGES:
0.5 :: Initial Release

0.6 :: Interaction with interpreters; separated logs; use of redir; 
EvalSelectionCmdLine (CLI like interaction) 

0.7 :: Improved interaction (e.g., multi-line commands in R); moved code 
depending on +ruby to EvalSelectionRuby.vim (thanks to Grant Bowman for 
pointing out this problem); saved all files in unix format; added 
python, perl, and tcl (I can't tell if they work) 

0.8 :: improved interaction with external interpreters (it's still not 
really usable but it's getting better); reunified EvalSelection.vim and 
EvalSelectionRuby.vim 

0.9 :: support for communication via win32 COM/OLE (R, SPSS); general 
calculator shortcuts 

0.10 :: capture interaction with R via R(D)COM; "RDCOM" uses a 2nd 
instance of gvim as a pager (it doesn't start RCmdr any more); "RDCOM 
Commander" uses RCmdr; "RDCOM Clean" and "RDCOM Commander Clean" modes; 
take care of functions with void results (like data, help.search ...) 

0.11
R: set working directory and load .Rdata if available, word completion, 
catch errors, build objects menu; SPSS: show data window, build menu; 
g:evalSelectionLogCommands defaults to 1; revamped log 

0.14
Fixed some menu-related problems; <LocalLeader>r shortkey for SPSS and R 
(work similarly to ctrl-r in the spss editor); display a more useful 
error message when communication via OLE goes wrong; possibility to save 
the interaction log; post setup & tear down hooks for external 
interpreters; don't use win32ole when not on windows

0.15
- Escape backslashes in EvalSelectionTalk()
- SPSS: Insert a space before variable names (as does SPSS)

0.16
- MzScheme support (thanks to Mark Smithfield)
- Catch errors on EvalSelectionQuit (you'll have to manually kill zombie 
processes)

