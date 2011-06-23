/**
  Displays and manages the Breezi loading bar for a proccess.

  @class LoadingBar
  @namespace Breeze.Widget
  @requires Neon
  @requires jQuery
  @requires Breeze.Widget

  @author Aukan
 **/
Class(Breeze, 'LoadingBar').inherits(Breeze.Widget)({

    ELEMENT_CLASS : 'widget loading-bar-widget',

    HTML : '\
        <div class="loading-container hidden">\
            <div class="ek-loader">\
                <div class="loading-border"><!-- This is need for a chrome bug -->\
                    <div class="loading-bar">\
                        <div class="loading-percent" style="width: 1%;"></div>\
                    </div>\
                </div>\
                <div class="loading-info">\
                    <p>Loading...</p>\
                </div>\
            </div>\
        </div>',

    prototype : {

        element : null,
        percent : null,
        intervalCheckFunction : null,
        intervalId : null,

        init : function (config){
            this.constructor.superClass.prototype.init.call(this, config);

            this.element.css('width', document.width);
            this.element.css('height', document.height);
            this.percent = 0;
        },

        /** setProgress : function
         *
         * @percent => 0-100
         * @message is optional
         *
         * returns true if attributes were set correctly
         **/
        setProgress : function (percent, message){
            if( !percent || percent < 0 || percent > 100 ){
                return false;
            }

            this.element.find('.loading-percent').css('width', percent.toString() + "%" );
            this.percent = percent;
            this.setMessage( message );
        },

        startIntervalCheck : function (time){
            var intervalTime = (time) ? time : 5000;
            this.intervalId = setInterval( this.intervalCheckFunction, 2000 );
            this.intervalCheckFunction();
        },

        stopIntervalCheck : function(){
            clearInterval( this.intervalId );
        },

        setMessage : function (message){
            if( message ){
                this.element.find('.loading-info p').html(message);
            }
        },

        addProgress : function (deltaPercent, message){
            this.setProgress( this.percent + deltaPercent, message );
        },

        close : function (){
            var self = this;
            this.element.fadeOut('slow', function(){
                self.destroy();
            });
        },

        render : function (element, beforeElement){
            this.element.hide();
            if (element === undefined && beforeElement === undefined){
                this.element.insertBefore(document.body);
            } else {
                this.constructor.superClass.prototype.render.call(this, element, beforeElement);
            }

            this.element.removeClass('hidden');
            this.element.fadeIn('slow');
        }
    }

});
