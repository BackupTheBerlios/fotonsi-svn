# Derechos de autor: Esteban Manchado Velázquez 2004
# Licencia: GPL

require 'test/unit'
require 'fosc'
require 'fosc/db'
require 'elements/table'

class TC_Table <Test::Unit::TestCase
   def setup
      @db = Fosc::DataBase.new('db_test')
   end

   def test_tables
      t = Fosc::Elements::Table.new('ttests')
      t.new_field(Fosc::Elements::Table::TableField.new('id', 'id'))
      t.new_field(Fosc::Elements::Table::TableField.new('field', 'char', '20'))
      @db.new_table(t)

      assert_equal(1, @db.tables.length)
      assert(t['id'],                            "Name-based field access")
      assert(t['field'],                         "Name-based field access")
      assert_raise(Fosc::Elements::UnknownFieldError) do
         t['nonexistent_field']
      end

      assert_equal('20', t['field'].dataTypeParam, "dataTypeParam")
   end

   def teardown
      @db = nil
   end
end
