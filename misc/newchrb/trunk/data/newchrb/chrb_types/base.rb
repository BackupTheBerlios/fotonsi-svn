require 'foton/misc'
require 'fileutils'

module ChrbTypes
    # Exceptions
    class Exception < StandardError; end
    class MissingPropertyError < Exception
        def initialize(message, missing_prop, given_props)
            @message      = message
            @missing_prop = missing_prop
            @given_props  = given_props
        end
    end
    class ChrbNotFoundError < Exception; end
    class BadChrbTemplateError < Exception; end
    class UnpackError < Exception; end

    CHRB_BASE_DIRECTORY = 'root'

    class Property
        VALID_TYPES = [:string, :number, :boolean]

        attr_reader :name, :description, :default, :type

        def initialize(name, opts)
            @name        = name
            @description = name
            @default     = nil
            @type        = :string
            @opts        = opts
            opts.each_pair do |opt,value|
                case opt
                when :description
                    @description = value
                when :default
                    @default = value
                when :type
                    if VALID_TYPES.include? value
                        @type = value
                    else
                        raise BadChrbTemplateError, "Unknown property type '#{value}'"
                    end
                else
                    raise BadChrbTemplateError, "Unknown property argument: #{opt}"
                end
            end
        end
    end

    class Base
        class <<self
            attr_writer :chrb_repo_dir, :fakeroot_path

            # Declares a new property for the chrb
            def property(name, opts)
                @properties ||= []
                @properties << Property.new(name, opts)
            end

            # Returns the properties for the chrb type
            def properties
                @properties ||= []
                return((superclass.respond_to?(:properties) ? superclass.properties : []) + @properties)
            end

            # Declares a file that is created from an ERB source file. You
            # declare the target path of the file (say, '/path/foo'), and the
            # ERB source file is calculated automatically ('/path/foo.erb')
            def erb_templates(*paths)
                @erb_templates ||= []
                @erb_templates.push(*paths) if paths.size > 0
                @erb_templates
            end

            # Returns the associated base filename
            def base_filename; class_to_filename(name.gsub(/.*:/, '')); end

            # Returns the +chrb+ repository directory
            def chrb_repo_dir
                if defined? @chrb_repo_dir
                    @chrb_repo_dir
                else
                    superclass.respond_to?(:chrb_repo_dir) ? superclass.chrb_repo_dir : '.'
                end
            end

            # Returns the +fakeroot+ binary path
            def fakeroot_path
                if defined? @fakeroot_path
                    @fakeroot_path
                else
                    superclass.respond_to?(:fakeroot_path) ? superclass.fakeroot_path : '.'
                end
            end

            def get_chrb_binding(props)
                for pair in props
                    prop, value = *pair
                    literal_tick = "\\\\'"
                    str = "#{prop} = " + case value
                                         when String
                                             "'#{value.gsub(/'/, "\\\\'")}'" 
                                         else
                                             value.to_s
                                         end
                    eval str
                end
                binding
            end

            # Creates a new +chrb+ in directory +dest_dir+
            def create(dest_dir, props)
                # Check properties for the new chrb
                properties.each do |prop|
                    if not props.has_key? prop.name
                        raise MissingPropertyError.new("Missing property #{prop.name}", prop, props)
                    end
                end

                # Unpack the chrb template to the target dir
                create_chrb_from(base_filename, dest_dir)

                # Process the ERB templates, if any
                require 'erb'
                erb_templates.each do |tpl|
                    base_path = File.join(dest_dir, tpl)
                    template  = "#{base_path}.erb"
                    if File.readable? template
                        File.open(template) do |file|
                            File.open(base_path, "w") do |out_file|
                                out_file.puts(ERB.new(file.read).result(get_chrb_binding(props)))
                            end
                        end
                        # Delete the source file, only leave there the result
                        File.unlink template
                    else
                        raise BadChrbTemplateError, "Non-existent ERB template '#{template}'"
                    end
                end
            end

            # Returns the path to the chrb template
            def chrb_template; chrb_template_and_method[0]; end


            protected

            METHODS_EXTENSIONS = {:unpack_bz2 => ['.tar.bz2', '.tbz', '.tbz2'],
                                  :unpack_gz  => ['.tar.gz', '.tgz']}

            # Returns an array with two values (the chrb template path and the
            # method used to uncompress it), or raises a +ChrbNotFoundError+
            # exception if the chrb couldn't be found
            def chrb_template_and_method
                METHODS_EXTENSIONS.each_pair do |method, ext_list|
                    ext_list.each do |ext|
                        filename = "#{base_filename}#{ext}"
                        filename_in_repo = File.join(chrb_repo_dir, filename)
                        if File.exists? filename
                            return [filename, method]
                        elsif File.exists? filename_in_repo
                            return [filename_in_repo, method]
                        end
                    end
                end

                raise ChrbNotFoundError, "Can't find chrb template in '#{base_filename}'. Tried extensions: #{METHODS_EXTENSIONS.values.flatten.join(", ")}"
            end

            # Creates a new chroot in the destination directory +dest_dir+.
            # Returns the final filename if everything was right, or raises a
            # +UnpackError+ or +BadChrbTemplateError+ exception if it couldn't
            # be unpacked
            def create_chrb_from(base_filename, dest_dir)
                path, method = chrb_template_and_method
                dest_dir_dirname = File.dirname(dest_dir)
                temp_unpack_dir = File.join(dest_dir_dirname, CHRB_BASE_DIRECTORY)
                if File.exists? temp_unpack_dir
                    raise UnpackError, "Can't unpack, '#{temp_unpack_dir}' directory already exists"
                end
                send(method, path, dest_dir)
            end

            def unpack_bz2(filename, dest_dir)
                unpack_tar(filename, dest_dir, :bz2)
            end

            def unpack_gz(filename, dest_dir)
                unpack_tar(filename, dest_dir, :gz)
            end

            def unpack_tar(filename, dest_dir, format = :tar)
                require 'pathname'
                absolute_path = Pathname.new(filename).expand_path
                absolute_dest_dir = Pathname.new(dest_dir).expand_path
                dirname, basename = absolute_dest_dir.dirname, absolute_dest_dir.basename
                options = case format
                          when :gz
                              'z'
                          when :bz2
                              'j'
                          else
                              raise Exception, "Unknown uncompress option #{format}"
                          end
                fakeroot_options = ""
                # If not root, try to use fakeroot
                if Process.uid != 0
                    if File.exists? fakeroot_path
                        fakeroot_options = fakeroot_path
                    else
                        raise UnpackError, "Not executing as root, and couldn't find fakeroot in '#{fakeroot_path}'"
                    end
                end
                cmd = "#{fakeroot_options} tar xf#{options} #{absolute_path} -C #{dirname}"
                output = `#{cmd} 2>&1`
                if $?.exitstatus != 0
                    FileUtils.rm_rf(File.join(dirname, CHRB_BASE_DIRECTORY))
                    raise UnpackError, "tar exited with an error: #{cmd}: #{output}"
                end
                # Move it to its final destination
                begin
                    FileUtils.mv(File.join(dirname, CHRB_BASE_DIRECTORY),
                                 File.join(dirname, basename))
                rescue Errno::ENOENT
                    if File.exists? File.join(dirname, CHRB_BASE_DIRECTORY)
                        raise BadChrbTemplateError, "Chrb template '#{filename}' doesn't seem to contain '#{CHRB_BASE_DIRECTORY}' directory"
                    else
                        raise
                    end
                end
            end
        end



        # Base properties
        property        :chrb_name, :description => 'Hostname for the new chrb?'
    end
end
