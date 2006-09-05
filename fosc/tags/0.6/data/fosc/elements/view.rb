=begin
= Format

Each view is made up of as much lines as there are fields in it. Each one can
have an alias, to be used in the SQL definition. An example:

 a
 t1.b as b1
 t2.b as b2
 t2.c
 some(expression)
 some(other(expression)) as some_field
 ~~~~~~~~~~~
 FROM t1 LEFT JOIN t2 ON t1.c = t2.c
=end

require 'elements/base_element'

module Fosc
    module Elements
        class View < BaseElement
            attr_reader :fields, :sql_definition, :attributes
            alias_method :sqlDefinition, :sql_definition

            def initialize(*args)
                super
                @sql_definition = ""
                @fields         = []
                @attributes     = []
            end

            def import(data)
                state = 'fields'
                line_number = 0
                data.each do |line|
                    line_number = line_number.next
                    if state == 'fields'
                        # «Extra» block begins
                        if line =~ TILDE_SEPARATOR_LINE
                            state = 'sql_def'
                            next
                        end

                        # Field definition
                        line =~ /^\s*(([a-z0-9_]+)\.)?([a-z0-9_]+)(\s+as\s+([a-z0-9_]+)?\s*)?$/i
                        opt_table, field_name, opt_alias = $2, $3, $5
                        # Second attempt, this time looking for a random expression
                        unless field_name
                            line =~ /^\s*(.+?)(\s+as\s+([a-z0-9_]+)?\s*)?$/i
                            opt_table, field_name, opt_alias = nil, $1, $3
                        end
                        field_name or raise FosSyntaxError.new(@name, "Syntax error in view #{name}: Can't find field name in #{line}", line_number)
                        @fields << ViewField.new(field_name, opt_table, opt_alias)
                    elsif state == 'sql_def'
                        # Definition end
                        if line == ''
                            state = ''
                            next
                        elsif line =~ /^\s*~+\s*$/
                            state = 'options'
                            next
                        end
                        # SQL definition
                        @sql_definition += line
                    elsif state == 'options'
                        # Definition end
                        if line == ''
                            state = ''
                            next
                        end
                        @attributes << ElementAttribute.import(line)
                    else
                        # Skip blank lines
                        next if line == ''
                        raise FosSyntaxError.new(@name, "Unexpected content: #{line}", line_number)
                    end
                end
                @sql_definition != '' or raise FosSyntaxError.new(@name, "View definition without SQL definition", line_number)
                self
            end


            # View field
            class ViewField
                attr_accessor :name, :field_alias, :table
                alias_method :fieldAlias, :field_alias

                def initialize(name, table, field_alias = nil)
                    @name        = name
                    @table       = table
                    @field_alias = field_alias
                end
            end
        end
    end
end
