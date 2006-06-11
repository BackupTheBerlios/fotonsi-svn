require 'fileutils'
require 'ftools'

module UCLPW
    VERSION = '0.21'

    class Exception < StandardError; end
    class ExistingOutputDirError < Exception; end
    class UnknownSkeletonError < Exception; end

    # UCLPW template processor
    class SkeletonProcessor
        attr_reader   :vars, :vars_file
        attr_reader   :skeleton_dirs
        attr_accessor :ignore_list

        DEFAULT_IGNORE_LIST   = ['*.jpg', '*.png', '*.gif', '*.gz', '*.bzip2']
        DEFAULT_SKELETON_DIRS = ['/usr/share/uclpw/skeletons']
        VAR_LINE_REGEXP       = /^([A-Z_]+)\s*=\s*(.*)/i

        def initialize(project_name, skeleton, skeleton_dirs = DEFAULT_SKELETON_DIRS)
            @vars       = { 'APPLICATION_ID' => project_name, }
            @skeleton   = skeleton
            @vars_file  = 'vars'
            @ignore_list = DEFAULT_IGNORE_LIST
            self.skeleton_dirs = skeleton_dirs
            get_skeleton(@skeleton)

            # Load the skeleton 'extra' module
            begin
               require File.join(output_dir, 'extra')
            rescue LoadError
            end
        end

        def project_name
            File.basename(output_dir)
        end

        def output_dir
            @vars['APPLICATION_ID']
        end

        def skeleton_dirs=(new_dirs)
            @skeleton_dirs = (new_dirs.kind_of? Array) ? new_dirs :
                                                         [ new_dirs ]
        end

        # Get a list of pairs [var_name, var_default_value] for the current
        # skeleton
        def get_vars
            var_list = []
            File.foreach(File.join(output_dir, vars_file)) do |line|
                next if line =~ /^#/    # Drop comment lines
                line =~ VAR_LINE_REGEXP
                var, default_value = $1, $2
                var_list << [var, (default_value || '').strip]
            end
            var_list
        end

        # Find every file recursively and substitute %{var_name}-style macros
        def process_dir
            execute_hook :pre_process
            process_dir_rec(output_dir)
            execute_hook :post_process
        end

        def update_vars_file(file = nil)
            file       ||= File.join(output_dir, @vars_file)
            tmp_file   = file + '.tmp'
            # Read everything, dump to a temp file...
            File.open(tmp_file, "w") do |out_f|
                File.foreach(file) do |line|
                    out_f.puts line.gsub(VAR_LINE_REGEXP) {|s| "#{$1} = #{vars.key?($1) ? vars[$1] : $2}"}
                end
            end
            # ...then move the temp file to the original path
            File.move(tmp_file, file)
        end

        def cleanup_dir
            cleanup_dir_rec(output_dir)
            File.safe_unlink(File.join(output_dir, 'extra.rb'))
        end


        protected

        # Gets skeleton
        def get_skeleton(name)
            # Is the output directory available?
            if FileTest.exists? output_dir
               raise ExistingOutputDirError, "'#{output_dir}' already exists"
            end

            @skeleton_dirs.each do |d|
                dir = File.join(d, name)
                if FileTest.exists? dir
                    FileUtils.cp_r dir, output_dir
                    return true
                end
            end
            raise UnknownSkeletonError, "Couldn't find skeleton '#{name}'"
        end

        def execute_hook(which)
            if respond_to? which
                old_dir = Dir.pwd
                Dir.chdir output_dir
                send(which)
                Dir.chdir old_dir
            end
        end

        def process_dir_rec(dir)
            Dir.foreach(dir) do |f|
                next if f =~ /^\.\.?$/
                next if @ignore_list.find { |pat| File.fnmatch(pat, f) }

                f = File.join(dir, f)
                if FileTest.directory? f
                    process_dir_rec(f)
                else
                    f_temp = f + "~"
                    File.move(f, f_temp)
                    File.open(f, "w") do |out_f|
                        File.foreach(f_temp) do |l|
                            out_f.puts l.gsub(/%\{([a-zA-Z0-9_]+)\}/) {|s|
                                vars.key?($1) ? vars[$1] : s
                            }
                        end
                    end
                end
            end
        end

        def cleanup_dir_rec(dir)
            Dir.foreach(dir) do |f|
                next if f =~ /^\.\.?$/
                f = File.join(dir, f)
                if FileTest.directory? f
                    cleanup_dir_rec(f)
                elsif f =~ /~$/      # Temp file
                    File.safe_unlink(f)
                end
            end
        end
    end
end
