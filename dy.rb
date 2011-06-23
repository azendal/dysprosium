require 'rubygems'
require 'bundler/setup'
require 'bluecloth'
require 'erb'
require 'fileutils'
require 'json'
require 'mustache'
require 'ruby-debug'

module Dysprosium
  
    def self.generate_doc_for(sources, template)
        source_codes   = [sources] unless sources.is_a? Array
        parsed_sources = parse source_codes
        index          = generate_index_from parsed_sources
        
        parsed_sources.each do |parsed_source|
            next if parsed_source.nil? || parsed_source[:type].nil?
            html_code = generate_file "#{template}/#{parsed_source[:type]}.erb", parsed_source
            File.open("#{template}/#{parsed_source[:name]}.html", 'w').puts(html_code)
        end unless parsed_sources.nil?
         
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
        
        index = {
            :objects    => [],
            :interfaces => [],
            :modules    => [],
            :classes    => [],
            :attributes => [],
            :methods    => []
        }
        
        parsed_sources.each do |parsed_source|
            next if parsed_source.nil?
            
            (index[parsed_source[:type].to_sym] ||= []) << parsed_source if parsed_source[:type]
            
            (parsed_source[:attribute] || []).each do |attribute|
                index[:attributes] << attribute
            end
            
            (parsed_source[:method] || []).each do |method|
                index[:methods] << method
            end
            
        end unless parsed_sources.nil?
        
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

    module Parser
        TAGS_RGXP         = /\n?\s*@(\w+)(?:\s+((?:\w+)|(?:\"[^\"]+\"))+)?(?:\s+\<([\w\,]+)\>)?(?:\s+\[([\w\|]+)\])?(?:\s+\(([^\)]+)\))?(?:\s+\'?((?:.|\n(?!\s*@))+))?/
        COMMENTS_RGXP     = /\/\*{2}((?:.(?!\*{2}\/)|\n(?!\*{2}\/))+.)\n?\*{2}\//
        DESCRIPTION_RGXP  = /((?:.|\n(?!\s*@))+)/
        IDENTATION_SPACES = /^([^@\w]+)/
        
        def self.parse(source)
            comments      = get_comments_from(source)
            parsed_source = comments.shift
            comments.each do |comment|
                next if comment[:type].nil?
                (parsed_source[comment[:type].to_sym] ||= []) << comment
            end
            parsed_source
        end
        
        def self.get_comments_from(source)
            source.scan(COMMENTS_RGXP).flatten.map do |comment_block|
                parts             = get_parts_from comment_block
                identation_spaces = get_identation_spaces_from parts.first
                description       = clean_description(parts.shift, identation_spaces) unless parts.first =~ /\^\s*@\w+/
                tags              = []
                
                parts.each do |tag_str|
                    match_result = tag_str.match(TAGS_RGXP)
                    
                    next if match_result.nil?
                    
                    tag_captures = match_result.captures

                    tags << {
                        :type        => tag_captures[0] || '',
                        :name        => tag_captures[1].nil? ? '' : tag_captures[1].gsub(/^\"|\"$/, ''),
                        :flags       => tag_captures[2].nil? ? [] : tag_captures[2].split(','),
                        :types       => tag_captures[3].nil? ? [] : tag_captures[3].split('|'),
                        :code        => tag_captures[4] || '',
                        :description => tag_captures[5].nil? ? '' : clean_description(tag_captures[5], identation_spaces)
                    }
                end

                comment = tags.shift || {}
                comment[:description] = description unless description.empty?

                tags.each do |tag|
                    (comment[tag[:type].to_sym] ||= []) << tag
                end

                comment
            end
        end
        
        def self.get_parts_from(comment_block)
            comment_block.scan(DESCRIPTION_RGXP).flatten
        end
        
        def self.get_identation_spaces_from(description)
            Regexp.new description.match(IDENTATION_SPACES).captures[0]
        end
        
        def self.clean_description(description, identation_spaces)
            apply_blue_cloth_on description.gsub(identation_spaces, "\n").gsub(/^\n|\n$/, '')
        end
        
        def self.apply_blue_cloth_on(text)
            BlueCloth.new(text).to_html
        end
    end
end

Dy = Dysprosium

source = <<EOS
/**
Test
Provides the functionality to "paginate" and "slide" content for the breezi application stack
    new Breezi.Api.Scroller

@class Scroller2
@namespace Breezi.Api
@requires Neon
@requires Elastic
@requires jQuery
@jslint_test 2010-09-15

@author Fernando Trasviña
**/
Class(Breezi.Api, 'Scroller2')({
    
    /**
    Holds the default element class value
    @attribute ELEMENT_CLASS <public,static> [String] ('scroller') well what the hell
        sadas;laskd 
    **/
    ELEMENT_CLASS : 'scroller',
    
    /**
    Holds the default html structure
    @attribute HTML <public,static> [String]
    **/
    HTML : '\
        <div>\
        	<div class="prev"></div>\
        	<div class="scrollable">\
        	    <div class="items-container">\
        	    </div>\
        	</div>\
        	<div class="next"></div>\
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
        Holds the reference to the button that acts as the prev button
        @attribute prevElement <public,static> [jQuery] (null)
        **/
        prevElement : null,
        
        /**
        flag that sets if the prevElement button is visible
        @attribute displayPrevElement <public,static> [jQuery] (null)
        **/
        displayPrevElement : true,
        
        /**
        Holds the reference to the button that acts as the next button
        @attribute nextElement <public,static> [jQuery] (null)
        **/
        nextElement : null,
        
        /**
        flag that sets if the nextElement button is visible
        @attribute displayNextElement <public,static> [jQuery] (null)
        **/
        displayNextElement : true,
        
        /**
        Holds the reference to the element that contains the element with the items
        this is part of the desired structure because Scroller is based on scrollTop
        and scrollLeft properties of this element instead of position absolutes.
        @attribute scrollableElement <public,static> [jQuery] (null)
        **/
        scrollableElement : null,
        
        /**
        Holds the reference to the element tha contains the items of the scroller
        this element must always be a direct child of scrollableElement. This is
        the element that gets moved when you scroll.
        @attribute nextElement <public,static> [jQuery] (null)
        **/
        itemsContainerElement : null,
        
        /**
        Holds the reference to the items class to find them, this can also be a css selector
        @attribute itemSelector <public,static> [string] ('.item')
        **/
        itemSelector   : '.item',
        
        /**
        Holds the reference to the initial scroll position. You must override this on the contructor
        beacuse its a pointer and will get overriden by other instances.
            init : function(config){
                this.currentPosition = {
                    x : 0,
                    y : 0
                };
                //...
            }
        @attribute currentPosition <public,static> [Object] ({
            x : 0,
            y : 0
        })
        **/
        currentPosition : {
            x : 0,
            y : 0
        },
        
        /**
        Initializes the Scroller Widget
        @method init <public,constructor> [Scroller]
        @argument config <required> [Object] an object that contains all the attributes you may
        want to set to the instance
        **/
        init : function(config){
            
            this.currentPosition = {
                x : 0,
                y : 0
            };
            
            $.extend(this, config);
            
            this._buildDomStructure()
                ._bindDomEvents()
                ._setupItemsContainerElement();
        },
        
        /**
        builds the Dom structure for the scroller, this takes into consideration that
        this elements may be passed on the configuration.
        @method _buildDomStructure <protected> [Breezi.Api.Scrollable]
        @return scrollable
        **/
        _buildDomStructure : function(){
            if(!this.element){
                this.element = $(this.constructor.HTML).addClass(this.constructor.ELEMENT_CLASS);
            }
            
            if(!this.prevElement && this.displayPrevElement){
                this.prevElement = this.element.find('.prev');
            }
            
            if(!this.nextElement && this.displayNextElement){
                this.nextElement = this.element.find('.next');
            }
            
            if(!this.scrollableElement){
                this.scrollableElement = this.element.find('.scrollable');
            }
            
            if(!this.itemsContainerElement){
                this.itemsContainerElement = this.scrollableElement.find('.items-container');
            }
            
            return this;
        },
        
        /**
        binds the widget so it can listen to the appropiate DOM events
        @method _bindDomEvents <protected> [Breezi.Api.Scrollable]
        @return scrollable
        **/
        _bindDomEvents : function(){
            var scrollable;
            
            scrollable = this;
            if(this.prevElement){
                this.prevElement.bind('click', function(){
                    console.log('scrollPrev');
                    scrollable.scrollPrev();
                });
            }
            if(this.nextElement){
                this.nextElement.bind('click', function(){
                    console.log('scrollNext');
                    scrollable.scrollNext();
                });
            }
            return this;
        },
        
        /**
        Sets the right width to the itemsContainerElement so the scroller does not have to do 
        any further computations, this also avoids the developer the need to this manually
        @method _setupItemsContainerElement <protected> [Breezi.Api.Scrollable]
        @return scrollable
        **/
        _setupItemsContainerElement : function(){
            var itemsWidth;
            
            itemsWidth = 0;
            
            this.itemsContainerElement.find(this.itemSelector).each(function(){
                itemsWidth += $(this).outerWidth(true);
            });
            
            this.itemsContainerElement.css({
                width : itemsWidth + 'px'
            });
            return this;
        },
        
        /**
        Moves the scroller one page left if its possible to do it
        @method scrollPrev <public> [Breezi.Api.Scrollable]
        @argument items [Number] (null) the number of items that must be scrolled
        if not passed it assumes that you can go to next page
        @return scrollable
        **/
        scrollPrev : function(items){
            var x, y;
            
            x = this.currentPosition.x - this.scrollableElement.width();
            if(items){
                x = this.currentPosition.x - this.scrollableElement.find(this.itemSelector).width() * items;
            }
            y = this.currentPosition.y;
            this.currentPosition = this.scrollTo(x,y);
            return this;
        },
        
        /**
        Moves the scroller one page right if its possible to do it
        @method scrollNext <public> [Breezi.Api.Scrollable]
        @argument items [Number] (null) the number of items that must be scrolled
        if not passed it assumes that you can go to next page
        @return scrollable
        **/
        scrollNext : function(items){
            var x, y;
            
            x = this.currentPosition.x + this.scrollableElement.width();
            if(items){
                x = this.currentPosition.x - this.scrollableElement.find(this.itemSelector).width() * items;
            }
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
            var x, y, itemPosition;
            
            item = this.scrollableElement.find(this.itemSelector)[index];
            x = this.currentPosition.x - $(item).attr('offsetLeft');
            y = this.currentPosition.y;
            return this.scrollTo(x,y);
        },
        
        /**
        Scrolls the content to the desired position
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
			
			this.currentPosition = {
			    x : this.scrollableElement.attr('scrollLeft'),
			    y : this.scrollableElement.attr('scrollTop')
			}
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
			
			return this;
		}
    }
});
EOS

puts Dy::generate_doc_for('breezi/widget/loading_bar.js', 'default')
# puts Dy::generate_doc_for(source, 'default')
