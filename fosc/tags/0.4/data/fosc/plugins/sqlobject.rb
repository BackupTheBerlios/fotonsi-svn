# Clase adaptadora para PostgreSQL

$types = { "id"       => "IntCol",
           "int"      => "IntCol",
           "varchar"  => "StringCol",
           "memo"     => "StringCol",
           "currency" => "CurrencyCol",
           "datetime" => "DateTimeCol",
           "binary"   => "StringCol",       # [s: no sé si ésta es la más correcta]
           "float"    => "FloatCol",
         }


def is_primary (f)
    f.name == 'id' or f.attributes.include? "primary"
end

require 'plugins/base_plugin'

module Fosc
   module Plugins
      class Sqlobject < BasePlugin
         def export(bd)
            # Add a comment in the actual module
            puts <<here1
# -*- coding: latin1 -*-

'''
This module has class definitions for SQLObject.

*Don't edit this module directly*, as it's automatically generated and you
will lose your changes. Make your changes in other module and take this as a
template, instead. For example, to add new objects

 from this_module import *

 def new_fn(..):
     ....

 class new_class(...):
     ...


If you need to add or change methods or attributes from the defined classes,
use something like


 from this_module import *

 original_ttable_class = ttable
 class ttable (original_ttable_class):
     # new methods for ttable


This module was generated #{Time.new.to_s}, and contains the following
classes:
here1

            bd.tables.each { |t| puts "    * " + t.name }
            puts <<here2
'''

from sqlobject import *

__connection__ = None      # Use Foton.FotonConnection to control this object

from Foton.SQLObject import DefaultValue, FotonSQLObject

here2

            bd.tables.each do |t|
               primaryKey = t.fields.find { |f| is_primary(f) }
               primaryKey or raise FosPluginError, "No defined primary key for '#{t.name}'"

               puts "class #{t.name}(FotonSQLObject):"
               puts "    _table = '#{t.name}'"
               puts "    _idName = '#{primaryKey.name}'"
               puts "    _idType = str" if not ["id", "integer"].include?(primaryKey.type)
               puts "    _idSequence = '#{primaryKey.attribute_value('values_from')}'" if primaryKey.attributes.include? 'values_from'
               puts

               primaryKey = true

               t.fields.each do |f|
                  type = f.type
                  if primaryKey and is_primary(f)
                     # Only get the first primaryKey
                     primaryKey = false
                     next
                  end

                  params = []

                  if ((not f.attributes.include?("notnull")) or f.attributes.include?('default'))
                     params << "default = DefaultValue"
                  end

                  puts "    #{f.name} = #{$types[f.type] || 'StringCol'} (#{params.join(', ')}) "
               end

               puts
            end
         end
      end
   end
end
