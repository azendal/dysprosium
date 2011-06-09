require 'rubygems'
gem 'bluecloth'
require 'bluecloth'
require 'erb'
require 'fileutils'
require 'ostruct'
require 'json'
require 'mustache'

module Dysprosium
    base_path = File.dirname(__FILE__)
    autoload :Parser, "#{base_path}/parser"
    autoload :Tag,    "#{base_path}/tag"
    
    def self.generate_doc_for(sources, template)
        source_codes   = [sources] unless sources.is_a? Array
        parsed_sources = parse source_codes
        index          = generate_index_from parsed_sources
        
        # parsed_sources.each do |parsed_source|
        #     html_code = generate_file "#{template}/#{parsed_source[:type]}.mustache", parsed_source
        #     File.open("#{template}/#{parsed_source[:name]}.html", 'w').puts(html_code)
        # end
        
        index_file = generate_file "#{template}/index.erb", index
        File.open("#{template}/index.html", 'w').puts(index_file)
    end
    
    def self.parse(sources)
        sources.map do |source|
            source_code = (File.exists? source) ? File.read(source) : source
            Parser.parse source_code
        end
    end
    
    def self.generate_index_from(parsed_sources)
        
        index = Project.new({
            :objects    => [],
            :interfaces => [],
            :modules    => [],
            :classes    => [],
            :attributes => [],
            :methods    => []
        })
        
        parsed_sources.each do |parsed_source|
            
            index[:objects]    << parsed_source if parsed_source[:type] == 'object'
            index[:modules]    << parsed_source if parsed_source[:type] == 'modules'
            index[:classes]    << parsed_source if parsed_source[:type] == 'class'
            index[:interfaces] << parsed_source if parsed_source[:type] == 'interface'
            
            (parsed_source[:attribute] || []).each do |attribute|
                index[:attributes] << attribute
            end
            
            (parsed_source[:method] || []).each do |method|
                index[:methods] << method
            end
            
        end
        
        index[:attributes].sort! do |a,b|
            b[:name] <=> a[:name]
        end
        
        index[:methods].sort! do |a,b|
            b[:name] <=> a[:name]
        end
        
        index
    end
    
    def self.generate_file(template, data)
        ERB.new(File.read(template)).result(data.send(:binding))
        #Mustache.render(File.read(template), data)
    end
end

Dy = Dysprosium

source = <<EOS
/**
Provides the functionality to "paginate" and "slide" content for the breezi application stack
    new Breezi.Api.Scroller

@class Scroller
@namespace Breezi.Api
**/
Class(breezi.Api, 'Scroller')({
    
    /**
    Holds the default element class value
    @attribute ELEMENT_CLASS <public,static> [String] ('scroller') well what the hell
    **/
    ELEMENT_CLASS : 'scroller',
    
    /**
    Holds the default html structure
    @attribute HTML <public,static> [String]
    **/
    HTML : '\
        <div>\
        	<div class="next"></div>\
        	<div class="scrollable">
        	    <div class="items-container">
        	    </div>
        	</div>\
        	<div class="prev"></div>\
        </div>\
    ',
    
    /**
    Holds the instance methods fot the class
    @attribute prototype <public,static> [Object]
    **/
    prototype : {
        
        /**
        Holds the reference to the main element of the widget
        @attribute element <public,static> [jQuery] (null)
        **/
        element : null,
        
        /**
        Holds the reference to the items class to find them
        @attribute itemClass <public,static,prototype> [string] ('.item')
        **/
        itemClass   : '.item',
        
        /**
        Initializes the Scroller Widget
        @method init <public,constructor> [Scroller]
        @argument config <required> [Object] an object that contains all the attributes you may
        want to set to the instance
        **/
        init : function(config){
            $extend(this, config);
            
            if(!this.element){
                this.element = $(this.constructor.HTML).addClass(this.constructor.ELEMENT_CLASS);
            }
            
            if(!this.prevElement){
                this.prevElement = this.element.find('.prev');
            }
            
            if(!this.nextElement){
                this.nextElement = this.element.find('.next');
            }
            
            if(!this.scrollableElement){
                this.scrollableElement = this.element.find('.scrollable');
            }
            
            if(!this.itemsContainerElement){
                this.itemsContainerElement = this.scrollableElement.find('.items-container');
            }
            
            this._bindDomEvents();
        },
        
        /**
        binds the widget so it can listen to the appropiate DOM events
        @method _bindDomEvents <protected> [Breezi.Api.Scrollable]
        @return scrollable
        **/
        _bindDomEvents : function(){
            var scrollable = this;
            this.prevElement.bind('click', function(){
                scrollable.scrollPrev();
            });
            this.prevElement.bind('click', function(){
                scrollable.scrollNext();
            });
            return this;
        },
        
        /**
        Moves the scroller one page left if its possible to do it
        @method scrollPrev <public> [Breezi.Api.Scrollable]
        @return scrollable
        **/
        scrollPrev : function(){
            x = this.currentPosition.x - this.scrollableElement.width();
            y = this.currentPosition.y;
            this.currentPosition = this.scrollTo(x,y);
            return this;
        },
        
        /**
        Moves the scroller one page right if its possible to do it
        @method scrollNext <public> [Breezi.Api.Scrollable]
        @return scrollable
        **/
        scrollNext : function(){
            x = this.currentPosition.x + this.scrollableElement.width();
            y = this.currentPosition.y;
            return this.scrollTo(x,y);
        },
        
        /**
        Moves the scroller to the item at position "index"
        @method scrollNext <public> [Breezi.Api.Scrollable]
        @argument index <required> [Integer]
        @returns scrollable
        **/
        scrollToIndex : function(index){
            x = this.currentPosition.x + this.scrollableElement.width();
            y = this.currentPosition.y;
            return this.scrollTo(x,y);
        },
        
        /**
        Holds the reference to the main element of the widget
        @method scrollTo <public> [Scrollable]
        @argument x <required> [Integer]
        @argument y <required> [Integer]
        @returns Scrollable
        **/
        scrollTo : function(x,y){
            this.scrollableElement.animate({
				scrollTop  : y,
				scrollLeft : x
			}, 'fast');
			return this;
        },
        
        /**
        Renders the widget as last child of the specified element
        @method render <public> [Breezi.Api.Scrollable]
        @argument x <required> [HTMLElement|jQuery]
        @returns Scrollable
        **/
        render : function(context){
			this.element.appendTo(context);
			this.widgetOverlay.insertBefore(this.element.find('> .content'));
			Elastic.refresh(this.element.get(0));
			return this;
		}
    }
});
EOS

puts Dy::generate_doc_for(source, '.')