ruby << RUBY
begin
  require 'dbi'
rescue LoadError
  require 'rubygems'
  require 'dbi'
end

class Connection
  def initialize(dsn)
    @dbh = DBI.connect dsn
  end

  def tables
    @dbh.tables
  end
end

def tables
  c = Connection.new "DBI:ODBC:massivegood"
  puts c.tables
end
RUBY

command! RubyTables call ruby#call('tables')
