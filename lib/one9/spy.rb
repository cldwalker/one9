module One9
  module Spy
    def self.setup(methods)
      valid_methods(methods).each do |meth|
        str = eval_string(meth)
        eval_meth = meth.class_method? ? :instance_eval : :module_eval
        meth.real_klass.send(eval_meth, str)
      end
    end

    def self.valid_methods(methods)
      methods.select do |meth|
        if meth.real_klass.nil?
          puts "#{meth.klass} does not exist. Skipping #{meth.name}..."
          false
        elsif !meth.exists?
          puts "#{meth.name} is not a method. Skipping ..."
          false
        else
          true
        end
      end
    end

    def self.eval_string(meth)
      alias_code = "alias_method :_one9_#{meth.meth}, :#{meth.meth}"
      alias_code = "class <<self; #{alias_code}; end" if meth.class_method?
      %[#{alias_code}

        def #{meth.meth}(*args, &block)
          One9.spy('#{meth.name}')
          _one9_#{meth.meth}(*args, &block)
        end
      ]
    end
  end
end
