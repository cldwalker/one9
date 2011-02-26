require 'one9'

module One9
  module Runner
    extend self
    OPTIONS = [
      ['-d, --debug', 'Print all methods when reporting'],
      ['-v, --version', 'Print version'],
      ['-h, --help', 'Print help']
    ]
    COMMANDS = [
      ['test', 'Spy on tests and print report. Default test command is `rake test`'],
      ['list', 'Print 1.9 changes report from last test'],
      ['edit', 'Place 1.9 changes from last test into an editor'],
      ['files', 'Print 1.9 changes per occurrence in a file'],
      ['quickfix', 'Generate 1.9 change list formatted for editors']
    ]

    def run(argv=ARGV)
      One9.config.merge! parse_options(argv)
      if One9.config[:help] || argv.empty?
        help
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

    def list
      Report.print_last_profile
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

    private
    def parse_options(argv)
      opt = {}
      while argv[0] =~ /^-/
        case option = argv.shift
        when '-d', '--debug' then opt[:debug] = true
        when '-h', '--help'  then opt[:help] = true
        when '-v', '--version' then puts(One9::VERSION); exit
        else
          warn "one9: invalid option `#{option}'"
        end
      end
      opt
    end

    def help
      puts "one9 [OPTIONS] COMMAND [ARGS]", "", "Options:", format_arr(OPTIONS),
        "", "Commands:", format_arr(COMMANDS)
    end

    def format_arr(arr)
      zero = arr.map {|e| e[0].length }.max
      one = arr.map {|e| e[1].length }.max
      arr.map {|k,v| "  %-*s  %-*s" % [zero, k, one, v] }
    end
  end
end
