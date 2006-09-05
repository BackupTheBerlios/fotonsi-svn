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
                "FILE GENERATED FOR #{plugin_name.upcase} AT #{Time.now}"   
            end

            def plugin_name
                self.class.name.sub(/.*::/, '')
            end
        end
    end
end
