# Derechos de autor: Esteban Manchado Velázquez 2005
# Licencia: GPL

require 'test/tc_page'
require 'test/tc_form'

class TS_Remix_Widgets
   def self.suite
      suite = Test::Unit::TestSuite.new
      ObjectSpace.each_object(Class) do |o|
         next unless o.name =~ /^TC_/
         suite << o.suite
      end
      return suite
   end
end
