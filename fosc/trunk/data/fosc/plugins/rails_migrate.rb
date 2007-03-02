# RailsMigrate plugin for FOSC
#
# Generate a rails migration based on the differences with the current database
#
# At this moment, fosc have to be called in the root directory of the application

RAILS_TYPES = {
    "time" => "time",
    "timestamp" => "timestamp",
    "int" => "integer",
    "bigint" => "integer",
    "smallint" => "integer",
    "id" => "primary_key",
    "datetime" => "datetime",
    "bool" => "boolean",
    "float" => "float",
    "currency" => "float",
    "varchar" => "string",
    "char" => "string",
    "memo" => "text",
    "binary" => "binary",
    "date" => "date",
}

class Hash
    def to_code
        map {|k,v| "#{k.inspect} => #{v.inspect}"} .join(", ")
    end
end

class Fosc::Elements::Table

    def add_index(index)
        res = "add_index #{name.inspect}, "
        res << index['columns'].inspect
        res << ", :unique => true" if index["unique"]
        res << ", :name => #{index['name'].inspect}\n"
        res
    end

    def remove_index(index)
        "remove_index #{name.inspect}, :name => #{index["name"].inspect}"
    end
end

class Fosc::Elements::Table::TableField
    def to_migration
        at_options = {}
        at_options[:null] = (not attributes.include?("notnull"))

        if attributes.include?("default")
            at_options[:default] = attribute_value("default")
        end
        if data_type == "varchar" and params
            at_options[:limit] = params.to_i
        end

        return (RAILS_TYPES[data_type] || data_type).to_sym, at_options
    end

    def pg_foreign_key
        r = reference
        "ALTER TABLE #{table_name} ADD FOREIGN KEY (#{name}) REFERENCES #{r[0]} (#{r[1]});"
    end

    def str_migration
        type, at_options = to_migration
        res = "#{name.inspect}, #{type.inspect}"
        res << ", #{at_options.to_code}" unless at_options.empty?
        res
    end
end


ENV['RAILS_ENV'] ||= 'development'

require 'config/environment'

class ActiveRecord::ConnectionAdapters::Column
    def str_migration
        res = "#{name.inspect}, #{type.inspect}"
        res << ", :limit => #{limit.inspect}" if limit
        res << ", :default => #{default.inspect}" if default
        res << ", :null => false" unless null
        res
    end
end

# We need access to private methods. I can't imagine why ActiveRecord guys
# think that it is a good idea hide this methods :-/
module ActiveRecord
    class SchemaDumper
        class <<self
            def public_new *args; new(*args); end
        end

        def public_table *args; table(*args); end
    end
end


require 'plugins/base_plugin'
module Fosc
    module Plugins
        class RailsMigrate < BasePlugin
            def export(fosc_bd)
                @fosc_bd = fosc_bd
                @code_up = StringIO.new
                @code_down = StringIO.new
                @header = ''

                tables = find_table_diffs(fosc_bd)

                if tables[:created].size > 0
                    @header << "  # Created tables:\n"
                    tables[:created].each {|t| @header << "  #    #{t}\n" }
                    @header << "\n"

                    tables[:created].each {|table|
                        table = table_definition(table)
                        ct_options = {}
                        pk = table.fields.find {|f| f.primary_key? }
                        if pk.nil?
                            ct_options[:id] = false
                        elsif pk.name != "id"
                            ct_options[:primary_key] = pk.name
                        end
                        @code_up << "    create_table #{table.name.inspect}"
                        @code_up << ", #{ct_options.to_code}" unless ct_options.empty?
                        @code_up << " do |t|\n"

                        foreign_keys = []

                        table.fields.each {|field|
                            next if field.primary_key?
                            @code_up << "      t.column #{field.str_migration}\n"

                            # is it a foreign key?
                            foreign_keys << field.pg_foreign_key if field.reference
                        }

                        @code_up << "    end\n"

                        if foreign_keys.size > 0
                            @code_up << "\n"
                            foreign_keys.each {|fk|
                                @code_up.puts "    execute #{fk.inspect}"
                            }
                            @code_up << "\n"
                        end

                        # Indexes
                        table.attributes.each {|attribute|
                            next unless attribute.name == "index"
                            @code_up.puts "    " + table.add_index(
                                                    "name" => attribute.props["name"],
                                                    "columns" => attribute.props['columns'].split(','),
                                                    "unique" => attribute.props.has_key?("unique"))
                        }
                        @code_up << "\n"

                        # self.down method:
                        @code_down << "    drop_table #{table.name.inspect}\n"
                    }

                    @code_down << "\n"
                end

                if tables[:removed].size > 0
                    @header << "\n  # Removed tables:\n"
                    tables[:removed].each {|t| @header << "  #    #{t}\n" }
                    @header << "\n"

                    dumper = ActiveRecord::SchemaDumper.public_new(ActiveRecord::Base.connection)
                    tables[:removed].each {|table|
                        @code_up.puts "    drop_table #{table.inspect}\n"
                        filter = StringIO.new
                        dumper.public_table(table, filter)

                        filter.rewind
                        @code_down.print '  ' + filter.read.gsub("\n ", "\n   ")
                    }

                end

                # Analize the other tables to detect changes in the columns
                tables[:kept].each {|table|
                    #
                    # First, compare the fields

                    table = table_definition(table)

                    bd_fields = ActiveRecord::Base.connection.columns(table.name)
                    bd_fields_names = bd_fields.map {|f| f.name }.sort
                    fosc_fields_names = table.fields.map {|f| f.name }.sort

                    if bd_fields_names != fosc_fields_names
                        _x = "\n    # Modified table: #{table.name}\n\n"
                        @code_up << _x
                        @code_down << _x
                    end


                    # Added fields
                    (fosc_fields_names - bd_fields_names).each {|field|
                        field = table.fields.find {|f| f.name == field }
                        @code_up << "    add_column #{table.name.inspect}, #{field.str_migration}\n"
                        @code_down << "    remove_column #{table.name.inspect}, #{field.name.inspect}\n"

                        if field.reference
                            @code_up << "    execute #{field.pg_foreign_key.inspect}\n"
                        end

                    }

                    # Removed fields
                    (bd_fields_names - fosc_fields_names).each {|field|
                        field = bd_fields.find {|f| f.name == field }
                        @code_up << "    remove_column #{table.name.inspect}, #{field.name.inspect}\n"
                        @code_down << "    add_column #{table.name.inspect}, #{field.str_migration}\n"
                    }

                    # Modified files
                    (bd_fields_names & fosc_fields_names).each {|field|
                        bd_field = bd_fields.find {|f| f.name == field }
                        fosc_field = table.fields.find {|f| f.name == field }

                        next if fosc_field.primary_key? # Primary keys are untouchable, like Eliot Ness

                        type, at_options = fosc_field.to_migration

                        if type.to_s != bd_field.type.to_s or
                            at_options[:limit] != bd_field.limit or
                            (at_options[:null] != bd_field.null) or
                            at_options[:default] != bd_field.default

                            @code_up << "    change_column #{table.name.inspect}, #{fosc_field.str_migration}\n"
                            @code_down << "    change_column #{table.name.inspect}, #{bd_field.str_migration}\n"
                        end
                    }


                    #
                    # Check the indexes
                    #
                    bd_indexes = ActiveRecord::Base.connection.indexes(table.name)

                    fosc_indexes = []
                    table.attributes.each {|at|
                        next unless at.name == "index"
                        fosc_indexes << {
                            "name" => at.props["name"] || "index_#{table.name}_#{at.props["columns"].tr(",", "_")}",
                            "columns" => at.props["columns"].split(','),
                            "unique" => at.props.has_key?("unique")
                        }
                    }

                    bd_indexes_names = bd_indexes.map {|i| i.name}.sort
                    fosc_indexes_names = fosc_indexes.map {|i| i["name"]}.sort

                    # Added indexes
                    (fosc_indexes_names - bd_indexes_names).each {|index|
                        index = fosc_indexes.find {|i| i["name"] == index }
                        @code_up.puts "    " + table.add_index(index)
                        @code_down.puts "    " + table.remove_index(index)
                    }

                    # Removed indexes
                    (bd_indexes_names - fosc_indexes_names).each {|index|
                        index = bd_indexes.find {|i| i.name == index }
                        @code_up.puts "    " + table.remove_index(index)
                        @code_down.puts "    " + table.add_index(index)
                    }

                    # Modified indexes
                    (fosc_indexes_names & bd_indexes_names).each {|index|
                        fosc_index = fosc_indexes.find {|i| i["name"] == index }
                        bd_index = bd_indexes.find {|i| i.name == index }

                        if (!fosc_index["unique"] != !bd_index["unique"]) or
                            (fosc_index["columns"].sort != bd_index["columns"].sort)

                            @code_up.puts "    " + table.remove_index(bd_index)
                            @code_up.puts "    " + table.add_index(fosc_index)

                            @code_down.puts "    " + table.remove_index(fosc_index)
                            @code_down.puts "    " + table.add_index(bd_index)
                        end
                    }

                }

                #
                # Print the generated code to stdout
                #
                @code_up.rewind
                @code_down.rewind

                puts "  # This file was autogenerated at #{Time.now}"
                puts @header
                puts "  def self.up"
                puts @code_up.read
                puts "  end\n\n"
                puts "  def self.down"
                puts @code_down.read
                puts "  end"
            end

            def find_table_diffs(fosc_bd)
                fosc_names = fosc_bd.elements('table').map {|t| t.name }
                bd_names = ActiveRecord::Base.connection.tables

                bd_names.delete('schema_info') # ignore schema_info table

                if it = @options["ignore_tables"]
                    bd_names = bd_names - it
                    fosc_names = fosc_names - it
                end

                if lt = @options["limit_tables"]
                    bd_names = bd_names & lt
                    fosc_names = fosc_names & lt
                end

                {
                    :created => fosc_names - bd_names,
                    :removed => bd_names - fosc_names,
                    :kept => bd_names & fosc_names
                }
            end

            def table_definition(table_name)
                @fosc_bd.elements('table').find {|t| t.name == table_name }
            end

        end
    end
end
