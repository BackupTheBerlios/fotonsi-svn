require 'chrb_types/base'

module ChrbTypes
    class PropertyTest < ChrbTypes::Base
        property      :first_prop,  :description => "First chrb property",
                                    :default => "some default value"
        property      :second_prop, :description => "Second test property",
                                    :type => :boolean
        erb_templates '/etc/chrb_test'
    end
end
