# Class::DBI plugin for FOSC

require 'ftools'

require 'plugins/base_plugin'

module Fosc
    module Plugins
        class Cdbi < BasePlugin
            def export(bd, *pars)
                # Check parameters
                perl_prefix, dir = pars
                perl_prefix ||= ''
                dir        ||= '.'
                File.mkpath(dir)

                # If every table name begins with "t", correct them
                t_prefix = !(bd.tables.detect {|t| t.name =~ /^[^t]/})

                # Generate a file for each table, in directory #{dir}
                bd.tables.each do |table|
                    filename  = file2perl(table.name, t_prefix)+'.pm'
                    class_name = (perl_prefix == '' ? '' : perl_prefix+'::') +
                    file2perl(table.name, t_prefix)
                    File.open(File.join(dir, filename), "w") do |file|
                        file.puts "package #{class_name};\n\n"
                        file.puts "use strict;\nuse warnings;\n\n"
                        file.puts "use base qw(#{perl_prefix != '' ? perl_prefix : 'Class::DBI'});\n\n";
                        file.puts "#{class_name}->table('#{table.name}');"

                        # Separate keys columns from the rest
                        key_columns = table.fields.find_all {|f| f.attributes.include?  'primary'}.map {|f| f.name}
                        non_key_columns = table.fields.find_all {|f| !f.attributes.include?  'primary'}.map {|f| f.name}
                        file.puts "#{class_name}->columns(Primary => qw(#{key_columns.join(' ')}));"
                        file.puts "#{class_name}->columns(Other => qw(#{non_key_columns.join(' ')}));"

                        # Sequence list
                        table.fields.each do |f|
                            if (f.name == 'id' or f.attributes.include? "primary") and f.attributes.include? "values_from"
                                file.puts "#{class_name}->sequence('#{f.attribute_value('values_from')}');"
                            end
                        end

                        # External table relations
                        # has_a
                        table.fields.each do |f|
                            if f.attributes.include? 'ext_table'
                                file.puts "#{class_name}->has_a(#{f.name} => '#{(perl_prefix == '' ? '' : perl_prefix+'::')+file2perl(f.reference[0], t_prefix)}');"
                            end
                        end
                        # has_many
                        child_tables = Array.new
                        table.attributes.each do |a|
                            if a.name == 'has_many'
                                child_tables.push a.props['name']
                                child_table_name = (perl_prefix == '' ? '' : perl_prefix+'::')+file2perl(a.props['table'], t_prefix)
                                if a.props.has_key? 'refcolumn'
                                    file.puts "#{class_name}->has_many(#{a.props['name']} => '#{child_table_name}', '#{a.props['refcolumn']}');"
                                else
                                    file.puts "#{class_name}->has_many(#{a.props['name']} => '#{child_table_name}');"
                                end
                            end
                        end

                        if child_tables.length > 0
                            file.print "\nsub lista_has_many {\n   (",
                                child_tables.map {|t| "'#{t}'"}.join(", "),
                            ")\n}\n"
                        end

                        file.puts "\n1;"
                    end
                end
            end

            def file2perl(filename, t_prefix=false)
                filename.gsub(/^t(.)/) {|s| t_prefix ? "T"+$1.capitalize :
                    s.capitalize}.
                    gsub(/_(.)/) {|s| $1.capitalize}
            end
        end
    end
end
