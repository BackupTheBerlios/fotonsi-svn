# Derechos de autor: Esteban Manchado Velázquez 2005
# Licencia: GPL

require 'test/unit'
require 'foton/misc'

class TC_Foton <Test::Unit::TestCase
   def test_class_to_filename_and_back
      fileList = [['some_easy_file', 'SomeEasyFile'],
                  ['ibm', 'Ibm'],
                  ['i_b_m', 'IBM']]
      fileList.each do |f|
         assert_equal(f[1], filename_to_class(f[0]),
                                                "filename_to_class")
         assert_equal(f[0], class_to_filename(filename_to_class(f[0])),
                                                "filename_to_class and back")
      end
   end
end
