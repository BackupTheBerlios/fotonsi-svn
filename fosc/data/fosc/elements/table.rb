require 'elements/base_element'

module Fosc
   module Elements
      class Table < BaseElement
         attr_reader :name, :fields, :attributes

         def initialize(*args)
            super
            @valid_types = [ 'id', 'int', 'float', 'smallint',
                             'char', 'varchar', 'memo', 'bool',
                             'datetime', 'date', 'time',
                             'currency', 'binary' ]
            @fields     = []
            @attributes = []
         end

         def import(data)
            state = 'table'
            lineNumber = 0
            data.each do |line|
               lineNumber = lineNumber.next
               if state == 'table'
                  # «Extra» block begins
                  if line =~ /^\s*~+\s*$/
                     state = 'extra'
                     next
                  end

                  # Field definition
                  chunks = split_line(line)
                  if chunks[0] =~ /^id/ and chunks[1].nil?
                     chunks[1] = "id"
                  end
                  if chunks[1].nil?
                     raise FosFormatError.new("Syntax error in table #{name}",
                                              lineNumber,
                                              "You have to specify the type for field #{chunks[0]}")
                  end
                  $stderr.puts "#{chunks[0]} (#{chunks[1]})" if $DEBUG
                  type = chunks[1]
                  params = nil
                  if type =~ /(.+)\((.+)\)/
                     type = $1
                     params = $2
                  end
                  # Check type in the valid types list
                  if not @valid_types.include? type
                     $stderr.puts "Warning: Non-standard type '#{type}'"
                     sleep 1
                  end
                  tmp = TableField.new(chunks[0], type, params)
                  # Skip field name and type
                  chunks[2..chunks.length].each do |t|
                     if t =~ /^ref\((.+)\((.+)\)\)/
                        tmp.reference = [$1, $2]
                     elsif t =~ /^([a-z0-9_]+)\((([^()]+|\([^()]*\))*)\)/i
                        tmp.new_attribute($1, $2)
                     else
                        tmp.new_attribute(t)
                     end
                  end
                  new_field(tmp)
               elsif state == 'extra'
                  # Table definition ends
                  if line == ''
                     state = ''
                     next
                  end
                  # Table attribute definition
                  chunks = line.split(' ')
                  tmp = TableAttribute.new(chunks[0])
                  chunks[1..chunks.length].each do |t|
                     if t =~ /^([a-z0-9_]+)\((([^()]+|\([^()]*\))*)\)/i
                        tmp.new_prop($1, $2)
                     else
                        tmp.new_prop(t)
                     end
                  end
                  new_attribute(tmp)
               else
                  # Skip blank lines
                  next if line == ''
                  raise FosFormatError, "Unexpected content: #{line}"
               end
            end
         end

         def clean
            @name = nil
            @fields.clear
         end

         def new_field(field)
            @fields << field
         end

         def empty?
            @fields.length == 0
         end

         def new_attribute(attr)
            @attributes << attr
         end


         # Table field
         class TableField
            attr_accessor :name, :type, :params, :reference
            attr_reader :attributes

            def initialize(name, type, params = nil)
               @name = name
               @type = type
               @params = params
               @reference = nil
               @attributes = Array.new
               @attr_values = Hash.new
            end

            def new_attribute(attr, value=nil)
               @attributes << attr
               @attr_values[attr] = value
            end

            def attribute_value(attr)
               @attr_values[attr]
            end
         end


         # Table attribute
         class TableAttribute
            attr_reader :name, :props

            def initialize(name)
               @name = name
               @props  = Hash.new
            end

            def new_prop(name, value=nil)
               @props[name] = value
            end
         end
      end
   end
end
