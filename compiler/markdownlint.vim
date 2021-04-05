if exists("current_compiler")
  finish
endif
let current_compiler = "markdownlint"

" Installation: gem install mdl
" Repository:   https://github.com/markdownlint/markdownlint
" Rules:        https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md

" Ignore rules:
" MD013 Line length
" MD033 Inline HTML
setlocal makeprg=mdl\ %\ -r\ ~MD013,~MD033

" sample error: README.md:71: MD034 Bare URL used
setlocal errorformat=%f:%l:\ MD0%n\ %m
