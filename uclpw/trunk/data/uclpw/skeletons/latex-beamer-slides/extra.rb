require 'ftools'

class SkeletonProcessor
   def post_process
      # Rename slides.tex to the final name
      File.move('slides.tex', project_name+'.tex')
   end
end
