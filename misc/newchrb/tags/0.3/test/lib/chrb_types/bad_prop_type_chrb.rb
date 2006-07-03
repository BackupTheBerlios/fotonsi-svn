require 'chrb_types/base'

module ChrbTypes
    class BadPropTypeChrb < ChrbTypes::Base
        property      :wrong_prop_type,  :type => :foobar
        erb_templates '/etc/chrb_test'
    end
end
