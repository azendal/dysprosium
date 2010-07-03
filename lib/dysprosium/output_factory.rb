module Dysprosium::OutputFactory
  base_dir = File.dirname(__FILE__) + '/output_factory/'
  autoload :DyExample, base_dir + 'dy_example.rb'  
end
