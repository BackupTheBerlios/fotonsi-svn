# Derechos de autor: Esteban Manchado Velázquez 2004
# Licencia: GPL

require 'test/unit'
require 'fosc'

class TC_Fosc <Test::Unit::TestCase
   def setup
      @conv = Fosc::FosConverter.new
   end
   def test_file1
      db = @conv.convert_file('test/test1.fos')

      assert_equal(1, db.tables.length)
      some_table = db.tables[0]
      assert_equal('some_table', some_table.name)
      assert_equal(2, some_table.fields.length)
      assert(some_table.fields[1].attributes.include?('unique'))
   end
   def teardown
      @conv = nil
   end
end
