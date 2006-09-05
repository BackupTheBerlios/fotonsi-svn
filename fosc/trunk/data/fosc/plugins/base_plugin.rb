module Fosc
    module Plugins
        # Generic exception
        class FosPluginError < RuntimeError; end

        # Base Fosc output plugin
        class BasePlugin
            def initialize(options={})
                @options = options
            end
            
            def generation_timestamp
                "FILE GENERATED FOR #{self.class.name.upcase} AT #{Time.now}"   
            end
        end
    end
end
