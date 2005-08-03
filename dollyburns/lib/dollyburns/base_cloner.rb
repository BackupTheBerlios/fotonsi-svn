# Cloner base definitions

require 'open3'

# Base class for all the cloners
class BaseCloner
   def initialize(name, params, errorHandler)
      @name         = name
      @params       = params
      @errorHandler = errorHandler
   end

   # Standard date mark for filenames
   def dateMark
      Time.now.strftime("%Y%m%d_%H%M%S")
   end

   # Returns the absolute path of the dump file
   def dumpFilename
      DumpDir + '/' + @name + '-' + dateMark
   end

   def logError(msg)
      @errorHandler.message(msg, @params['email'])
   end

   def execute_cmd_line(cmd_line)
      stdin, stdout, stderr = Open3.popen3(cmd_line)
      stderr = stderr.read
      if stderr != ''
         logError "Error executing '#{cmd_line}': #{stderr}"
      end
   end
end
