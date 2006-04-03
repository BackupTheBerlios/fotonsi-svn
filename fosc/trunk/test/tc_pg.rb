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

   def each_fosc_output_line(file)
      File.popen("ruby -w -Ilib bin/fosc test/#{file} pg") do |f|
         f.each_line do |line|
            yield line
         end
      end
   end

   def test_only_values
      found = false
      each_fosc_output_line('test-pg1.fos') do |line|
         if line =~ /CHECK \(some_col = 'a' OR some_col = 'b' OR some_col = 'c'\)/
            found = true
         end
      end
      assert(found)
   end

   def test_views
      found = false
      each_fosc_output_line('test-pg2.fos') do |line|
         found = true if line =~ /SELECT DISTINCT/
      end
      assert(found)
   end

   def teardown
      @conv = nil
   end
end
