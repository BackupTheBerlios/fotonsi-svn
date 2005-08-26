# FOSC internal in-memory representation of database information

module Fosc
   class DataBase
      attr_reader :name, :path

      def initialize(path)
         @path = path
         @name = File.basename(path, '.fos')
         @elements = []
      end

      def elements(ofType = nil)
         ofType ? @elements.find_all {|e| e.type == ofType} :
                  @elements
      end

      def new_element(element)
         @elements << element
      end

      # Compatibility
      alias_method :new_table, :new_element
      def tables
         elements('table')
      end
   end
end
