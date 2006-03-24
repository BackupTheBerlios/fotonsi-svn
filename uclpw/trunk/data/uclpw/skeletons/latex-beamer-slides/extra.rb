require 'ftools'

class SkeletonProcessor
   def post_process
      # Rename slides.tex to the final name
      File.move('slides.tex', projectName+'.tex')
   end
end
