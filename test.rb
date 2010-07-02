require 'lib/dysprosium/file_parser'
require 'pp'
require 'rubygems'
require 'mustache'

d = Dysprosium::FileParser.new 'test.js'
result = d.parse

pp result

fr = result.shift
class_structure = {
    :name        => fr['tags'].select{|tag| true if tag['tag'] == 'class'}.first['name'],
    :description => fr['description'].strip,
    :examples    => fr['tags'].select{|tag| true if tag['tag'] == 'example'},
    :todos       => fr['tags'].select{|tag| true if tag['tag'] == 'todo'},
    :notes       => fr['tags'].select{|tag| true if tag['tag'] == 'note'},
    
    :inherits    => fr['tags'].select{|tag| true if tag['tag'] == 'inherits'},
    :includes    => fr['tags'].select{|tag| true if tag['tag'] == 'includes'},
    :requires    => fr['tags'].select{|tag| true if tag['tag'] == 'requires'},
    :requires    => fr['tags'].select{|tag| true if tag['tag'] == 'ensures'},
    
    :attributes  => result.select{|tag| true if tag['type'] == 'attribute'},
    :methods     => result.select{|tag| true if tag['type'] == 'method'},
    :events      => fr['tags'].select{|tag| true if tag['tag'] == 'event'}
}

class_structure[:attributes].map! do |item|
    {
        :description => item['description'].strip,   
    }.merge item['tags'][0].delete_if{|key, value| key == 'description' || key == 'tag'}
end

class_structure[:methods].map! do |item|
    {
        :description => item['description'].strip,
        :arguments   => item['tags'].select{|tag| true if tag['tag'] == 'argument'}
    }.merge item['tags'][0].delete_if{|key, value| key == 'description' || key == 'tag'}
end

pp class_structure

File.open('test.html', 'w') do |f|
    f.write Mustache.render(File.read('templates/default.mustache'), class_structure)
end