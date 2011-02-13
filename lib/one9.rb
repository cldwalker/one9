require 'hirb'
require 'one9/method'
require 'one9/spy'
require 'one9/rc'

module One9
  extend self
  METHODS = []
  CURRENT_DIRS = [Dir.pwd + '/', './']
  CURRENT_DIRS_REGEX = Regexp.new "^#{Regexp.union(One9::CURRENT_DIRS)}"
  STACKS = Hash.new {|h,k| h[k] = [] }

  def it
    %w{fileutils date time}.each {|e| require e } # ensure all changes are loaded
    load_rc File.dirname(__FILE__) + '/one9/defaults.rb'
    load_rc('~/.one9rc') if File.exists?(File.expand_path('~/.one9rc'))
    Spy.setup METHODS
    at_exit { report }
  end

  def spy(meth)
    (STACKS[meth] ||= []) << caller[1..-1]
  end

  def report_paths
    @report_paths ||= CURRENT_DIRS.map {|e| e + 'lib/' }
  end

  def regexp_paths
    @regexp_paths ||= Regexp.new "^#{Regexp.union(report_paths)}"
  end

  def report
    Hirb.enable
    results = METHODS.select {|e| e.count > 0 }
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
