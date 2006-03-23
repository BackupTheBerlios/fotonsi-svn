# Derechos de autor: Fotón Sistemas Inteligentes 2004
# Licencia: GPL

Dir.entries('test').find_all {|e| e =~ /^tc_.*\.rb/}.each do |e|
   require "test/#{e}"
end

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
