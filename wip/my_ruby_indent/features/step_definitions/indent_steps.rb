Given /^my ruby indent is loaded$/ do
  plugin_dir = File.expand_path('../../..', __FILE__)
  @vim.add_plugin plugin_dir
end

When /^I reindent the file$/ do
  @vim.normal 'gg=G'
  @vim.write
end
