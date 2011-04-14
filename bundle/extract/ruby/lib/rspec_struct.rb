class RspecStruct < Struct.new(:type, :body)
  class << self
    def parse(string)
      new(:it, $1) if string =~ /it "(.*)"/
    end
  end
end
