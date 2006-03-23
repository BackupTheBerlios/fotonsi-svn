# Class::DBI plugin for FOSC

require 'ftools'

require 'plugins/base_plugin'

module Fosc
   module Plugins
      class Cdbi < BasePlugin
         def export(bd, *pars)
            # Check parameters
            perlPrefix, dir = pars
            perlPrefix ||= ''
            dir        ||= '.'
            File.mkpath(dir)

            # If every table name begins with "t", correct them
            tPrefix = !(bd.tables.detect {|t| t.name =~ /^[^t]/})

            # Generate a file for each table, in directory #{dir}
            bd.tables.each do |table|
               filename  = file2perl(table.name, tPrefix)+'.pm'
               className = (perlPrefix == '' ? '' : perlPrefix+'::') +
                           file2perl(table.name, tPrefix)
               File.open(File.join(dir, filename), "w") do |file|
                  file.puts "package #{className};\n\n"
                  file.puts "use strict;\nuse warnings;\n\n"
                  file.puts "use base qw(#{perlPrefix != '' ? perlPrefix : 'Class::DBI'});\n\n";
                  file.puts "#{className}->table('#{table.name}');"

                  # Separate keys columns from the rest
                  keyColumns = table.fields.find_all {|f| f.attributes.include?  'primary'}.map {|f| f.name}
                  nonkeyColumns = table.fields.find_all {|f| !f.attributes.include?  'primary'}.map {|f| f.name}
                  file.puts "#{className}->columns(Primary => qw(#{keyColumns.join(' ')}));"
                  file.puts "#{className}->columns(Other => qw(#{nonkeyColumns.join(' ')}));"

                  # Sequence list
                  table.fields.each do |f|
                      if (f.name == 'id' or f.attributes.include? "primary") and f.attributes.include? "values_from"
                          file.puts "#{className}->sequence('#{f.attribute_value('values_from')}');"
                      end
                  end

                  # External table relations
                  # has_a
                  table.fields.each do |f|
                     if f.attributes.include? 'ext_table'
                        file.puts "#{className}->has_a(#{f.name} => '#{(perlPrefix == '' ? '' : perlPrefix+'::')+file2perl(f.reference[0], tPrefix)}');"
                     end
                  end
                  # has_many
                  childTables = Array.new
                  table.attributes.each do |a|
                     if a.name == 'has_many'
                        childTables.push a.props['name']
                        childTableName = (perlPrefix == '' ? '' : perlPrefix+'::')+file2perl(a.props['table'], tPrefix)
                        if a.props.has_key? 'refcolumn'
                           file.puts "#{className}->has_many(#{a.props['name']} => '#{childTableName}', '#{a.props['refcolumn']}');"
                        else
                           file.puts "#{className}->has_many(#{a.props['name']} => '#{childTableName}');"
                        end
                     end
                  end

                  if childTables.length > 0
                     file.print "\nsub lista_has_many {\n   (",
                            childTables.map {|t| "'#{t}'"}.join(", "),
                            ")\n}\n"
                  end

                  file.puts "\n1;"
               end
            end
         end

         def file2perl(filename, tPrefix=false)
            filename.gsub(/^t(.)/) {|s| tPrefix ? "T"+$1.capitalize :
                                                    s.capitalize}.
                     gsub(/_(.)/) {|s| $1.capitalize}
         end
      end
   end
end
