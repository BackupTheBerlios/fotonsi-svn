require 'chrb_types/base'

module ChrbTypes
    class Foton < ChrbTypes::Base
        property      :intranet, :description => "Is the new chroot going to be installed in Foton's intranet?", :default => "y", :type => :boolean
        property      :ip,       :description => "IP address (only for Foton's intranet)?"
        erb_templates '/etc/hostname',
                      '/etc/mailname'
    end
end
