module Fosc
   module Elements
      class FosFormatError < RuntimeError
         attr_reader :msg, :line, :details

         def initialize(msg, line, details=nil)
            @msg, @line, @details = msg, line, details
         end
      end

      # Base FOS-DB element class
      class BaseElement
         attr_reader :name

         # Creates a new element of name +name+
         def initialize(name)
            @name = name
         end

         # Element type. By default it's the (base)name of the class, converted
         # to a unix filename standard convention
         def type
            class_to_filename(self.class.to_s.sub(/.*:/, ''))
         end

         # See if the element is empty. By default, it's never empty
         def empty?; false; end

         # Split line into "tokens"
         def split_line(line)
            tmpLine = line.clone
            chunks  = []

            while tmpLine != ''
               tmpLine.sub!(/^\s*/,"")
               tmpLine.sub!(/^([a-z0-9_"]+)(\((([^()]+|\([^()]*\))*)\))?/i,"")
               break if $&.nil?
               chunks.push $& unless $& == ''
            end

            chunks
         end
      end
   end
end
