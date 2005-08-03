# Derechos de autor: Esteban Manchado Velázquez 2004
# Licencia: GPL

require 'test/unit'
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
   end
   def teardown
      @db = nil
   end
end
