require 'chrb_types/base'

module ChrbTypes
    class TestChrb < ChrbTypes::Base
        property      :first_prop,  :description => "First chrb property"
        property      :second_prop, :description => "Second test property"
        erb_templates '/etc/chrb_test'
    end
end
