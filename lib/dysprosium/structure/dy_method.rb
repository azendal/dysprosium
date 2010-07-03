module Dysprosium::Structure
  class DyMethod
    include DyBase
    attr_accessor :returns, :arguments, :dispatches
    
    def parse
      set_collection :returns
      set_collection :arguments
      set_collection :dispatches, :dispatch
      
      super
    end
  end  
end
