require 'foton'

module Fosc
   module Elements
      # Useful constants
      TILDE_SEPARATOR_LINE = /^\s*~+\s*$/

      # Base exception class
      class Exception < RuntimeError; end

      # Bad syntax exception
      class FosSyntaxError < Exception
         attr_reader :msg, :line, :details
         def initialize(msg, line, details=nil)
            @msg, @line, @details = msg, line, details
         end
      end

      # Non-existent element
      class NonExistentElementError < Exception
         def initialize(plugin_name, original_exception)
            @plugin_name = plugin_name
            @message = original_exception.message
         end
      end

      # Invalid element
      class InvalidElementError < Exception
         def initialize(plugin_name, original_exception)
            @plugin_name = plugin_name
            @message = original_exception.message
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


         # Generic element attribute (with optional properties)
         class ElementAttribute
            attr_reader :name, :props

            def self.import(string)
               chunks = string.split(' ')
               el = new(chunks.first)
               chunks[1..-1].each do |t|
                  if t =~ /^([a-z0-9_]+)\((([^()]+|\([^()]*\))*)\)/i
                     el.new_prop($1, $2)
                  else
                     el.new_prop(t)
                  end
               end
               el
            end

            def initialize(name)
               @name  = name
               @props = {}
            end

            def new_prop(name, value=nil)
               @props[name] = value
            end
         end
      end
   end
end
