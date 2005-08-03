require 'dollyburns/base_cloner'

class Mysql < BaseCloner
   def clone_item
      cmd_line = "LC_ALL=C mysqldump -u #{@params['user']}"
      cmd_line += " -p"+@params['password'] if @params['password']
      cmd_line += " #{@params['database']} >#{dumpFilename}"
      execute_cmd_line cmd_line
   end
end
