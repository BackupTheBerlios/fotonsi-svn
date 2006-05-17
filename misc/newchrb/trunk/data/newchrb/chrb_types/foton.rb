require 'chrb_types/base'

module ChrbTypes
    class Foton < ChrbTypes::Base
        property      :intranet, :description => "Is the new chroot going to be installed in Foton's intranet?", :default => "y", :type => :boolean
        erb_templates '/etc/hosts',     # Procesa /etc/hosts.erb -> /etc/hosts
                      '/etc/apt/sources.list'
    end
end
