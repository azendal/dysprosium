module Dysprosium::Structure::DyBase
  module ClassMethods
  end
  
  module InstanceMethods
    attr_accessor :definition_block
    attr_accessor :description
    attr_accessor :notes, :todos, :examples
    
    def initialize(definition_block)
      @definition_block = definition_block
      super(@definition_block['tags'].find { |tag| tag['tag'] == @definition_block['type'] })
      @description = extract_description(@definition_block['description'])

      parse
    end
    
    def parse
      set_collection :notes
      set_collection :todos
      set_collection :examples
    end
    
    protected
      def set_collection(collection_name, singular_name=nil)
        collection_name = collection_name.to_s
        singular_name ||= collection_name[0...-1]
        singular_name = singular_name.to_s
        tags = @definition_block['tags'].select { |tag| tag['tag'] == singular_name }.map do |tag| 
          Dysprosium::Structure::DyTag.new(tag)
        end
        instance_variable_set :"@#{collection_name}", tags
          
      end
      
      def extract_description(original_description)
        description = []
        first_character = original_description.index(/[^\s]/)
        original_description.each_line do |line|
          description << line[first_character-1..-1]
        end
        description.join.strip
      end
  end
  
  def self.included(receiver)
    receiver.class_eval do
      include Dysprosium::Structure::DyBaseTag
    end
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
