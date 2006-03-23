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
               primaryKeys = Array.new
               t.fields.each do |f|
                  type = f.type
                  if f.name == "id" or f.attributes.include? "primary"
                     primaryKeys << f.name
                  end
                  list << "  #{f.name} #{$tipos[type] || type}#{f.params ? '('+f.params+')' : ''}"
               end
               extras << "PRIMARY KEY (#{primaryKeys.join(', ')})" unless primaryKeys.empty?
               puts((list + extras).join(",\n"))
               puts ");\n"
            end
         end
      end
   end
end
