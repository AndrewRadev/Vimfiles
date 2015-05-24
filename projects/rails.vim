runtime projects/ruby.vim

silent AckIgnore log/ tmp/

runtime after/plugin/snippets.vim

call ExtractSnipsFile(expand(g:snippets_dir).'rails.snippets', 'ruby')
call ExtractSnipsFile(expand(g:snippets_dir).'rails_erb.snippets', 'eruby')
call ExtractSnipsFile(expand(g:snippets_dir).'rails_rspec.snippets', 'rspec')
call ExtractSnipsFile(expand(g:snippets_dir).'rails_haml.snippets', 'haml')
call ExtractSnipsFile(expand(g:snippets_dir).'jquery.snippets', 'javascript')

call ExtractSnipsFile('_snippets/ruby.snippets', 'ruby')
call ExtractSnipsFile('_snippets/rspec.snippets', 'rspec')
call ExtractSnipsFile('_snippets/javascript.snippets', 'javascript')

" autocmd BufRead * nmap <buffer> gf      <Plug>CustomRailsFind
" autocmd BufRead * nmap <buffer> <C-W>f  <Plug>CustomRailsSplitFind
" autocmd BufRead * nmap <buffer> <C-W>gf <Plug>CustomRailsTabFind
"
" nnoremap <Plug>CustomRailsFind      :exe 'edit '   . <SID>CustomRailsIncludeexpr()<cr>
" nnoremap <Plug>CustomRailsSplitFind :exe 'split '  . <SID>CustomRailsIncludeexpr()<cr>
" nnoremap <Plug>CustomRailsTabFind   :exe 'tabnew ' . <SID>CustomRailsIncludeexpr()<cr>

autocmd User Rails set includeexpr=CustomRailsIncludeexpr()

function! CustomRailsIncludeexpr()
  let line = getline('.')

  let coffee_require_pattern = '#=\s*require \(\f\+\)\s*$'
  let scss_import_pattern    = '@import "\(.\{-}\)";'
  let stylesheet_pattern     = 'stylesheet ''\(.\{-}\)'''
  let javascript_pattern     = 'javascript ''\(.\{-}\)'''

  if expand('%:e') =~ 'coffee' && line =~ coffee_require_pattern
    let path = lib#ExtractRx(line, coffee_require_pattern, '\1')
    return s:FindRailsFile('app/assets/javascripts/'.path.'.*')
  elseif expand('%:e') =~ 'scss' && line =~ scss_import_pattern
    let path = lib#ExtractRx(line, scss_import_pattern, '\1')
    let file = s:FindRailsFile('app/assets/stylesheets/'.path.'.*')
    if file == ''
      let path = substitute(path, '.*/\zs\([^/]\{-}\)$', '_\1', '')
      let file = s:FindRailsFile('app/assets/stylesheets/'.path.'.*')
    endif
    return file
  elseif line =~ stylesheet_pattern
    let path = lib#ExtractRx(line, stylesheet_pattern, '\1')
    return s:FindRailsFile('app/assets/stylesheets/'.path.'.*')
  elseif line =~ javascript_pattern
    let path = lib#ExtractRx(line, javascript_pattern, '\1')
    return s:FindRailsFile('app/assets/javascripts/'.path.'.*')
  else
    return RailsIncludeexpr()
  endif
endfunction
function! s:FindRailsFile(pattern)
  let matches = glob(getcwd().'/'.a:pattern, 0, 1)
  if !empty(matches)
    return matches[0]
  else
    return ''
  endif
endfunction

let g:rails_mappings = 0

command! Eroutes edit config/routes.rb
command! -nargs=* -complete=custom,s:CompleteRailsModels Eschema call s:Eschema(<q-args>)
command! -nargs=1 -complete=custom,s:CompleteRailsModels Emodel edit app/models/<args>.rb
command! -nargs=1 -complete=custom,s:CompleteRailsControllers Econtroller edit app/controllers/<args>_controller.rb
" command! -nargs=* -complete=custom,s:CompleteRailsFactory Efactory call s:Efactory(<f-args>)

command! -nargs=1 -complete=custom,s:EconfigComplete Econfig call s:Econfig(<f-args>)
function! s:Econfig(pattern)
  let files = split(glob('config/'.a:pattern.'*'), "\n")

  if len(files) == 0
    echoerr "Pattern not found: config/".a:pattern."*"
    return
  elseif len(files) == 1
    exe 'edit '.files[0]
  else
    let prompt = ['Which file?'] + map(copy(files), 'string(v:key + 1) . ") " . v:val')
    let choice = inputlist(prompt)
    if choice <= 0
      return
    endif
    let selected_file = files[choice - 1]
    exe 'edit '.selected_file
  endif
endfunction
function! s:EconfigComplete(argument_lead, command_line, cursor_position)
  let files = split(glob('config/*'), "\n")
  let files = map(files, "substitute(v:val, '^config/', '', '')")
  let files = map(files, "fnamemodify(v:val, ':r')")
  let files = uniq(files)
  return join(files, "\n")
endfunction

command! DumpRoutes r! bundle exec rake routes
command! ReadCucumberSteps r!cucumber | sed -n -e '/these snippets/,$ p' | sed -n -e '2,$ p'

function! s:Eschema(model_name)
  let model_name = a:model_name

  if model_name == ''
    let model_name = s:CurrentModelName()
  endif

  edit db/schema.rb

  if model_name != ''
    let table_name = s:Tableize(model_name)
    call search('create_table "'.table_name.'"')
  endif
endfunction

function! s:CurrentModelName()
  let current_file = expand('%:p')

  if current_file =~ 'app/models/.*\.rb$'
    let filename = expand('%:t:r')
    return lib#CapitalCamelCase(filename)
  else
    return ''
  endif
endfunction

" TODO (2012-01-30) Better pluralization
function! s:Tableize(model_name)
  return lib#Underscore(a:model_name) . 's'
endfunction

function! s:CompleteRailsModels(A, L, P)
  let names = []
  for file in split(glob('app/models/**/*.rb'), "\n")
    let name = fnamemodify(file, ':t:r')
    call add(names, name)
  endfor
  return join(names, "\n")
endfunction

function! s:CompleteRailsControllers(A, L, P)
  let names = []
  for file in split(glob('app/controllers/**/*_controller.rb'), "\n")
    let name = fnamemodify(file, ':t:r')
    let name = substitute(name, '_controller$', '', '')
    call add(names, name)
  endfor
  return join(names, "\n")
endfunction

function! s:CompleteRailsFactory(A, L, P)
  let factories = []
  for line in split(system("grep -r 'Factory.define' spec/factories"), "\n")
    let factory = matchstr(line, 'Factory.define :\zs\w\+\ze')
    call add(factories, factory)
  endfor
  return join(factories, "\n")
endfunction

" TODO (2011-12-19) Extract factories with position data both for completion
" and editing
function! s:Efactory(name)
  exe "Ack 'Factory.define :".a:name."\\b' spec/factories"
  cclose
endfunction

" TODO (2012-01-30) :A, :R, gf
