require 'fileutils'
require 'hirb'
require 'one9/method'
require 'one9/spy'
require 'one9/rc'

module One9
  extend self
  attr_accessor :meths, :stacks
  self.meths = []
  self.stacks = Hash.new {|h,k| h[k] = [] }
  CURRENT_DIRS = [Dir.pwd + '/', './']
  CURRENT_DIRS_REGEX = Regexp.new "^#{Regexp.union(One9::CURRENT_DIRS)}"

  def run
    return warn("one9 hasn't profiled anything. Run it with your test suite") unless
      File.exists? marshal_file
    init
    self.meths, self.stacks = File.open(marshal_file, 'rb'){|f| Marshal.load(f.read ) }
    report
  end

  # ensure all changes can be loaded
  def init
    %w{date time}.each {|e| require e }
  end

  def it
    load_rc File.dirname(__FILE__) + '/one9/defaults.rb'
    load_rc('~/.one9rc') if File.exists?(File.expand_path('~/.one9rc'))
    Spy.setup meths
    File.unlink(lock_file) if File.exists?(lock_file)
    at_exit { report_and_save }
  end

  def dir
    @dir ||= begin
      path = File.expand_path('~/.one9')
      FileUtils.mkdir_p path
      path
    end
  end

  def marshal_file
    "#{dir}/one9.marshal"
  end

  def lock_file
    "#{dir}/report.lock"
  end

  def spy(meth)
    (stacks[meth] ||= []) << caller[1..-1]
  end

  def report_paths
    @report_paths ||= CURRENT_DIRS.map {|e| e + 'lib/' }
  end

  def regexp_paths
    @regexp_paths ||= Regexp.new "^#{Regexp.union(report_paths)}"
  end

  def report_and_save
    return if File.exists? lock_file
    report
    save
  end

  def save
    stacks_copy = stacks.inject({}) {|h,(k,v)| h.merge!(k => v) }
    File.open(marshal_file, 'wb') {|f| f.write Marshal.dump([meths, stacks_copy]) }
  rescue Exception => err
    warn "one9: Error while saving report:\n" +
    "#{err.class}: #{err.message}\n    #{err.backtrace.slice(0,10).join("\n    ")}"
  end

  def report
    FileUtils.touch lock_file
    Hirb.enable
    results = meths.select {|e| e.count > 0 }
    puts "\n** One9 Report **"
    return puts('No 1.9 changes found') if results.size.zero?
    puts Hirb::Helpers::AutoTable.render(results,
     :fields => [:name, :count, :message, :type, :stacks])
  end

  def load_rc(file)
    Rc.module_eval File.read(file)
  rescue StandardError, SyntaxError, LoadError => err
    warn "one9: Error while loading #{file}:\n"+
      "#{err.class}: #{err.message}\n    #{err.backtrace.slice(0,10).join("\n    ")}"
  end
end
