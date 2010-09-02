module Dysprosium::Structure
  class DyModule
    include DyPrimary

    def type
      'module'
    end

    def initialize(comments_list)
      super comments_list.shift, comments_list
    end
  end  
end
