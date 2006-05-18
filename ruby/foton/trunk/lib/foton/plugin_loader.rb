# Plugin loader. Takes a directory and optionally a base class. The directory
# is the prefix directory where plugins can be found, and the optional base
# class is the class where plugins are stored.
# Each plugin is a class, loaded from a file whose name is obtained
# transforming the class name into a file name using class_to_filename from
# the 'foton' module

require 'foton/misc'

module Foton
    # Incorrect base class exception
    class PluginBaseClassError < RuntimeError; end
    # Any load error
    class PluginLoadError < RuntimeError; end

    # Plugin loader class
    class PluginLoader
        attr_reader :baseClass, :pluginDir

        def initialize (dir, baseClass=nil)
            @pluginDir = dir
            @baseClass = baseClass

            if baseClass.kind_of? String
                className  = baseClass.gsub('^([a-zA-Z]+).*', '\1')
                @baseClass = eval className
            end
        end

        # Returns a list of available plugins
        def availPlugins
            list = Array.new
            Dir.open(@pluginDir).each do |f|
                list << filename_to_class(f).sub(/\.rb$/,'') \
                        if f =~ /^[^\.].*\.rb$/
            end
            list
        end

        # Gets a plugin by name
        def plugin(c, pars=[])
            fileName = class_to_filename c

            begin
                require pluginDir + '/' + fileName
                pluginClass = eval(c.gsub('^([a-zA-Z]+).*', '\1'))
            rescue LoadError => e
                raise PluginLoadError, "Can't find plugin #{c} (file '#{fileName}').  Details: #{e}"
            rescue NameError => e
                raise PluginLoadError, "Can't load plugin #{c} (file '#{fileName}'). Details: #{e}"
            end

            begin
                obj = pluginClass.new(*pars)
            rescue ArgumentError => e
                raise PluginLoadError, "Can't load plugin #{c} (file '#{fileName}'). Details: #{e}"
            end
            if @baseClass and not obj.kind_of? @baseClass
                raise PluginBaseClassError, "#{c} is not a #{@baseClass} type plugin"
            end
            obj
        end

        # Gets a plugin by index (starts with 0)
        def pluginByIndex(i)
           plugin(avail_plugins[i])
        end
    end
end
