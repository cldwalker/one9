module One9
  module Report
    extend self

    def print(meths, stacks)
      FileUtils.touch lock_file
      Hirb.enable
      results = ReportMethod.create(meths, stacks)
      results = results.select {|e| e.count > 0 }
      puts "\n** One9 Report **"
      return puts('No 1.9 changes found') if results.size.zero?
      puts Hirb::Helpers::AutoTable.render(results,
       :fields => [:name, :count, :message, :type, :stacks],
      :filters => { :stacks => [:join, ','] })
    end

    def later(meths, stacks)
      File.unlink(lock_file) if File.exists?(lock_file)
      at_exit { print_and_save(meths, stacks) }
    end

    def setup
      return warn("one9 hasn't profiled anything. Run it with your test suite first.") unless
        File.exists? marshal_file
      One9.setup
      File.open(marshal_file, 'rb'){|f| Marshal.load(f.read ) }
    end

    def print_files(query=nil)
      meths, stacks = setup
      if meths && stacks
        objs = query ? meths.select {|e| e.name[/#{query}/] } : meths
        results = ReportMethod.create(objs, stacks)
        results = results.inject([]) {|arr, e|
          arr += e.stacks.map {|f| [e.name, f] }
        }
        puts Hirb::Helpers::AutoTable.render(results, :change_fields => [:name, :file])
      end
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
