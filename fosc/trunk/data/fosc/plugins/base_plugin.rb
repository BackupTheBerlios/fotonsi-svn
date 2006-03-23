module Fosc
   module Plugins
      # Generic exception
      class FosPluginError < RuntimeError; end

      # Base Fosc output plugin
      class BasePlugin
         def initialize(options={})
            @options = options
         end
      end
   end
end
