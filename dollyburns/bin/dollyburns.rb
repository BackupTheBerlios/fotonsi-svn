#!/usr/bin/ruby -w

require 'yaml'

require 'plugin_loader'
require 'dollyburns/error_handler'

begin
   confFile = '/etc/dollyburns.conf'
   load confFile
rescue LoadError => e
   $stderr.puts "Can't read configuration file #{confFile}: #{e}"
   exit 1
end

# Use constants from the configuration file
pluginLoader = PluginLoader.new(PluginDir)
errorHandler = DollyBurns::ErrorHandler.new(FromEmail, Email,
                                                   (defined? SmtpServer) ? SmtpServer : 'localhost',
                                                   (defined? SmtpPort) ? SmtpPort : 25)

# Process ".d" directory entries
entries = Dir["#{ConfDir}/*.yml"].entries
if entries.length == 0
   $stderr.puts "Can't find any dump definition in #{ConfDir}"
else
   entries.each do |dd|
      confStruct = YAML::load_file(dd)
      if not confStruct.kind_of? Hash
         errorHandler.message("Wrong dump definition '#{dd}'")
         next
      end
      email = confStruct['email']
      if not confStruct['dumpType']
         errorHandler.message("Wrong dump definition '#{dd}': no defined dump type", email)
         next
      end

      begin
         clonator = pluginLoader.plugin(confStruct['dumpType'],
                                        [ File.basename(dd).sub(/\.yml$/, ''),
                                          confStruct['params'],
                                          errorHandler ])
      rescue PluginLoadError => e
         errorHandler.message("Couldn't load '#{dd}', ignoring it: #{e}", email)
         next
      rescue => e
         errorHandler.message("Internal error loading '#{dd}': #{e}", email)
      end
      clonator.clone_item
   end
end
