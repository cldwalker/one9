change 'Module#constants', 'Returns array of symbols instead of array of strings'
change Module.methods.grep(/_methods$/).map {|e| "Module##{e}" } , 'Returns array of symbols instead of array of strings'
change Kernel.methods.grep(/_variables$/).map {|e| "Kernel.#{e}" }, 'Returns array of symbols instead of array of strings'
change 'Kernel.proc', 'Same as Proc.new instead of being same as lambda'
change 'Hash#to_s', 'An alias of #inspect instead of a spaceless join of the elements'
change 'Hash#select', 'Returns a hash instead of an association array'
change 'Array#to_s', 'An alias of #inspect instead of a spaceless join of the elements'
change 'FileUtils#mkdir_p', 'Returns an array containing directory instead of the directory'
change 'Date.parse', 'mm/dd/yyyy syntax does not exist anymore'
change 'Time.parse', 'mm/dd/yyyy syntax does not exist anymore'
change 'Proc#arity', 'Number of parameters that would not be ignored instead of ...'
delete 'Array#choice', 'Use Array#sample instead'
delete 'Kernel#to_a', 'Replace with Array()'
delete 'Object#type', 'Replace with #class'
delete 'Array#nitems', "Replace with #compact.size"
delete 'Enumerable#enum_with_index', 'Replace with #to_enum.with_index'
delete 'Symbol#to_int'
delete 'Hash#indices', 'Replace with #values_at'
delete 'Array#indices', 'Replace with #values_at'
delete 'Exception#to_str', 'Replace with #to_s'

# * BUGGY *
# doesn't work when preloaded ('-r') in rails
# change 'Object#=~', 'Returns nil instead of false'
# causes memory leaks
# change 'String#[]', 'Returns string instead of number'
#
# too many false positives with Array()
# delete 'String#to_a', 'Replace with Array()'
# delete 'String#each', 'Use String#each_line instead'
