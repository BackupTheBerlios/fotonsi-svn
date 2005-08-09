=begin
= Format

Each view is made up of as much lines as there are fields in it. Each one can
have an alias, to be used in the SQL definition. An example:

 a
 t1.b as b1
 t2.b as b2
 t2.c
 ~~~~~~~~~~~
 FROM t1 LEFT JOIN t2 ON t1.c = t2.c
=end

require 'elements/base_element'

module Fosc
   module Elements
      class View < BaseElement
         attr_reader :fields, :sqlDefinition

         def initialize(*args)
            super
            @sqlDefinition = ""
            @fields  = []
         end

         def import(data)
            state = 'fields'
            lineNumber = 0
            data.each do |line|
               lineNumber = lineNumber.next
               if state == 'fields'
                  # «Extra» block begins
                  if line =~ /^\s*~+\s*$/
                     state = 'sql_def'
                     next
                  end

                  # Field definition
                  line =~ /^\s*([a-z0-9_]+\.)?([a-z0-9_]+)(\s+as\s+([a-z0-9_]+)?\s*)?$/i
                  optTable, fieldName, optAlias = $1, $2, $4
                  $2 or raise FosFormatError.new("Syntax error in view #{name}",
                                                 lineNumber,
                                                 "Can't find field name in #{line}")
                  @fields << ViewField.new(fieldName, optTable, optAlias)
               elsif state == 'sql_def'
                  # Table definition ends
                  if line == ''
                     state = ''
                     next
                  end
                  # SQL definition
                  @sqlDefinition += line
               else
                  # Skip blank lines
                  next if line == ''
                  raise FosFormatError, "Unexpected content: #{line}"
               end
            end
            @sqlDefinition != '' or raise FosFormatError, "View definition without SQL definition"
            self
         end


         # View field
         class ViewField
            attr_accessor :name, :fieldAlias, :table

            def initialize(name, table, fieldAlias = nil)
               @name       = name
               @table      = table
               @fieldAlias = fieldAlias
            end
         end
      end
   end
end
