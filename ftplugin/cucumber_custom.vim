command! -buffer -nargs=* -complete=file Run !cucumber % <args>

let b:fswitchdst  = 'rb'
let b:fswitchlocs = 'step_definitions'

command! -buffer A FSHere
