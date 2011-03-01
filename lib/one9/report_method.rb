module One9
  class ReportMethod
    CURRENT_DIRS = [Dir.pwd + '/', './']
    CURRENT_DIRS_REGEX = Regexp.new "^#{Regexp.union(CURRENT_DIRS)}"

    class <<self; attr_accessor :stacks; end

    def self.create(meths, stacks)
      self.stacks = stacks
      meths.map {|e| new(e) }
    end

    def initialize(meth)
      @meth = meth
    end

    [:name, :message, :type].each do |m|
      define_method(m) { @meth.send(m) }
    end

    def stacks
      @stacks ||= Array(self.class.stacks[name]).map {|e| report_stack(e) }.
        compact.map {|e| e.sub(CURRENT_DIRS_REGEX, '') }.uniq
    end

    def count
      stacks.count
    end

    def report_stack(ary)
      One9.config[:all] || ary[0][regexp_paths] ? ary[0] : nil
    end

    def regexp_paths
      @regexp_paths ||= Regexp.new "^#{Regexp.union(report_paths)}"
    end

    def report_paths
      @report_paths ||= CURRENT_DIRS.map {|e| e + 'lib/' }
    end
  end
end
