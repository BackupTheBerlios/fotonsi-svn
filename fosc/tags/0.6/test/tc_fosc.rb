# Derechos de autor: Esteban Manchado Velázquez 2004
# Licencia: GPL

require 'test/unit'
require 'fosc'
require 'elements/base_element'

class TC_Fosc <Test::Unit::TestCase
    def setup
        @conv = Fosc::FosConverter.new
    end

    def test_plugin_loader
        assert_raises(Fosc::Elements::NonExistentElementError) do
            db = @conv.convert_file('test/test-element-non-existent.fos')
        end
        assert_raises(Fosc::Elements::InvalidElementError) do
            db = @conv.convert_file('test/test-element-invalid.fos')
        end
    end

    def teardown
        @conv = nil
    end
end
