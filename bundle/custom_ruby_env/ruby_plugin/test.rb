$env.instance_eval do
  command 'TestRubyEnv' do
    puts 'just a test'
    VIM.command('tabnew')
  end

  command!('TestRubyEnv') { puts 'foo' }

  command 'TryMethodMissing' do
    tabnew "test.rb"
    split "foo.txt"
    normal! "ijust a test"
  end
end
