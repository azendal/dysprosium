module Dysprosium::Structure
  base_dir = File.dirname(__FILE__) + '/structure/'
  autoload :DyBase, base_dir + 'dy_base.rb'
  autoload :DyPrimary, base_dir + 'dy_primary.rb'
  autoload :DyClass, base_dir + 'dy_class.rb'
  autoload :DyAttribute, base_dir + 'dy_attribute.rb'
  autoload :DyMethod, base_dir + 'dy_method.rb'
  autoload :DyModule, base_dir + 'dy_module.rb'
  autoload :DyTag, base_dir + 'dy_tag.rb'
  autoload :DyBaseTag, base_dir + 'dy_base_tag.rb'
end
