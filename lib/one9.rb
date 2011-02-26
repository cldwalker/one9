require 'fileutils'
require 'hirb'
require 'one9/report'
require 'one9/method'
require 'one9/report_method'
require 'one9/spy'
require 'one9/rc'
require 'one9/version'

module One9
  extend self
  attr_accessor :stacks, :config
  self.stacks = Hash.new {|h,k| h[k] = [] }
  self.config = {}

  def spy(meth)
    stacks[meth] << caller[1..-1]
  end

  def it
    meths = load_methods
    Spy.setup meths
    Report.later(meths, stacks)
  end

  def load_methods
    setup
    Rc.load File.dirname(__FILE__) + '/one9/defaults.rb'
    Rc.load('~/.one9rc') if File.exists?(File.expand_path('~/.one9rc'))
    Rc.meths
  end

  # ensure all changes can be loaded
  def setup
    %w{date time}.each {|e| require e }
  end

  def dir
    @dir ||= begin
      path = File.expand_path('~/.one9')
      FileUtils.mkdir_p path
      path
    end
  end
end
