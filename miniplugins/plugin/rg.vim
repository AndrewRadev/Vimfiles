command! -nargs=1 Rgmigration call s:Rgmigration(<q-args>)
function! s:Rgmigration(description)
  let name = substitute(a:description, '\s\+', '_', 'g')

  let file_name  = 'db/migrate/'.strftime('%Y%m%d%H%M%S_').name.'.rb'
  let class_name = lib#CapitalCamelCase(name)

  exe 'edit '.file_name

  call append(0, [
        \ 'class '.class_name.' < ActiveRecord::Migration[5.2]',
        \ '  def change',
        \ '    create_table #<tab>',
        \ '  end',
        \ 'end'
        \ ])
  $delete _
  normal! gg
  write
endfunction

command! -nargs=1 Rgmodel call s:Rgmodel(<q-args>)
function! s:Rgmodel(name)
  let name       = a:name
  let file_name  = 'app/models/'.name.'.rb'
  let spec_name  = 'spec/models/'.name.'_spec.rb'
  let class_name = lib#CapitalCamelCase(name)

  call writefile([
        \ 'class '.class_name.' < ActiveRecord::Base',
        \ 'end'
        \ ], file_name)

  call writefile([
        \ 'require ''spec_helper''',
        \ '',
        \ 'describe '.class_name.' do',
        \ 'end'
        \ ], spec_name)

  exe 'Rgmigration create_'.name.'s'
endfunction
