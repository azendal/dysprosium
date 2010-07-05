module Dysprosium::Structure::DyPrimary
  module ClassMethods
  end
  
  module InstanceMethods
    attr_accessor :comment_blocks
    attr_accessor :includes, :requires, :events
    attr_accessor :attributes, :methods
    
    def initialize(definition_block, comment_blocks)
      @comment_blocks = comment_blocks
      super definition_block
    end
    
    def parse
      set_collection :includes
      set_collection :requires
      set_collection :events
      
      super
      attributes_extractor
      methods_extractor
    end

    def type
    end

    private
      def attributes_extractor
        @attributes = extract_collection(:attribute) do |attribute| 
          Dysprosium::Structure::DyAttribute.new(attribute)
        end
      end
    
      def methods_extractor
        @methods = extract_collection(:method) { |method| Dysprosium::Structure::DyMethod.new(method) }
      end
    
      def extract_collection(type)
        type = type.to_s
        @comment_blocks.select { |block| block['type'] == type }.map do |block|
          yield(block) if block_given?
        end
      end
  end
  
  def self.included(receiver)
    receiver.class_eval do
      include Dysprosium::Structure::DyBase
    end
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
