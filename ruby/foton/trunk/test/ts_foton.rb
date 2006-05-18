# Derechos de autor: Esteban Manchado Velázquez 2005
# Licencia: GPL

require 'test/tc_foton'
require 'test/tc_plugin_loader'
require 'test/tc_plugin_utils'
require 'test/tc_latex_pdf_compiler'

class TS_Foton
   def self.suite
      suite = Test::Unit::TestSuite.new
      ObjectSpace.each_object(Class) do |o|
         next unless o.name =~ /^TC_/
         suite << o.suite
      end
      return suite
   end
end
