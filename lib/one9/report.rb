module One9
  class NoReportError < StandardError; end
  module Report
    extend self

    def list
      meths, stacks = setup
      print(meths, stacks)
    end

    def lines(query=nil)
      meths, stacks = setup
      results = method_lines(meths, stacks, query)
      table results.map {|m,l| [m.name, l] } , :change_fields => [:method, :line]
    end

    def changes(query=nil)
      meths = One9.load_methods
      meths = query_methods(meths, query)
      table meths, :fields => [:name, :message, :type],
        :headers => {:name => 'method', :stacks => 'lines'}
    end

    def quickfix(query=nil)
      meths, stacks = setup
      results = method_lines(meths, stacks, query)
      results.map! {|meth, trace|
        trace[/^([^:]+:\d+:)(.*)/] ? "#{$1} #{meth.name} - #{meth.message}" : trace
      }
      puts results
    end

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

    def report_exists!
      raise(NoReportError) unless File.exists? marshal_file
    end

    def later(meths, stacks)
      File.unlink(lock_file) if File.exists?(lock_file)
      at_exit { print_and_save(meths, stacks) }
    end

    def marshal_file
      "#{One9.dir}/one9.marshal"
    end

    def lock_file
      "#{One9.dir}/report.lock"
    end

    private
    def table(*args)
      puts Hirb::Helpers::AutoTable.render(*args)
    end

    def setup
      report_exists!
      One9.setup
      File.open(marshal_file, 'rb'){|f| Marshal.load(f.read ) }
    end

    def query_methods(meths, query)
      query ? meths.select {|e| e.name[/#{query}/] } : meths
    end

    def method_lines(meths, stacks, query)
      objs = query_methods(meths, query)
      results = ReportMethod.create(objs, stacks)
      results.inject([]) {|arr, e|
        arr += e.stacks.map {|f| [e, f] }
      }
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
