compiler cucumber

RunCommand !cucumber % <args>

let b:fswitchdst  = 'rb'
let b:fswitchlocs = 'step_definitions'

let b:outline_pattern = '\v^\s*(Feature|Scenario):(\s|$)'

command! -buffer A FSHere
