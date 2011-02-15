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
    end

    def files(meth=nil)
      Report.print_files(meth)
    end
  end
end
