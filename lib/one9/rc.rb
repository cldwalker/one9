module One9
  module Rc
    def self.load(file)
      module_eval File.read(file)
    rescue StandardError, SyntaxError, LoadError => err
      warn "one9: Error while loading #{file}:\n"+
        "#{err.class}: #{err.message}\n    #{err.backtrace.slice(0,10).join("\n    ")}"
    end

    def self.meths
      @meths ||= []
    end

    def self.change(meths, msg=nil, options={})
      create(meths, :change, msg, options)
    end

    def self.delete(meths, msg=nil, options={})
      create(meths, :delete, msg, options)
    end

    def self.create(meths, type, msg, options)
      Array(meths).each {|e|
        self.meths << Method.new(e, options.merge(:type => type, :message => msg))
      }
    end
  end
end
