# MySQL plugin for FOSC

$tipos = { "id"       => "bigint auto_increment",
           "memo"     => "text",
           "currency" => "decimal(10,2)",
           "binary"   => "blob",
         }

require 'plugins/base_plugin'

module Fosc
    module Plugins
        class Mysql < BasePlugin
            def export(bd)
                bd.tables.each do |t|
                    puts "CREATE TABLE #{t.name} ("
                    list = Array.new
                    extras = Array.new
                    primary_keys = Array.new
                    t.fields.each do |f|
                        type = f.type
                        if f.name == "id" or f.attributes.include? "primary"
                            primary_keys << f.name
                        end
                        list << "  #{f.name} #{$tipos[type] || type}#{f.params ? '('+f.params+')' : ''}"
                    end
                    extras << "PRIMARY KEY (#{primary_keys.join(', ')})" unless primary_keys.empty?
                    puts((list + extras).join(",\n"))
                    puts ");\n"
                end
            end
        end
    end
end
