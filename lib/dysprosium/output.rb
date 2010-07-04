module Dysprosium
  class Output
    def initialize(parsed_blocks)
      @parsed_blocks = parsed_blocks
    end
    
    def generate
      create_directory
      @parsed_blocks.each do |block|
        dress_block(block)
        %w{events todos notes}.each do |subtag|
           block.send(subtag).each { |subitem| dress_hash(subitem) }
         end
        
        %w{methods attributes}.each do |tag|
          block.send(tag).each do |item| 
            dress_block(item)
           %w{dispatches todos notes returns}.each do |subtag|
              item.send(subtag).each { |subitem| dress_hash(subitem) }
            end
          end
        end
        template = get_template(block)
        output = ERB.new(File.read template).result(binding)
        File.open("#{@dir}/#{block.name}.html", 'w') do |file|
          file.puts output
        end
      end
    end
    
    private      
      def dress_block(block)
        block.description = BlueCloth.new(block.description).to_html
        block.examples.map! do |example|
          dy_example = OutputFactory::DyExample.new(example)
          dy_example.to_html
        end
      end
      
      def dress_hash(hash)
        hash.description = BlueCloth.new(hash.description).to_html        
      end
      
      def create_directory
        @dir = Dir.pwd + '/doc'
        Dir.mkdir(@dir)
      rescue
        FileUtils.rm_rf(@dir)
        Dir.mkdir(@dir)
      end
      
      def get_template(block)
        type = if Dysprosium::Structure::DyClass === block
          'class'
        elsif Dysprosium::Structure::DyModule === block
          'module'
        end
        File.dirname(__FILE__) + "/../../templates/#{type}.html.erb"
      end
  end
end
