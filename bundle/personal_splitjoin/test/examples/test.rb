foo 1, 2, :one => 1, :two => 2, :three => 'three'

foo = { :bar => 'baz', :one => 'two' }

class Bar
  foo 1, 2, :one => 1, :two => 2, :three => 'three'
end

Bar.new { |b| puts b.to_s; puts 'foo' }

Bar.new { puts self.to_s }

class Baz
  def qux
    return if problem?

    foo 1, 2, :one => 1, :two => 2, :three => 'three'

    foo 1, 2, :one => 1, :two => 2 do
      something
    end

    foo 1, 2, :one => 1, :two => 2, :three => 'three' if condition?

    foo = "bar" if one.two?

    return 42 unless something_wrong?
  end
end
