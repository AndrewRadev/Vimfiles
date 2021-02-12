silent AckIgnore target/
silent TagsExclude target/*

let g:rust_sysroot = systemlist('rustc --print sysroot')
if !empty(rust_sysroot)
  let &tags .= ',' . fnamemodify(rust_sysroot[0] . '/lib/rustlib/src/rust/library/std/src/tags', ':p')
endif

compiler cargo
set makeprg=cargo\ test
