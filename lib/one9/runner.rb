require 'boson/runner'
require 'one9'

module One9
  class Runner < Boson::Runner
    GLOBAL_OPTIONS[:version] = {
      :type => :boolean, :desc => 'Print version'
    }

    def self.execute(cmd, args, options)
      options[:version] ? puts(One9::VERSION) :
        super
    rescue NoReportError
      abort("one9 has no report. `one9 test` your project first.")
    rescue
      warn("one9 error: #{$!}\n  #{$!.backtrace[0]}")
    end

    option :all, :type => :boolean , :desc => "Displays full stack"
    desc 'Print 1.9 changes report from last test'
    def list(query=nil, options={})
      Report.list(query, options)
    end

    option :all, :type => :boolean , :desc => "Displays full stack"
    desc 'Print 1.9 changes by line from last test'
    def lines(query=nil, options={})
      Report.lines(query, options)
    end

    desc 'Print all known 1.9 changes'
    def changes(query=nil)
      Report.changes(query)
    end

    option :all, :type => :boolean , :desc => "Displays full stack"
    desc 'Generate 1.9 change list formatted for editors'
    def quickfix(query=nil, options={})
      Report.quickfix(query, options)
    end

    desc 'Spy on tests and print report.'
    def test(*commands)
      ENV['RUBYOPT'] = "-I#{File.dirname File.dirname(__FILE__)} -rone9/it"
      system commands.empty? ? 'rake test' : commands.join(' ')
      warn "** one9: Error occurred while testing **" unless $?.success?
    end

    desc 'Place 1.9 changes from last test into an editor'
    def edit(query=nil)
      Report.report_exists!
      editor = ENV['EDITOR'] || 'vim'
      if editor[/^vim/]
        grep = "one9 quickfix #{query}".strip.gsub(' ', '\\ ')
        exec(%q[vim -c 'set grepprg=] + grep + %q[' -c 'botright copen' -c 'silent! grep'])
      else
        puts "No support for #{editor} yet. Patches welcome :)"
      end
    end
  end
end
