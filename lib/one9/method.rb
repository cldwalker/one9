module One9
  class Method
    attr_accessor :klass, :name, :meth, :type, :message
    def self.create(*args)
      METHODS << new(*args)
    end

    def self.any_const_get(name)
      return name if name.is_a?(Module)
      begin
        klass = Object
        name.split('::').each {|e|
          klass = klass.const_get(e)
        }
        klass
      rescue
         nil
      end
    end

    def initialize(name, options={})
      @name = name.to_s[/[.#]/] ? name :
        options[:class] ? options[:class] + name :
        raise(ArgumentError, "Method '#{name}' has an invalid name")
      @klass, @meth = @name.split(/[.#]/, 2)
      @message, @type = options.values_at(:message, :type)
      @message ||= @type == :delete ? "This method does not exist in 1.9" :
        "This method has different behavior in 1.9"
    end

    def count
      STACKS[name].select {|e| report_stack(e) }.size
    end

    def report_stack(ary)
      ary[0][One9.regexp_paths] ? ary[0] : nil
    end

    def stacks
      STACKS[name].map {|e| report_stack(e) }.compact.
        map {|e| e.sub(One9::CURRENT_DIRS_REGEX, '') }.uniq.join(', ')
    end

    def real_klass
      @real_klass ||= self.class.any_const_get(@klass)
    end

    def exists?
      obj = class_method? ? (class << real_klass; self end) : real_klass
      obj.method_defined?(meth) || obj.private_method_defined?(meth)
    end

    def class_method?
      @name.include?('.')
    end
  end
end
