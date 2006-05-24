# Derechos de autor: Esteban Manchado Velázquez 2004
# Licencia: GPL

require 'test/unit'
require 'test/fosc_mixin.rb'

class TC_Functional <Test::Unit::TestCase
    include FoscMixin

    def test_only_values
        found = false
        each_fosc_output_line('test-pg1.fos', 'pg') do |line|
            if line =~ /CHECK \(some_col = 'a' OR some_col = 'b' OR some_col = 'c'\)/
                found = true
            end
        end
        assert(found)
    end

    def test_views
        found = false
        each_fosc_output_line('test-pg2.fos', 'pg') do |line|
            found = true if line =~ /SELECT DISTINCT/
        end
        assert(found)
    end
end
