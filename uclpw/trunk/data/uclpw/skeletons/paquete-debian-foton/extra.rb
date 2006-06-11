require 'ftools'

class SkeletonProcessor
   def post_process
      File.chmod(0755, 'debian/rules')
   end
end
