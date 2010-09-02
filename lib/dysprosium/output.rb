module Dysprosium
  class Output
    def initialize(parsed_blocks)
      @parsed_blocks = parsed_blocks
    end
    
    def generate
      create_directory
      create_files
      create_index
    end
    
    private
      def create_files
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
          output = ERB.new(File.read get_template(block)).result(binding)
          File.open("#{@dir}/#{block.name}.html", 'w') do |file|
            add_file block.name
            file.puts output
          end
        end
      end

      def create_index
        # TODO: use @files to generate the index from a template
      end

      def dress_block(block)
        block.description = BlueCloth.new(block.description).to_html
        block.examples.map! do |example|
          OutputFactory::DyExample.new(example).to_html
        end
      end
      
      def dress_hash(hash)
        hash.description = BlueCloth.new(hash.description).to_html        
      end
      
      def create_directory
        @dir = Dir.pwd + '/doc'
        FileUtils.rm_rf(@dir) if File.exists? @dir
        Dir.mkdir(@dir)
      end
      
      def get_template(block)
        File.dirname(__FILE__) + "/../../templates/#{block.type}.html.erb"
      end
      
      def add_file(file, source=nil)
        @files ||= {}
        @files[file] = source || (file + '.html')
      end
  end
end
