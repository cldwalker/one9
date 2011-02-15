require 'one9'

module One9
  module Runner
    extend self

    def run(argv = ARGV)
      if argv.empty?
        Report.print_last_profile
      elsif public_methods.include? argv[0]
        send(*argv)
      else
        warn "one9: Invalid command '#{argv[0]}'"
      end
    rescue NoProfileError
      warn("one9 hasn't profiled anything. Run it with your test suite first.")
    end

    def files(query=nil)
      Report.print_files(query)
    end

    def quickfix(query=nil)
      Report.quickfix(query)
    end

    def edit(query=nil)
      Report.profile_exists!
      grep = "one9 quickfix #{query}".strip.gsub(' ', '\\ ')
      exec(%q[vim -c 'set grepprg=] + grep + %q[' -c 'botright copen' -c 'silent! grep'])
    end
  end
end
