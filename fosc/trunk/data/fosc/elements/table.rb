require 'elements/base_element'

module Fosc
    module Elements
        # When trying to access a non-existent field
        class UnknownFieldError < StandardError; end

        class Table < BaseElement
            attr_reader :fields, :attributes

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
                line_number = 0
                data.each do |line|
                    line_number = line_number.next
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
                            raise FosSyntaxError.new(@name, "You have to specify the type for field #{chunks[0]}", line_number)
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
                        chunks[1..-1].each do |t|
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
                        raise FosSyntaxError, "Unexpected content: #{line}"
                    end
                end
                self
            end

            def clean
                @name = nil
                @fields.clear
            end

            def new_field(field)
                @fields << field
            end

            # Returns true if the table has no fields
            def empty?
                @fields.length == 0
            end

            def new_attribute(attr)
                @attributes << attr
            end

            # Name-based field access
            def [](field_name)
                field = @fields.find {|f| f.name == field_name}
                field ? field : raise(UnknownFieldError, "Can't find field '#{field_name}'")
            end


            # Table field
            class TableField
                attr_accessor :name, :data_type, :data_type_param, :reference
                attr_reader :attributes
                alias_method :type, :data_type
                alias_method :params, :data_type_param
                alias_method :dataType, :data_type
                alias_method :"dataType=", :"data_type="
                alias_method :dataTypeParam, :data_type_param
                alias_method :"dataTypeParam=", :"data_type_param="

                def initialize(name, type, data_type_param = nil)
                    @name = name
                    @data_type = type
                    @data_type_param = data_type_param
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
