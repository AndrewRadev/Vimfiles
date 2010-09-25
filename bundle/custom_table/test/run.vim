" Initialize stage
tabnew
e bundle/custom_table/test/example.txt
w! bundle/custom_table/test/output.txt
e bundle/custom_table/test/output.txt

" Go downwards
normal! GGo
normal! o
normal! mz

" Now, check tables
function! CheckTable(name)
  call search(a:name)
  let [lines, cols] = [GetLines(), GetCols()]
  normal! GG
  exe "normal! i".a:name.": line [".lines[0].", ".lines[1]."] col [".cols[0].", ".cols[1]."]"
endfunction

call CheckTable("1")
normal! o
call CheckTable("2")
normal! o
call CheckTable("3")
normal! o
call CheckTable("4")

" Finish up
set nomodified

" Let's see the results
diffsplit bundle/custom_table/test/expectation.txt
