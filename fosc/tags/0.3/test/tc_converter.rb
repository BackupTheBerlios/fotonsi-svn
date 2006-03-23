# Derechos de autor: Esteban Manchado Velázquez 2004
# Licencia: GPL

require 'test/unit'
require 'fosc/db'
require 'fosc'
$: << 'test/lib'

class TC_Converter <Test::Unit::TestCase
   def setup
      @conv = Fosc::FosConverter.new
   end
   def test_elements
      db = @conv.convert_file('test/test-elements.fos')
      assert_equal(3, db.elements.length)
      assert_equal(2, db.tables.length)
      assert_equal(1, db.elements('fake_element_for_testing').length)
   end
   def teardown
      @conv = nil
   end
end
