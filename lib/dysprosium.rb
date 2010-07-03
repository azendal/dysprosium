require 'rubygems'
gem 'bluecloth'
require 'bluecloth'
require 'erb'
require 'fileutils'

module Dysprosium
  base_dir = File.dirname(__FILE__) + '/dysprosium/'
  autoload :FileParser, base_dir + 'file_parser.rb'
  autoload :Structure, base_dir + 'structure.rb'
  autoload :Output, base_dir + 'output.rb'
  autoload :OutputFactory, base_dir + 'output_factory.rb'
  
  def self.parse(files)
    parsed_blocks = files.map do |file|
      file_parser = Dysprosium::FileParser.new file
      comments_block = file_parser.parse
      case comments_block.first['type']
      when 'class'
        Structure::DyClass.new(comments_block)
      when 'module'
        Structure::DyModule.new(comments_block)
      else
        'Error: Doesn\'t looks like a documentation comment block.'
      end
    end
    output = Output.new(parsed_blocks)
    output.generate
  end
end

Dy = Dysprosium
