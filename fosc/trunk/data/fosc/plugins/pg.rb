# PostgreSQL plugin for FOSC

$types = { "id"       => "serial",
           "memo"     => "text",
           "currency" => "decimal(10,2)",
           "datetime" => "timestamptz",
           "binary"   => "bytea",
           "float"    => "double precision",
           "bool"     => "boolean",
           "bigint"   => "bigint",
         }

require 'plugins/base_plugin'

module Fosc
    module Plugins
        class Pg < BasePlugin
            def export(bd)
                puts "--- #{generation_timestamp}"
                foreign_keys = Array.new
                structure = Array.new
                bd.elements('table').each do |t|
                    list = Array.new
                    extra_lines = Array.new
                    primary_keys = Array.new
                    new_sequences = Array.new
                    t.fields.each do |c|
                        type = c.data_type
                        if c.name == "id" or c.attributes.include? "primary"
                            primary_keys << c.name
                            is_primary = true
                        else
                            is_primary = false
                        end
                        if c.reference
                            foreign_keys << "ALTER TABLE #{t.name} ADD FOREIGN KEY (#{c.name}) REFERENCES #{c.reference[0]} (#{c.reference[1]});"
                        end

                        # Collect interesting field attributes
                        if is_primary and c.attributes.include? "values_from"
                            type = 'integer'
                            seq = c.attribute_value("values_from")
                            extra = " DEFAULT nextval('#{seq}') UNIQUE NOT NULL"

                            new_sequences << seq
                        else
                            extra = ""
                        end

                        extra << " UNIQUE" if c.attributes.include? "unique"
                        extra << " NOT NULL" if c.attributes.include? "notnull"
                        extra << " DEFAULT #{c.attribute_value('default')}" if c.attributes.include? "default"
                        extra_lines << "  CHECK (#{c.name} <> ''::#{$types[type] || type})" if c.attributes.include? "nonempty"

                        # Add only_values check
                        if c.attributes.include? "only_values"
                            check_text = c.attribute_value('only_values').split(',').map {|i| "#{c.name} = #{i}"}.join(" OR ")
                            extra_lines << "  CHECK (#{check_text})"
                        end

                        # Add complete line to the field definitions
                        list << "  #{c.name} #{$types[type] || type}#{c.params ? '('+c.params+')' : ''}#{extra}"
                    end
                    # Collect multiple foreign keys
                    t.attributes.each do |a|
                        next unless a.name == 'multifk'
                        nombre_tabla = a.props.keys.reject {|p| p == 'src' || p == 'dst' }[0]
                        foreign_keys << "ALTER TABLE #{t.name} ADD FOREIGN KEY (#{a.props['src']}) REFERENCES #{nombre_tabla} (#{a.props['dst']});"
                    end
                    extra_lines << "  PRIMARY KEY(#{primary_keys.join(', ')})" unless primary_keys.empty?

                    # First, sequences
                    structure << '' 
                    new_sequences.each { |s| structure << "CREATE SEQUENCE #{s};"}
                    # And now, the actual table
                    structure << "DROP TABLE #{t.name};" if @options[:drop_table]
                    structure << "CREATE TABLE #{t.name} ("
                    structure << (list + extra_lines).join(",\n")
                    structure << ");\n"
                    # And then, indexes
                    t.attributes.each do |a|
                        next unless a.name == 'index'
                        field_names = a.props['columns']
                        index_name = a.props['name'] || "index_#{t.name}_#{field_names.tr(",", "_")}"
                        unique = a.props.has_key?('unique') ? 'UNIQUE ' : ''
                        structure << "CREATE #{unique}INDEX #{index_name} ON #{t.name} ( #{field_names} );"
                        index_name.nil? or index_name == '' and $stderr.puts "Error: Índice sin nombre en la tabla #{t.name}"
                        field_names.nil? or field_names == '' and $stderr.puts "Error: Campos vacíos para el índice #{index_name} en la tabla #{t.name}"
                    end
                end # tables

                bd.elements('view').each do |view|
                    fields = view.fields.map { |f| (f.table ? "#{f.table}." : "") +
                        f.name +
                        (f.field_alias ? " AS #{f.field_alias}" : "")}.
                        join(", ")
                    optional_distinct = view.attributes.find {|a| a.name == 'distinct'} ? 'DISTINCT' : ''
                    structure << "CREATE VIEW #{view.name} AS SELECT #{optional_distinct} #{fields} #{view.sql_definition};"
                end

                # Now we print structure or integrity or both in this order
                if ['all', 'structure'].include? @options['output']
                    puts(structure.join("\n"))
                end
                if ['all', 'integrity'].include? @options['output']
                    puts(foreign_keys.join("\n"))
                end
            end
        end
    end
end
