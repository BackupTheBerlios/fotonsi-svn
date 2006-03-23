require 'elements/base_element'

module Fosc
   module Elements
      class FakeElementForTesting < BaseElement
         attr_reader :data

         def import(data)
            @data = data
         end
      end
   end
end
