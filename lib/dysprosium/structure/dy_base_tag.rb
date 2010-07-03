module Dysprosium::Structure::DyBaseTag
  module ClassMethods
  end
  
  module InstanceMethods
    attr_accessor :tag, :name, :flags, :types, :code, :description
    
    def initialize(tag)
      @tag         = tag['tag']
      @name        = tag['name']
      @flags       = tag['flags']
      @code        = tag['code']
      @types       = tag['types']
      @description = tag['description']
    end    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
