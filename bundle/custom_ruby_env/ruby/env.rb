class Env
  def initialize
    @commands = {}
  end

  def command(name, &block)
    @commands[name] = block
    VIM.command("command #{name} ruby $env.exec_command('#{name}')")
  end

  def command!(name, &block)
    @commands[name] = block
    VIM.command("command! #{name} ruby $env.exec_command('#{name}')")
  end

  def exec_command(name)
    @commands[name].call
  end

  # Try calling a command directly
  def method_missing(m, *args, &block)
    VIM.command("#{m} #{args.join(' ')}")
  end
end

$env = Env.new
