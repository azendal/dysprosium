module Dysprosium::OutputFactory
  class DyExample
    attr_accessor :tag
    def initialize(tag)
      @tag = tag
    end
    
    def to_html
      BlueCloth.new(output).to_html
    end
    
    private
      def output
        if (@tag.name[0] == ?' && @tag.name[-1] == ?') ||
          (@tag.name[0] == ?" && @tag.name[-1] == ?")
          "#### #{@tag.name}\n\n#{@tag.description}"
        else
          "#{@tag.name} #{@tag.description}"
        end
      end
  end
end