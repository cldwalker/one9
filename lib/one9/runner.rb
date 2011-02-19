require 'one9'

module One9
  module Runner
    extend self

    def run(argv=ARGV)
      One9.config.merge! parse_options(argv)
      if argv.empty?
        Report.print_last_profile
      elsif public_methods.include? argv[0]
        send(*argv)
      else
        warn "one9: Invalid command '#{argv[0]}'"
      end
    rescue NoProfileError
      warn("one9 hasn't profiled anything. Run it with your test suite first.")
    rescue
      warn("one9 error: #{$!}\n  #{$!.backtrace[0]}")
    end

    def parse_options(argv)
      opt = {}
      opt[:debug] = true if argv.delete('-d') || argv.delete('--debug')
      opt
    end

    def files(query=nil)
      Report.print_files(query)
    end

    def quickfix(query=nil)
      Report.quickfix(query)
    end

    def test(*args)
      ENV['RUBYOPT'] = '-rone9/it'
      exec args.empty? ? 'rake test' : args.join(' ')
    end

    def edit(query=nil)
      Report.profile_exists!
      grep = "one9 quickfix #{query}".strip.gsub(' ', '\\ ')
      exec(%q[vim -c 'set grepprg=] + grep + %q[' -c 'botright copen' -c 'silent! grep'])
    end
  end
end
