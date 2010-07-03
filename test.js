/**
## Cesium CSS runtime library

* asdas
* asdasd
@example sad asd asd asd asd asd 
@example sad asd asd asd asd asd 

@class Cesium
**/
var Cesium, Cs;
Cesium = Cs = {
    parsingString : '',
	/**
	A general configuration object for the compile time
	@attribute config <public> [Object]
    	({
    		id      : null,
    		type    : null,
    		prepend : null
    	})
	**/
	config : {
		id      : null,
		type    : null,
		prepend : null
	},
	/**
	Gets a transformed selector for the Breezi application model to avoid collisions
	@method getPrepend <public>
	@argument cssClass <required> [String] the context css class for class rewrite
	@returns [String]
	**/
	getPrepend: function(cssClass) {
		if(this.config.type === 'app') {
			// appName-templateName-appId-templateWidth-zoneAppIndex
			return '.breezi-app > .' + this.config.prepend + ' ' + cssClass;
		} else {
			return cssClass;
		}
	},
	/**
    Compiles a source code into a javascript data structure and appends all the rules
    into the provided RuleTree
        def a
          'a'
        end
	@method compile <public>
	@argument sourceCode <required> [String]
	@argument ruleTree <required> [RuleTree]
	@argument options <optional> [Object] (undefined)
	@returns [Boolean]
	**/
	compile: function(sourceCode, ruleTree, options) {
		var parseCode; 
		
		if(options){
			$.extend(this.config, options);
		}
        
        parsedCode = Cesium.Parser.Selectors.parse(sourceCode);
        
        $.each(parsedCode.value.rules, function() {
            var rule = ruleTree.createRule();
            $.extend(rule, this.value);
            
            ruleTree.appendChild(rule);
            $.each(rule.attributes, function(attribute, property) {
            	$.each(rule.selectors, function(){
            		if(ruleTree.ruleTreeGroup.dirtyRules[this.toString()] && 
					ruleTree.ruleTreeGroup.dirtyRules[this.toString()][attribute]){
            			property.value = ruleTree.ruleTreeGroup.dirtyRules[this.toString()][attribute];
            		}
            	});
                if(property.type === 'function_value') {
                	if(!property.value){
                    	var value = property.function_value.apply(ruleTree);
                    
                		var digitValue = parseInt(value,10);
                		if(!isNaN(digitValue)){
                			value = digitValue + 'px';
                		}
                		//rule.setAttribute(attribute, value);
                		rule.attributes[attribute].value = value;
                	}
                	else{
                		//rule.setAttribute(attribute, property.value);
                		rule.attributes[attribute].value = property.value;
                	}
                    $.each(property.dependencies, function() {
                        var dependency = ruleTree.getRuleBySelector(this.selector);
                        if(dependency){
                            dependency.bind('change:' + this.property, function(e){
                            	var value = property.function_value.apply(ruleTree);
                            	var digitValue = parseInt(value,10);
                            	if(!isNaN(digitValue)){
                            		value = digitValue + 'px';
                            	}
                            	rule.setAttribute(attribute, value);
                            	//rule.attributes[attribute].value = value;
                            });
                        }
                    });
                }
            });
        });
        ruleTree.ruleTreeGroup.element(ruleTree.ruleTreeGroup.toCss());
        this.config = {};
        return true;
    }
};
