require 'pty'
require 'expect'

require 'dollyburns/base_cloner'

$expect_verbose = false

class Postgresql < BaseCloner
   def clone_item
      output = ''
      begin
         cmd_line = "LC_ALL=C pg_dump -u #{@params['database']} >#{dumpFilename}"
         PTY.spawn(cmd_line) do |r_f,w_f,pid|
            w_f.sync = true

            # User
            r_f.expect(/name/) do
               w_f.puts @params['user']
            end

            # Password
            if @params['password']
               r_f.expect(/word/) do
                  w_f.puts @params['password'] 
               end
            end
            output = r_f.read # For the process to end completely
         end
      rescue PTY::ChildExited => e
         logError "Couldn't execute command line '#{cmd_line}': #{e}"
      rescue Errno::EIO => e
         logError "Error executing '#{cmd_line}': #{e}"
      else
         if output != ''
            logError "Error executing '#{cmd_line}': #{output}"
         end
      end
   end
end
