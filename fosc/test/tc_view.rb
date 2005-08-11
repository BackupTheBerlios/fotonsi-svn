# Derechos de autor: Esteban Manchado Velázquez 2004
# Licencia: GPL

require 'test/unit'
require 'elements/view'
require 'fosc'

class TC_View <Test::Unit::TestCase
   def test_import
      viewElement = Fosc::Elements::View.new('some_view').import(<<'EOD')
         t1.a
         t1.b as b1
         t2.b AS b2
         c
         ~~~~~~~~~~~
         FROM t1 LEFT JOIN t2 ON t1.c = t2.c
EOD
      assert_equal(4, viewElement.fields.size,     "Number of view fields")
      assert_equal('some_view', viewElement.name,  "View name")
      assert_equal("FROM t1 LEFT JOIN t2 ON t1.c = t2.c",
                        viewElement.sqlDefinition.strip,
                                                   "View SQL definition")
      # Check contents
      fields = [ { :name => 'a', :fieldAlias => nil, :table => 't1' },
                 { :name => 'b', :fieldAlias => 'b1', :table => 't1' },
                 { :name => 'b', :fieldAlias => 'b2', :table => 't2' },
                 { :name => 'c', :fieldAlias => nil, :table => nil } ]
      fields.each_index do |i|
         fields[i].each_pair do |a, v|
            assert_equal(v, viewElement.fields[i].send(a),
                                                   "Compare #{a} attribute, index #{i}")
         end
      end
   end
end
