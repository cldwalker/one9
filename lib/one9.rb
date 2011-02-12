require 'hirb'
require 'one9/method'
require 'one9/spy'
require 'one9/rc'

module One9
  extend self
  METHODS = []
  COUNTS = Hash.new(0)
  STACKS = Hash.new([])

  def it
    load_rc File.dirname(__FILE__) + '/one9/defaults.rb'
    load_rc('~/.one9rc') if File.exists?(File.expand_path('~/.one9rc'))
    Spy.setup METHODS
    at_exit { report }
  end

  def spy(meth)
    COUNTS[meth] += 1
    STACKS[meth] << caller(2)
  end

  def report
    Hirb.enable
    puts Hirb::Helpers::AutoTable.render(METHODS.select {|e| e.count > 0 },
     :fields => [:name, :count, :message, :type, :stack])
  end

  def load_rc(file)
    Rc.module_eval File.read(file)
  rescue StandardError, SyntaxError, LoadError => err
    warn "one9: Error while loading #{file}:\n"+
      "#{err.class}: #{err.message}\n    #{err.backtrace.slice(0,10).join("\n    ")}"
  end
end
