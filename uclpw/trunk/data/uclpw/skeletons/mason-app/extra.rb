require 'ftools'

class SkeletonProcessor
   def pre_process
      @vars['modulo_perl'] = project_name.capitalize.gsub(/_([a-zA-Z])/) {|s| $1.capitalize}
   end

   def post_process
      File.move('conf.ini.in', project_name+'.ini.in')
      File.move('perl/Modulo.pm', 'perl/'+@vars['modulo_perl']+'.pm')
      Dir.mkdir('perl/'+@vars['modulo_perl'])
      File.move('perl/DBI.pm', 'perl/'+@vars['modulo_perl'])
      Dir.mkdir('mason/plantillas')
      Dir.mkdir('mason/img')
      Dir.mkdir('mason/comp')
   end
end
