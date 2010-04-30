"SwapIt: General Purpose related word swapping for vim
" Script Info and Documentation  {{{1
"=============================================================================
"
"    Copyright: Copyright (C) 2008 Michael Brown {{{2
"      License: The MIT License
"
"               Permission is hereby granted, free of charge, to any person obtaining
"               a copy of this software and associated documentation files
"               (the "Software"), to deal in the Software without restriction,
"               including without limitation the rights to use, copy, modify,
"               merge, publish, distribute, sublicense, and/or sell copies of the
"               Software, and to permit persons to whom the Software is furnished
"               to do so, subject to the following conditions:
"
"               The above copyright notice and this permission notice shall be included
"               in all copies or substantial portions of the Software.
"
"               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"               OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"               MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"               IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"               CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"               TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"               SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"
" Name Of File: swapit.vim {{{2
"  Description: system for swapping related words
"   Maintainer: Michael Brown
" Contributors: Ingo Karkat (speedating compatability)
"  Last Change:
"          URL:
"      Version: 0.1.2
"
"        Usage: {{{2
"
"               On a current word that is a member of a swap list use the
"               incrementor/decrementor keys (:he ctrl-a,ctrl-x). The script
"               will cycle through a list of related options.
"
"               eg. 1. Boolean
"
"               foo=yes
"
"               in normal mode, pressing ctrl-a on the y will make it.
"
"               foo=no
"
"               The plugin handles clashes. Eg. if yes appears in more than
"               one swap list (eg. yes/no or yes/no/maybe), a confirm dialog will appear.
"
"               eg. 2. Multi Word Swaps.
"
"               Hello World! is a test multi word swap.
"
"               on 'Hello World!' go select in visual (vi'<ctrl-a>) to get
"
"               'GoodBye Cruel World!'
"
"               eg 3. Defining custom swaps
"
"               A custom list is defined as follows.
"
"               :SwapList datatype bool char int float double
"
"               The first argument is the list name and following args
"               are members of the list.
"
"               if there is no match then the regular incrementor decrementor
"               function will work on numbers
"
"               At the bottom of the script I've added some generic stuff but
"
"               You can create a custom swap file for file types at
"
"               ~/.vim/after/ftplugins/<filetype>_swapit.vim
"               with custom execs eg.
"               exec "SwapList function_scope private protected public"
"
"               For this alpha version multi word swap list is a bit trickier
"               to to define. You can add to the swap list directly using .
"
"                 call add(g:swap_lists, {'name':'Multi Word Example',
"                             \'options': ['swap with spaces',
"                             \'swap with  @#$@# chars in it' , \
"                             \'running out of ideas here...']})
"
"               Future versions will make this cleaner
"
"               Also if you have a spur of the moment Idea type
"               :SwapIdea
"               To get to the current filetypes swapit file
"
"               4. Insert mode completion
"
"               You can use a swap list in insert mode by typing the list name
"               and hitting ctrl+b eg.
"
"               datatype<ctrl+b>    once  will provide a complete list of datatypes.
"
"               (Note: insert mode complete is still buggy and will eat your current
"               word if you keep hitting ctrl+b on an incorrect. It's disabled
"               by default so as not to annoy anyone.  Uncomment the line in the
"               command configuration if you want to try it out.
"
"               Note: This alpha version doesnt create the directory structure
"
"               To integrate with other incrementor scripts (such as
"               speeddating.vim or monday.vim), :nmap
"               <Plug>SwapItFallbackIncrement and <Plug>SwapItFallbackDecrement
"               to the keys that should be invoked when swapit doesn't have a
"               proper option. For example for speeddating.vim:
"
"               nmap <Plug>SwapItFallbackIncrement <Plug>SpeedDatingUp
"               nmap <Plug>SwapItFallbackDecrement <Plug>SpeedDatingDown
"
"         Bugs: {{{2
"
"               Will only give swap options for first match (eg make sure
"               options are unique).
"
"               The visual mode is inconsistent on highlighting the end of a
"               phrase occasionally one character under see VISHACK
"
"               Visual selection bug: if you have set selection=exclusive. You
"               might have trouble with the last character not being selected
"               on a multi word swap
"
"        To Do: {{{2
"
"               - improve filetype handling
"               - look at load performance if it becomes an issue
"               - might create a text file swap list rather than vim list
"               - look at clever case option to reduce permutations
"               - look at possibilities beyond <cword> for non word swaps
"                   eg swap > for < , == to != etc.
"               - add a repeated keyword warning for :SwapList
"               - add repeat resolition confirm option eg.
"                SwapSelect>   a. (yes/no) b. (yes/no/maybe)
"
"               ideas welcome at mjbrownie (at) gmail dot com.
"
"               I'd like to compile some useful swap lists for different
"               languages to package with the script
"
"Variable Initialization {{{1
"if exists('g:loaded_swapit')
"    finish
"elseif v:version < 700
"    echomsg "SwapIt plugin requires Vim version 7 or later"
"    finish
"endif
let g:loaded_swapit = 1
let g:swap_xml_matchit = []

if !exists('g:swap_lists')
    let g:swap_lists = []
endif
if !exists('g:swap_list_dont_append')
    let g:swap_list_dont_append = 'no'
endif
if empty(maparg('<Plug>SwapItFallbackIncrement', 'n'))
    nnoremap <Plug>SwapItFallbackIncrement <c-a>
endif
if empty(maparg('<Plug>SwapItFallbackDecrement', 'n'))
    nnoremap <Plug>SwapItFallbackDecrement <c-x>
endif

"Command/AutoCommand Configuration {{{1
"
" For executing the listing
nnoremap <silent><c-a> :<c-u>call SwapWord(expand("<cword>"),'forward', 'no')<cr>
nnoremap <silent><c-x> :<c-u>call SwapWord(expand("<cword>"),'backward','no')<cr>
vnoremap <silent><c-a> "dy<esc>:call SwapWord(@d,'forward','yes')<cr>
vnoremap <silent><c-x> "dy<esc>:call SwapWord(@d,'backward','yes')<cr>
"inoremap <silent><c-b> <esc>b"sdwi <c-r>=SwapInsert()<cr>
"inoremap <expr> <c-b> SwapInsert()

" For adding lists
com! -nargs=* SwapList call AddSwapList(<q-args>)
com! ClearSwapList let g:swap_lists = []
com! SwapIdea call OpenSwapFileType()
com! -range -nargs=1 SwapWordVisual call SwapWord(getline('.'),<f-args>,'yes')
"au BufEnter call LoadFileTypeSwapList()
com! SwapListLoadFT call LoadFileTypeSwapList()
com! -nargs=+ SwapXmlMatchit call AddSwapXmlMatchit(<q-args>)
"Swap Processing Functions {{{1
"
"
"SwapWord() main processiong event function {{{2
fun! SwapWord (word, direction, is_visual)

    "{{{3 css omnicomplete property swapping
    if &filetype == 'css'
        let sline = split(getline("."), ":")

        if len(sline) == 2 " for a typical key:value line"
            let temp_reg = @s
            let cur_word = substitute(sline[1],"[^0-9A-Za-z_-]", "","g" )
            let matches = csscomplete#CompleteCSS(0, sline[0] . ": ")
            if index(matches,cur_word) != -1

                let word_index = index(matches, cur_word)

                if a:direction == 'forward'
                    let word_index = (word_index + 1) % len(matches)
                else
                    let word_index = (word_index - 1) % len(matches)
                endif
                let swap = sline[0]. ':' . substitute(sline[1], cur_word, matches[word_index], "")
                let result = setline(line("."), swap)
                return 1
            else
                let match_list = []
            endif

            let @s = temp_reg
        endif
    endif

    if g:swap_list_dont_append == 'yes'
        let test_lists =  g:swap_lists
    else
        let test_lists =  g:swap_lists + g:default_swap_list
    endif

    let cur_word = a:word
    let match_list = []

    " Main for loop over each swaplist {{{3
    for swap_list  in test_lists
        let word_options = swap_list['options']
        let word_index = index(word_options, cur_word)

        if word_index != -1
            call add(match_list, swap_list)
        endif
    endfor

    "}}}

    let out =  ProcessMatches(match_list, cur_word , a:direction, a:is_visual)
endfun

"ProcessMatches() handles various result {{{2
fun! ProcessMatches(match_list, cur_word, direction, is_visual)

    if len(a:match_list) == 0
        if a:direction == 'forward'
            exec "normal \<Plug>SwapItFallbackIncrement"
        else
            exec "normal \<Plug>SwapItFallbackDecrement"
        endif
        return ''
    endif

    if len(a:match_list) == 1
        let swap_list = a:match_list[0]
        call SwapMatch(swap_list, a:cur_word, a:direction, a:is_visual)
        return ''
    endif

    if len(a:match_list) > 7
        echo "Too many matches for " . a:cur_word . ". "
        echo a:match_list
        return ''
    endif

    if len(a:match_list) > 1
        call ShowSwapChoices(a:match_list, a:cur_word, a:direction, a:is_visual)
    endif

endfun
"PassThrough() handles no match event {{{2
fun! PassThrough(direction)
    ""echo "Swap: No match for " . cur_word
    if a:direction == 'forward'
        exec "normal! \<Plug>SwapItFallbackIncrement"
    else
        exec "normal! \<Plug>SwapItFallbackDecrement"
    endif
endfun

" SwapMatch()  handles match {{{2
fun! SwapMatch(swap_list, cur_word, direction, is_visual)

    let word_options = a:swap_list['options']
    let word_index = index(word_options, a:cur_word)

    if a:direction == 'forward'
        let word_index = word_index + 1
    else
        let word_index = word_index - 1
    endif

    "Deal with boundary conditions {{{3
    if  word_index < 0 && a:direction == 'backward'
        let list_size = len(word_options)
        let word_index = list_size - 1
    elseif word_index >= len(word_options)
        let word_index = 0
    endif

    let next_word = word_options[word_index]

    let temp_reg = @s
    let @s = next_word
    let in_visual = 0

    "XML matchit handling  {{{3
    if index(g:swap_xml_matchit, a:swap_list['name']) != -1

        if match(getline("."),"<\\(\\/".a:cur_word."\\|".a:cur_word."\\)[^>]*>" ) == -1
            return 0
        endif

        exec "norm T<ma%"

        "If the cursor is on a / then jump to the front and mark

        if getline(".")[col(".") -1] != "/"
            exec "norm ma%"
        endif

        exec "norm lviw\"sp`aviw\"sp"
    " Regular swaps {{{3
    else

        if a:is_visual == 'yes'
            if next_word =~ "\W"
                let in_visual = 1
                exec 'norm! gv"sp`[v`]'
            else
                exec 'norm! gv"spb'
            endif
        else
            if next_word =~ "\W"
                let in_visual = 1
                exec 'norm! maviw"sp`[v`]'
            else
                exec 'norm! maviw"spb`a'
            endif
        endif
    endif
    " 3}}}

    "TODO VISHACK This is a silly hack to fix the visual range. if the v ends with
    "a word character the visual range is onw column over but not for
    "non word characters.

"    if in_visual == 1 && next_word =~ "\\w$" && &selection == 'inclusive'
"        exec 'norm! h'
"    endif

"    if in_visual == 1 && (next_word =~  "\\W$") && &selection == 'exclusive'
"        exec 'norm! l'
"    endif

    let @s = temp_reg
    "    echo "Swap: " . a:swap_list['name'] .' '. a:cur_word . " > " . next_word
    "\. ' ' . word_index . ' ' . a:direction . ' ' . len(word_options)
    return 1
endfun
"
"ShowSwapChoices() shows alternative swaps {{{2
fun! ShowSwapChoices(match_list, cur_word, direction, is_visual)

    let a_opts = ['A','B','C','D','E','F','G']
    let con_index = 0
    let confirm_options = ''
    let confirm_but = ''

    "Generate the prompt {{{3
    for swap_list in a:match_list
        let confirm_options =  confirm_options . ' ' . a_opts[con_index] . " . " . swap_list['name'] . ' (' .
                    \a:cur_word . ' > ' . swap_list['options'][index(swap_list['options'], a:cur_word) + 1] . ') '

        "        For some reason concatenating stuffs up the string, using an
        "        if con_index > 0
        "            let confirm_but = confirm_but + '\n'
        "        endif
        "        let confirm_but = confirm_but +  "option&". a_opts[con_index]

        let con_index = con_index + 1
    endfor
    "   }}}
    "    TODO Prompt  This is a bit inelegant but I'm using it as the second argument of
    "       confirm wont take a concatenated string (some escape issue). At the moment I just want it
    "       to work
    "       {{{3
    if len(a:match_list) == 2
        let choice = confirm("Swap Options: " . confirm_options , "&A\n&B" ,  0)
    elseif len(a:match_list) == 3
        let choice = confirm("Swap Options: ". confirm_options  , "&A\n&B\n&C" ,  0)
    elseif len(a:match_list) == 4
        let choice = confirm("Swap Options: ". confirm_options  , "&A\n&B\n&C\n&D" , 0)
    elseif len(a:match_list) == 5
        let choice = confirm("Swap Options: ". confirm_options  , "&A\n&B\n&C\n&D\n&E" ,  0)
    elseif len(a:match_list) == 6
        let choice = confirm("Swap Options: ". confirm_options  , "&A\n&B\n&C\n&D\n&E\n&F" , 0)
    elseif len(a:match_list) == 7
        let choice = confirm("Swap Options: ". confirm_options  , "&A\n&B\n&C\n&D\n&E\&F\&G" , 0)
    endif
    "   }}}
    if choice != 0
        call SwapMatch(a:match_list[choice -1], a:cur_word, a:direction, a:is_visual)
    else
        echo "Swap: Cancelled"
    endif
endfun
"Insert Mode List Handling {{{1
"
"SwapInsert() call a swap list from insert mode
fun! SwapInsert()
    for swap_list  in (g:swap_lists + g:default_swap_list)
        if swap_list['name'] == @s
            call complete(col('.'), swap_list['options'])
            return ''
        endif
    endfor
    return  ''
endfun
"List Maintenance Functions {{{1
"AddSwapList()  Main Definition Function {{{2
"use with after/ftplugin/ vim files to set up file type swap lists
fun! AddSwapList(s_list)

    let word_list = split(a:s_list,'\s\+')

    if len(word_list) < 3
        echo "Usage :SwapList <list_name> <member1> <member2> .. <membern>"
        return 1
    endif

    let list_name = remove (word_list,0)

    call add(g:swap_lists,{'name':list_name, 'options':word_list})
endfun

fun! AddSwapXmlMatchit(s_list)
    let g:swap_xml_matchit = split(a:s_list,'\s\+')
endfun
"LoadFileTypeSwapList() "{{{2
"sources .vim/after/ftplugins/<file_type>_swapit.vim
fun! LoadFileTypeSwapList()

    "Initializing  the list {{{3
"    call ClearSwapList()
    let g:swap_lists = []
    let g:swap_list = []
    let g:swap_xml_matchit = []

    let ftpath = "~/.vim/after/ftplugin/". &filetype ."_swapit.vim"
    let g:swap_lists = []
    if filereadable(ftpath)
        exec "source " . ftpath
    endif

endfun

"OpenSwapFileType() Quick Access to filtype file {{{2
fun! OpenSwapFileType()
    let ftpath = "~/.vim/after/ftplugin/". &filetype ."_swapit.vim"
    if !filereadable(ftpath)
        "TODO add a directory check
        exec "10 split " . ftpath
        "exec 'norm! I "SwapIt.vim definitions for ' . &filetype . ': eg exec "SwapList names Tom Dick Harry\"'
        return ''
    else
        exec "10 split " . ftpath
    endif
    exec "norm! G"
endfun
"Default DataSet. Add Generic swap lists here {{{1
if g:swap_list_dont_append == 'yes'

    let g:default_swap_list = []

else
    let g:default_swap_list = [
                \{'name':'yes/no', 'options': ['yes','no']},
                \{'name':'Yes/No', 'options': ['Yes','No']},
                \{'name':'True/False', 'options': ['True','False']},
                \{'name':'true/false', 'options': ['true','false']},
                \{'name':'AND/OR', 'options': ['AND','OR']},
                \{'name':'Hello World', 'options': ['Hello World!','GoodBye Cruel World!' , 'See You Next Tuesday!']},
                \{'name':'On/Off', 'options': ['On','Off']},
                \{'name':'on/off', 'options': ['on','off']},
                \{'name':'ON/OFF', 'options': ['ON','OFF']},
                \{'name':'comparison_operator', 'options': ['<','<=','==', '>=', '>' , '=~', '!=']},
                \{'name': 'datatype', 'options': ['bool', 'char','int','unsigned int', 'float','long', 'double']},
                \]
endif
"NOTE: comparison_operator doesn't work yet but there in the hope of future
"
"capability
"
