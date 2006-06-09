# Copyright Fotón Sistemas Inteligentes 2006
# License: GPL

Dir.entries('test').find_all {|e| e =~ /^tc_.*\.rb/}.each do |e|
   require "test/#{e}"
end

class TS_NewChrb
   def self.suite
      suite = Test::Unit::TestSuite.new
      ObjectSpace.each_object(Class) do |o|
         next unless o.name =~ /^TC_/
         suite << o.suite
      end
      return suite
   end
end
