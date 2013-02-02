require 'vimrunner'
require 'vimrunner/testing'
require_relative './support/vim'
require_relative './support/files'

RSpec.configure do |config|
  config.include Vimrunner::Testing
  config.include Support::Files

  config.before(:suite) do
    VIM = Vimrunner.start_gvim
    VIM.add_plugin(File.expand_path('.'), 'plugin/xruntime.vim')

    Support::Vim.define_extra_methods(VIM)
  end

  config.after(:suite) do
    VIM.kill
  end

  # cd into a temporary directory for every example.
  config.around do |example|
    @vim = VIM

    tmpdir(@vim) do
      example.call
    end
  end
end
