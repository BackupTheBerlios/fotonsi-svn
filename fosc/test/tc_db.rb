# Derechos de autor: Esteban Manchado Vel�zquez 2004
# Licencia: GPL

require 'test/unit'
require 'fosc'
require 'fosc/db'
require 'elements/table'

class TC_Db <Test::Unit::TestCase
   def setup
      @db = Fosc::DataBase.new('db_test')
   end

   def test_tables
      t = Fosc::Elements::Table.new('ttests')
      t.new_field(Fosc::Elements::Table::TableField.new('id', 'id'))
      @db.new_table(t)

      assert_equal(1, @db.tables.length)
      assert(t['id'],                            "Name-based field access")
      assert_raise(Fosc::Elements::UnknownFieldError) do
         t['nonexistent_field']
      end
   end

   def test_access
      conv = Fosc::FosConverter.new
      @db = conv.convert_file('test/test-access.fos')
      assert(@db['some_table'],                    "some_table is defined")
      assert(@db['some_view'],                     "some_table is defined")
      assert_raise(Fosc::UnknownElementError) do
         assert(@db['some_nonexistent_view'],      "access some nonexistent element")
      end
   end

   def teardown
      @db = nil
   end
end
