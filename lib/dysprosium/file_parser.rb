module Dysprosium
  class FileParser
    TAGS_RGXP = /\n?\s*@(\w+)\s*(\w+)?(?:\s+\<([\w\|]+)\>)?(?:\s+\[([\w\|]+)\])?(?:\s+\(([^\)]+)\))?(?:\s+((?:.|\n(?!\s*@))+))?/
    COMMENTS_RGXP = /\/\*{2}((?:.(?!\*{2}\/)|\n(?!\*{2}\/))+.)\n?\*{2}\//
    DESCRIPTION_RGXP = /((?:.|\n(?!\s*@))+)/
    TAG_ATTRIBUTES = %w{tag name flags types code description}
    
    def initialize(file)
      @file = file
    end

    def parse
      @source = File.read(@file)
      extract_comments
    end

    private
      def extract_comments
        @source.scan(COMMENTS_RGXP).flatten.map do |comment|
          extract_description(comment)
        end
      end
      
      def extract_description(comment)
        hash = { 'description' => nil, 'tags' => [] }
        tags = comment.scan(DESCRIPTION_RGXP).flatten
        hash['description'] = tags.shift unless tags.first =~ /\A\s*@/
        tags.each do |tag|
          hash['tags'] << extract_tag(tag)
        end
        hash
      end
      
      def extract_tag(tag)
        Hash[*tag.match(TAGS_RGXP).captures.each_with_index.map do |attribute, index|
          [TAG_ATTRIBUTES[index], attribute]
        end.flatten]
      end
  end  
end

puts Dysprosium::FileParser.new('test.js').parse.inspect
