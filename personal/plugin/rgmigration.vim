command! -nargs=1 Rgmigration call s:Rgmigration(<q-args>)
function! s:Rgmigration(description)
  let name = substitute(a:description, '\s\+', '_', 'g')

  let file_name  = 'db/migrate/'.strftime('%Y%m%d%H%M%S_').name.'.rb'
  let class_name = lib#CapitalCamelCase(name)

  exe 'edit '.file_name

  call append(0, [
        \ 'class '.class_name.' < ActiveRecord::Migration',
        \ '  def self.up',
        \ '  end',
        \ '',
        \ '  def self.down',
        \ '  end',
        \ 'end'
        \ ])
  normal! Gdd
  write
endfunction
