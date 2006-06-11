require 'ftools'
require 'find'

class SkeletonProcessor
    def pre_process
    end

    def post_process

        dirs = []
        files = []
        Find.find('.') do |f|
            if FileTest.directory?(f)
                dirs.push(f)
            else
                files.push(f)
            end
        end

        (files + dirs).each  { |f|
            if File.basename(f).include?('_application_')
                File.move(f, 
                        File.dirname(f) + '/' + 
                        File.basename(f).sub('_application_', project_name))
            end
        }
    end
end
