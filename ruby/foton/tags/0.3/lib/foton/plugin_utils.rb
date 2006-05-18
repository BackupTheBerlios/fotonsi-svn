require 'foton/misc'

# Plugin utilities
module Foton
    module PluginUtils
        class Exception          < StandardError; end
        class BadPluginError         < Exception; end
        class NonExistentPluginError < Exception; end

        # Loads a plugin (class) from a module. It tries to load the file,
        # following a simple convention (plugin 'Foo' in module FooBar::Qux
        # should be available requiring 'foo_bar/qux/foo'). Returns the +Class+
        # object
        def load_plugin(plugin, base_module)
            alreadyLoaded            = false
            module_require_base_path = class_to_filename(base_module.to_s)
            base_module.kind_of?(Module) or raise "base_module needs to be a Module object"
            begin
                c = base_module
                plugin.split('::').each do |s|
                    unless c.constants.include? s
                        require "#{module_require_base_path}/#{class_to_filename(plugin)}"
                        c.constants.include?(s) or
                                raise BadPluginError, "Bad plugin #{plugin}: '#{module_require_base_path}/#{class_to_filename(plugin)}' required but can't find #{c}::#{s}"
                    end
                    c = c.const_get(s)
                end
                return c
            rescue LoadError => e
                raise NonExistentPluginError, "Can't find '#{plugin}': #{e}"
            rescue NameError => e
                raise BadPluginError, "Can't load '#{plugin}' from #{base_module}: #{e}"
            end
        end

        module_function :load_plugin
    end
end
