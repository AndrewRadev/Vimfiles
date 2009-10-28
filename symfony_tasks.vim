let g:main_tasks = [
      \ "help",
      \ "list",
      \ "app",
      \ "cache",
      \ "configure",
      \ "generate",
      \ "i18n",
      \ "log",
      \ "plugin",
      \ "project",
      \ "propel",
      \ "test",
      \ ]


let g:all_tasks = [
      \ "app:routes",
      \ "cache:clear",
      \ "configure:author",
      \ "configure:database",
      \ "generate:app",
      \ "generate:module",
      \ "generate:project",
      \ "generate:task",
      \ "i18n:extract",
      \ "i18n:find",
      \ "log:clear",
      \ "log:rotate",
      \ "plugin",
      \ "plugin:add-channel",
      \ "plugin:install",
      \ "plugin:list",
      \ "plugin:publish-assets",
      \ "plugin:uninstall",
      \ "plugin:upgrade",
      \ "project:clear-controllers",
      \ "project:deploy",
      \ "project:disable",
      \ "project:enable",
      \ "project:freeze",
      \ "project:permissions",
      \ "project:unfreeze",
      \ "project:upgrade1.1",
      \ "project:upgrade1.2",
      \ "propel:build-all",
      \ "propel:build-all-load",
      \ "propel:build-filters",
      \ "propel:build-forms",
      \ "propel:build-model",
      \ "propel:build-schema",
      \ "propel:build-sql",
      \ "propel:data-dump",
      \ "propel:data-load",
      \ "propel:generate-admin",
      \ "propel:generate-module",
      \ "propel:generate-module-for-route",
      \ "propel:graphviz",
      \ "propel:init-admin",
      \ "propel:insert-sql",
      \ "propel:schema-to-xml",
      \ "propel:schema-to-yml",
      \ "test:all",
      \ "test:coverage",
      \ "test:functional",
      \ "test:unit",
      \ ]

command! -complete=customlist,CompleteTasks -nargs=+ Pake !php symfony <args>
function! CompleteTasks(A,L,P)
  if a:A !~ ":"
    return filter(g:main_tasks, "v:val =~ '".a:A."'")
  else
    return filter(g:all_tasks, "v:val =~ '".a:A."'")
  endif
endfunction
