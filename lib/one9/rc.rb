module One9
  module Rc
    def self.change(meths, msg=nil, options={})
      Array(meths).each {|e| Method.create(e, options.merge(:type => :change, :message => msg)) }
    end

    def self.delete(meths, msg=nil, options={})
      Array(meths).each {|e| Method.create(e, options.merge(:type => :delete, :message => msg)) }
    end
  end
end
