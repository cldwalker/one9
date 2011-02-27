require 'aruba/cucumber'
require 'one9'
dir = Dir.pwd + '/tmp/one9'
FileUtils.mkdir_p dir
One9.dir = dir
ENV['ONE9_DIR'] = dir
