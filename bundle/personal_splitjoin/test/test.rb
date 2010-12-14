foo 1, 2, :one => 1, :two => 2, :three => 'three'

foo = { :bar => 'baz', :one => 'two' }

class Bar
  foo 1, 2, :one => 1, :two => 2, :three => 'three'
end

class Baz
  def qux
    foo 1, 2, :one => 1, :two => 2, :three => 'three'
  end
end
