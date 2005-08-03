# Derechos de autor: Esteban Manchado Velázquez 2004
# Licencia: GPL

require 'test/unit'
require 'plugins/pg'
require 'fosc'

class TC_Pg <Test::Unit::TestCase
   def setup
      @conv = Fosc::FosConverter.new
      @pgPlugin = Fosc::Plugins::Pg.new
      @db = @conv.convert_file('test/test-pg1.fos')
   end
   def test_only_values
      onlyValuesCheckFound = false
      File.popen('ruby -w bin/fosc test/test-pg1.fos pg') do |f|
         f.each_line do |line|
            if line =~ /CHECK \(some_col = 'a' OR some_col = 'b' OR some_col = 'c'\)/
               onlyValuesCheckFound = true
            end
         end
      end
      assert(onlyValuesCheckFound)
   end
   def teardown
      @conv = nil
   end
end
