module One9
  class NoProfileError < StandardError; end
  module Report
    extend self

    def print(meths, stacks)
      FileUtils.touch lock_file
      Hirb.enable
      results = ReportMethod.create(meths, stacks)
      results = results.select {|e| e.count > 0 }
      puts "\n** One9 Report **"
      return puts('No 1.9 changes found') if results.size.zero?
      table results, :fields => [:name, :count, :message, :type, :stacks],
        :headers => {:name => 'method', :stacks => 'lines'},
        :filters => { :stacks => [:join, ','] }
    end

    def table(*args)
      puts Hirb::Helpers::AutoTable.render(*args)
    end

    def later(meths, stacks)
      File.unlink(lock_file) if File.exists?(lock_file)
      at_exit { print_and_save(meths, stacks) }
    end

    def profile_exists!
      raise(NoProfileError) unless File.exists? marshal_file
    end

    def setup
      profile_exists!
      One9.setup
      File.open(marshal_file, 'rb'){|f| Marshal.load(f.read ) }
    end

    def quickfix(query=nil)
      meths, stacks = setup
      results = method_lines(meths, stacks, query)
      results.map! {|meth, trace|
        trace[/^([^:]+:\d+:)(.*)/] ? "#{$1} #{meth.name} - #{meth.message}" : trace
      }
      puts results
    end

    def method_lines(meths, stacks, query)
      objs = query ? meths.select {|e| e.name[/#{query}/] } : meths
      results = ReportMethod.create(objs, stacks)
      results.inject([]) {|arr, e|
        arr += e.stacks.map {|f| [e, f] }
      }
    end

    def print_files(query=nil)
      meths, stacks = setup
      results = method_lines(meths, stacks, query)
      table results.map {|m,l| [m.name, l] } , :change_fields => [:method, :line]
    end

    def print_last_profile
      meths, stacks = setup
      print(meths, stacks)
    end

    def marshal_file
      "#{One9.dir}/one9.marshal"
    end

    def lock_file
      "#{One9.dir}/report.lock"
    end

    def print_and_save(meths, stacks)
      return if File.exists? lock_file
      print(meths, stacks)
      save(meths, stacks)
    end

    def save(meths, stacks)
      stacks_copy = stacks.inject({}) {|h,(k,v)| h.merge!(k => v) }
      File.open(marshal_file, 'wb') {|f| f.write Marshal.dump([meths, stacks_copy]) }
    rescue Exception => err
      warn "one9: Error while saving report:\n" +
      "#{err.class}: #{err.message}\n    #{err.backtrace.slice(0,10).join("\n    ")}"
    end
  end
end
