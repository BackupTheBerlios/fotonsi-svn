require 'chrb_types/base'

module ChrbTypes
    class BadChrb < ChrbTypes::Base
        property      :wrong_prop,  :some_invalid_attr => true
        erb_templates '/etc/chrb_test'
    end
end
