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

   def test_multiline
      wherePart = <<EOD
FROM t_entities JOIN t_nodes ON t_nodes.node_id=t_entities.node_ref
WHERE
t_entities.entity_type_ref='Usuario' AND
t_entities.entity_subtype_ref='Pmr'
EOD
      viewElement = Fosc::Elements::View.new('second_view').import(<<EOD)
t_entities.insert_date
t_entities.update_user_ref
t_entities.update_date
t_nodes.node_id
t_nodes.node_address
t_nodes.node_town_ref
t_nodes.node_municipality_ref
t_nodes.node_zone_ref
~~~~~~~~~
#{wherePart}
EOD
      assert_equal(8, viewElement.fields.size,     "Number of view fields")
      assert_equal('second_view', viewElement.name,"View name")
      assert_equal(wherePart.strip, viewElement.sqlDefinition.strip,
                                                   "View SQL definition")
      assert_equal('t_entities', viewElement.fields.first.table,
                                                   "First field table name")
   end

   def test_attributes
      viewElement = Fosc::Elements::View.new('attr_view').import(<<EOD)
a
~~~~~~~~~
FROM b WHERE c = 'f'
~~~~
distinct
EOD
      assert_equal(1, viewElement.attributes.size, "Number of attributes")
      assert_equal('distinct', viewElement.attributes.first.name,
                                                   "Attribute name")
   end

   def test_expressions
       viewElement = Fosc::Elements::View.new('attr_view').import(<<EOD)
some(strange(expression)) || 'foo'
CASE WHEN a=1 THEN 'one' WHEN a=2 THEN 'two' ELSE 'other' END AS foobar
~~~~~~~~~
FROM b WHERE c = 'f'
EOD
      assert_equal(2, viewElement.fields.size, "Number of attributes")
      assert_equal("some(strange(expression)) || 'foo'",
                   viewElement.fields[0].name,
                                                "Random expressions")
      assert_equal("CASE WHEN a=1 THEN 'one' WHEN a=2 THEN 'two' ELSE 'other' END",
                   viewElement.fields[1].name,  "More random expressions")
      assert_equal("foobar", viewElement.fields[1].fieldAlias,
                                                "Alias for random expressions")
   end
end
