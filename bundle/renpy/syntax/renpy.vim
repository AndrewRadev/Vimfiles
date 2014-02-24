" Vim syntax file
" Language:     Renpy script
" Maintainer:   Civa Lin <larina.wf@gmail.com>
" Last Change:  2012 8 9
" Features:     

" Based on work by MusashiAharon <astrochess@gmail.com> (Version: 2011 Oct 9), http://yesoidos.sourceforge.net/upload/renpy.vim


if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

"syn include @Python syntax/python.vim
runtime! syntax/python.vim
unlet b:current_syntax

" Numbers
syn match renpyNumber "-\?\d\+\(\.\d\+\)\?"
syn match renpyNumber "-\?\.\d\+"

" Variable and label names
syn match renpyIdentifier "[_a-zA-Z][_a-zA-Z0-9]*"

" String commands and escaped characters
syn match renpyEscape +\\['"%]+ contained 
syn match renpyEscape +{/\?[ibsu]}+ contained
syn match renpyEscape +{/\?plain}+ contained
syn match renpyEscape +{\(p\|fast\|nw\|w\)}+ contained
syn match renpyEscape +{\(font\|a\|color\|w\)=[^}]*}+ contained
syn match renpyEscape +{/\(font\|a\|color\|w\)}+ contained
syn match renpyEscape +{/\?=[^}]*}+ contained
syn match renpyEscape +{{+ contained

" New in Renpy 6.13: square-bracket string interpolation
syn region renpyEscape start=+\[+ end=+\]+ contained
syn match renpyEscape +\[\[+ contained

" Strings
syn region renpyString start=+'+ end=+'+ skip=+\\'+ contains=renpyEscape,@Spell
syn region renpyString start=+"+ end=+"+ skip=+\\"+ contains=renpyEscape,@Spell

" Comments
syn match renpyComment "#.*$" contains=renpyTodo,@Spell
syn keyword renpyTodo FIXME TODO NOTE NOTES XXX contained

" Tabs not allowed in Renpy
syn match renpySpaceError "\t"

" Operators, keywords and special functions

""" Block
syn keyword renpyStatement init python early transform screen
""" Image
syn keyword renpyStatement image hide show scene with
syn keyword renpyOperator as at behind onlayer zorder
""" Flow Control
syn keyword renpyStatement menu jump call return
syn keyword renpyStatement if elif else
syn match renpyStatement "label" display nextgroup=renpyIdentifier skipwhite
""" Sound Voice & Music
syn keyword renpyStatement play stop queue
syn keyword renpyStatement voice sustain
syn keyword renpyOperator sound music
syn keyword renpyOperator fadein fadeout
""" Other
syn keyword renpyStatement define
syn keyword renpyOperator expression

" ATL

""" ATL: on & event Statenent
syn keyword renpyStatement event
syn match renpyStatement /on/ nextgroup=renpyEvent skipwhite
syn match renpyEvent / \(start\|show\|hide\|replace\|replaced\|hover\|idle\|selected_hover\|selected_idle\)/ contained
""" ATL: Interpolation Statemant & Warpers
syn keyword renpyStatement pause linear ease easein easeout
""" ATL: Circular Motion
syn keyword renpyOperator warp knot clockwise counterclockwise circles
""" ATL: Block (complex) Statement
syn keyword renpyStatement choice function parallel block
syn match renpyStatement /contains/ 
""" ATL: simple Statement
syn keyword renpyStatement time pass repeat
""" ATL: Displayable Transform Properties
syn keyword renpyOperator pos xpos ypos
syn keyword renpyOperator anchor xanchor yanchor
syn keyword renpyOperator align xalign yalign
syn keyword renpyOperator xcenter ycenter
syn keyword renpyOperator rotate rotate_pad
syn keyword renpyOperator zoom xzoom yzoom
syn keyword renpyOperator alpha
syn keyword renpyOperator around alignaround
syn keyword renpyOperator angle radius
syn keyword renpyOperator crop corner1 corner2
syn keyword renpyOperator size
syn keyword renpyOperator subpixel
syn keyword renpyOperator delay

" Screen

""" Screen: UI Statement properties
syn keyword renpyOperator at default id style style_group focus
""" Screen: UI Statement
syn keyword renpyStatement add
syn keyword renpyStatement bar vbar
syn keyword renpyStatement button textbutton imagebutton mousearea imagemap
syn keyword renpyStatement fixed frame grid hbox vbox side window null
syn keyword renpyStatement input key timer transform
syn keyword renpyStatement viewport hotspot hotbar
syn keyword renpyStatement label text
syn keyword renpyStatement has
""" Screen: Control Statement
syn keyword renpyStatement default for if elif else use on
syn keyword renpyOperator in not


" Function

""" Transition Function
syn keyword renpyFunction AlphaDissolve ComposeTransition CropMove Dissolve
syn keyword renpyFunction Fade ImageDissolve MoveTransition MultipleTransition
syn keyword renpyFunction Pause Pixellate
""" Displayable Function
syn keyword renpyFunction Image Frame LiveCrop LiveTile Null Solid
syn keyword renpyFunction ConditionSwitch DynamicDisplayable ShowingSwitch
syn keyword renpyFunction Fixed HBox VBox
""" Other Image Function
syn keyword renpyFunction At AlphaBlend

" Special variables

""" Default Transforms
syn keyword renpyBuiltin left right center truecenter topleft top topright
syn keyword renpyBuiltin offscreenleft offscreenright default reset
""" Pre-Defined Transitions
syn keyword renpyBuiltin fade dissolve pixellate
syn keyword renpyBuiltin move moveinright moveinleft moveintop moveinbottom
syn keyword renpyBuiltin moveoutright moveoutleft moveouttop moveoutbottom
syn keyword renpyBuiltin ease easeinright easeinleft easeintop easeinbottom
syn keyword renpyBuiltin easeoutright easeoutleft easeouttop easeoutbottom
syn keyword renpyBuiltin zoomin zoomout zoominout
syn keyword renpyBuiltin vpunch hpunch
syn keyword renpyBuiltin blinds squares
syn keyword renpyBuiltin wipeleft wiperight wipeup wipedown
syn keyword renpyBuiltin slideleft slideright slideup slidedown
syn keyword renpyBuiltin slideawayleft slideawayright slideawayup slideawaydown
syn keyword renpyBuiltin irisin irisout
""" Pre-Defined Displayable
syn keyword renpyBuiltin black text pause linear

" Python lines ($)
syn match pythonStatement /^ *\$ /
syn region None start=/^ *\$ / end=/$/ contains=@Python

" Python block
" FIXME: Not work
" syn region None start=/\( *\)[ \S]*?python[ \S]*?:$/ end=// contains=@Python

" Renpy-specific Python functions and variables
syn keyword pythonFunction Animation Character Null
syn keyword pythonFunction ShowingSwitch
syn match pythonFunction "anim\.\(Edge\|SMAnimation\|State\|TransitionAnimation\)"
syn match pythonFunction "anim\.Filmstrip"
syn match pythonFunction "im\.Composite"
syn match pythonFunction "im\.Crop"
syn match pythonFunction "im\.\(FactorScale\|Flip\|Grayscale\)"
syn match pythonFunction "im\.Image"
syn match pythonFunction "im\.MatrixColor"
syn match pythonFunction "im\.matrix\.\(brightness\|contrast\|hue\|invert\|saturation\)"
syn match pythonFunction "im\.Scale"
syn match pythonFunction "layout\.imagemap_main_menu"
syn match pythonFunction "layout\.button_menu"
syn match pythonFunction "renpy\.block_rollback"
syn match pythonFunction "renpy\.\(call_in_new_context\|curry\)"
syn match pythonFunction "renpy\.hide"
syn match pythonFunction "renpy\.\(jump_out_of_context\|jump\)"
syn match pythonFunction "renpy\.music\.\(play\|stop\|queue\|register_channel\|set_volume\)"
syn match pythonFunction "renpy\.pause"
syn match pythonFunction "renpy\.redraw"
syn match pythonFunction "renpy\.random\.\(choice\|randint\)"
syn match pythonFunction "renpy\.restart_interaction"
syn match pythonFunction "renpy\.\(scene\|show\)"
syn match pythonFunction "renpy\.showing"
syn match pythonFunction "renpy\.transition"
syn match pythonFunction "theme\.roundrect"
syn match pythonFunction "ui\.add"
syn match pythonFunction "ui\.\(bar\|button\)"
syn match pythonFunction "ui\.clear"
syn match pythonFunction "ui\.close"
syn match pythonFunction "ui\.\(fixed\|frame\|grid\)"
syn match pythonFunction "ui\.hbox"
syn match pythonFunction "ui\.image"
syn match pythonFunction "ui\.imagebutton"
syn match pythonFunction "ui\.imagemap"
syn match pythonFunction "ui\.interact"
syn match pythonFunction "ui\.\(keymap\|layer\)"
syn match pythonFunction "ui\.null"
syn match pythonFunction "ui\.remove"
syn match pythonFunction "ui\.returns"
syn match pythonFunction "ui\.text"
syn match pythonFunction "ui\.textbutton"
syn match pythonFunction "ui\.timer"
syn match pythonFunction "ui\.\(vbox\|window\)"

hi def link renpyNumber		Number
hi def link renpyString		String
hi def link renpyEscape		Special
hi def link renpyComment	Comment
hi def link renpyTodo		Todo
hi def link renpyStatement	Statement
hi def link renpyFunction	Function
hi def link renpyBuiltin	Identifier
hi def link renpyOperator	Operator
hi def link renpySpaceError	Error

hi def link renpyEvent          Identifier

let b:current_syntax = "renpy"
