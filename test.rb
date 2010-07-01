require 'lib/dysprosium/file_parser'
require 'pp'

d = Dysprosium::FileParser.new 'test.js'
pp d.parse