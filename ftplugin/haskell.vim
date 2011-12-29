setlocal include=^import\\s*\\(qualified\\)\\?\\s*
setlocal includeexpr=substitute(v:fname,'\\.','/','g').'.'
setlocal suffixesadd=hs,lhs,hsc

ConsoleCommand !ghci       % <args>
RunCommand     !runhaskell % <args>

nmap <buffer> gm :exe ":Search hoogle " . expand("<cword>")<cr>
