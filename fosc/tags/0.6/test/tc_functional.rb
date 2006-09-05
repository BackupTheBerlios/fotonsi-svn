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

    def test_t_command_line_switch
        expected = <<EOS
CREATE TABLE some_table (
  id serial,
  some_field int,
  PRIMARY KEY(id)
);
EOS
        assert_fosc_output(expected, 'test-access.fos', 'pg -t some_table', :skip_lines => 1)
    end

    def test_timestamp
        found = false
        each_fosc_output_line('test-pg1.fos', 'pg') do |line|
            found = true if line =~ /^--- FILE GENERATED FOR/
        end
        assert(found)
    end

    def test_bigint
        expected = <<EOS
CREATE TABLE some_table (
  some_col bigint
);
EOS
        assert_fosc_output(expected, 'test-pg3.fos', 'pg', :skip_lines => 1)
    end


end
