require 'aruba/cucumber'
require 'one9'
dir = Dir.pwd + '/tmp/one9'
FileUtils.mkdir_p dir
ENV['ONE9_DIR'] = One9.dir = dir
ENV['ONE9_RC'] = One9.rc = dir + '/rc'
at_exit { FileUtils.rm_rf Dir.pwd + '/tmp/' }
