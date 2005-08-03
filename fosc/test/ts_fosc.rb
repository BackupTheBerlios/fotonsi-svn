# Derechos de autor: Fotón Sistemas Inteligentes 2004
# Licencia: GPL

require 'test/tc_db'
require 'test/tc_fosc'
require 'test/tc_pg'
require 'test/tc_converter'

class TS_Fosc
   def self.suite
      suite = Test::Unit::TestSuite.new
      ObjectSpace.each_object(Class) do |o|
         next unless o.name =~ /^TC_/
         suite << o.suite
      end
      return suite
   end
end
