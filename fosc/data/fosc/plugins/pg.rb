# PostgreSQL plugin for FOSC

$types = { "id"       => "serial",
           "memo"     => "text",
           "currency" => "decimal(10,2)",
           "datetime" => "timestamptz",
           "binary"   => "bytea",
           "float"    => "double precision",
           "bool"     => "boolean",
         }

require 'plugins/base_plugin'

module Fosc
   module Plugins
      class Pg < BasePlugin
         def export(bd)
            foreignKeys = Array.new
            structure = Array.new
            bd.elements('table').each do |t|
               list = Array.new
               extraLines = Array.new
               primaryKeys = Array.new
               newSequences = Array.new
               t.fields.each do |c|
                  type = c.type
                  if c.name == "id" or c.attributes.include? "primary"
                     primaryKeys << c.name
                     isPrimary = true
                  else
                      isPrimary = false
                  end
                  if c.reference
                     foreignKeys << "ALTER TABLE #{t.name} ADD FOREIGN KEY (#{c.name}) REFERENCES #{c.reference[0]} (#{c.reference[1]});"
                  end

                  # Collect interesting field attributes
                  if isPrimary and c.attributes.include? "values_from"
                     type = 'integer'
                     seq = c.attribute_value("values_from")
                     extra = " DEFAULT nextval('#{seq}') UNIQUE NOT NULL"

                     newSequences << seq
                  else
                     extra = ""
                  end

                  extra << " UNIQUE" if c.attributes.include? "unique"
                  extra << " NOT NULL" if c.attributes.include? "notnull"
                  extra << " DEFAULT #{c.attribute_value('default')}" if c.attributes.include? "default"
                  extraLines << "  CHECK (#{c.name} <> ''::#{$types[type] || type})" if c.attributes.include? "nonempty"

                  # Add only_values check
                  if c.attributes.include? "only_values"
                     checkText = c.attribute_value('only_values').split(',').map {|i| "#{c.name} = #{i}"}.join(" OR ")
                     extraLines << "  CHECK (#{checkText})"
                  end

                  # Add complete line to the field definitions
                  list << "  #{c.name} #{$types[type] || type}#{c.params ? '('+c.params+')' : ''}#{extra}"
               end
               # Collect multiple foreign keys
               t.attributes.each do |a|
                  next unless a.name == 'multifk'
                  nombreTabla = a.props.keys.reject {|p| p == 'src' || p == 'dst' }[0]
                  foreignKeys << "ALTER TABLE #{t.name} ADD FOREIGN KEY (#{a.props['src']}) REFERENCES #{nombreTabla} (#{a.props['dst']});"
               end
               extraLines << "  PRIMARY KEY(#{primaryKeys.join(', ')})" unless primaryKeys.empty?

               # First, sequences
               structure << '' 
               newSequences.each { |s| structure << "CREATE SEQUENCE #{s};"}
               # And now, the actual table
               structure << "CREATE TABLE #{t.name} ("
               structure << (list + extraLines).join(",\n")
               structure << ");\n"
               # And then, indexes
               t.attributes.each do |a|
                  next unless a.name == 'index'
                  indexName = a.props['name']
                  fieldNames = a.props['columns']
                  unique = a.props.has_key?('unique') ? 'UNIQUE ' : ''
                  structure << "CREATE #{unique}INDEX #{indexName} ON #{t.name} ( #{fieldNames} );"
                  indexName.nil? or indexName == '' and $stderr.puts "Error: Índice sin nombre en la tabla #{t.name}"
                  fieldNames.nil? or fieldNames == '' and $stderr.puts "Error: Campos vacíos para el índice #{indexName} en la tabla #{t.name}"
               end
            end # tables

            bd.elements('view').each do |view|
                fields = view.fields.map { |f| "#{f.name} AS #{f.fieldAlias}" }.join(", ")
                structure << "CREATE VIEW #{view.name} AS SELECT #{fields} #{view.sqlDefinition};"
            end

            # Now we print structure or integrity or both in this order
            if ['all', 'structure'].include? @options['output']
              puts(structure.join("\n"))
            end
            if ['all', 'integrity'].include? @options['output']
              puts(foreignKeys.join("\n"))
            end
         end
      end
   end
end
