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
      ['test', 'Spy on tests and print report.'],
      ['list', 'Print 1.9 changes report from last test'],
      ['edit', 'Place 1.9 changes from last test into an editor'],
      ['changes', 'Print all known 1.9 changes'],
      ['lines', 'Print 1.9 changes by line from last test'],
      ['quickfix', 'Generate 1.9 change list formatted for editors']
    ]
    COMMANDS_HELP = {
      :test => "[COMMAND='rake test']",
      :list => '[QUERY]',
      :changes => '[QUERY]',
      :lines => '[QUERY]',
      :edit => '[QUERY]',
      :quickfix => '[QUERY]'
    }

    def run(argv=ARGV)
      One9.config.merge! parse_options(argv)
      if One9.config[:help] || argv.empty?
        help
      elsif public_methods.include? argv[0]
        send(*argv)
      else
        abort "one9: Invalid command `#{argv[0]}'"
      end
    rescue NoReportError
      abort("one9 has no report. `one9 test` your project first.")
    rescue
      warn("one9 error: #{$!}\n  #{$!.backtrace[0]}")
    end

    [:list, :lines, :changes, :quickfix].each do |meth|
      define_method(meth) {|*args|
        command_help(meth, *args)
        Report.send(meth, *args)
      }
    end

    def test(*args)
      command_help(:test, *args)
      ENV['RUBYOPT'] = '-rone9/it'
      exec args.empty? ? 'rake test' : args.join(' ')
    end

    def edit(query=nil)
      command_help(:edit, query)
      Report.report_exists!
      editor = ENV['EDITOR'] || 'vim'
      if editor[/^vim/]
        grep = "one9 quickfix #{query}".strip.gsub(' ', '\\ ')
        exec(%q[vim -c 'set grepprg=] + grep + %q[' -c 'botright copen' -c 'silent! grep'])
      else
        puts "No support for #{editor} yet. Patches welcome :)"
      end
    end

    private
    def command_help(cmd, *args)
      if %w{-h --help}.include? args[0]
        msg = "one9 #{cmd}"
        msg += " " + COMMANDS_HELP[cmd] if COMMANDS_HELP[cmd]
        abort msg
      end
    end

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
      puts "one9 [OPTIONS] COMMAND [ARGS]", "",
        "Commands:", format_arr(COMMANDS), "",
        "For more information on a command use:", "  one9 COMMAND -h", "",
        "Options:", format_arr(OPTIONS)
    end

    def format_arr(arr)
      zero = arr.map {|e| e[0].length }.max
      one = arr.map {|e| e[1].length }.max
      arr.map {|k,v| "  %-*s  %-*s" % [zero, k, one, v] }
    end
  end
end
