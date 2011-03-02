module One9
  class ReportMethod
    CURRENT_DIRS = [Dir.pwd + '/', './']
    CURRENT_DIRS_REGEX = Regexp.new "^#{Regexp.union(CURRENT_DIRS)}"

    class <<self; attr_accessor :stacks, :allowed_paths, :report_paths, :regexp_paths; end
    self.allowed_paths = ['lib/']

    def self.create(meths, stacks)
      self.stacks = stacks
      self.allowed_paths += ['app/', 'config/'] if File.exists? 'config/environment.rb'
      self.report_paths = CURRENT_DIRS.map {|e| allowed_paths.map {|f| e + f } }.flatten
      self.regexp_paths = Regexp.new "^#{Regexp.union(report_paths)}"
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
      One9.config[:all] || ary[0][self.class.regexp_paths] ? ary[0] : nil
    end
  end
end
