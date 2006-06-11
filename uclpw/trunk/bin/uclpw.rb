#!/usr/bin/ruby -w

require 'commandline'
require 'uclpw'

class App < CommandLine::Application
    def initialize
        version           VERSION
        author            "Esteban Manchado Vel�zquez"
        copyright         "Copyright (c) 2006, Fot�n Sistemas Inteligentes"
        synopsis          "new-project-name [skeleton-name]"
        short_description "Ultimate Command-Line Project Wizard"
        long_description  "Directory-tree, programmable, extensible template system"

        option :help
        option :debug
        expected_args [1,2]
    end

    def main
        @project_name = @args[0]
        # Second, optional argument
        @skeleton     = @args.size > 1 ? @args[1] : 'default'

        begin
            processor = UCLPW::SkeletonProcessor.new(@project_name,
                                                     @skeleton)
        rescue UCLPW::UnknownSkeletonError => e
           $stderr.puts "uclpw: ERROR: Can't find skeleton '#{@skeleton}'"
           exit 1
        rescue UCLPW::ExistingOutputDirError => e
           $stderr.puts "uclpw: ERROR: '#{@project_name}' already exists"
           exit 1
        rescue UCLPW::Exception => e
            $stderr.puts "uclpw: ERROR: Couldn't create processor for skeleton '#{@skeleton}':"
            $stderr.puts e.message
            exit 1
        end

        # Find out variable values ...
        var_list = processor.get_vars
        while true
           var_list.each do |k|
              print k[1] ? "#{k[0]} [#{k[1]}]\t= " : "#{k[0]}\t= "
              input = STDIN.gets.strip
              if input != ''
                  k[1] = input
                  processor.vars[k[0]] = input
              end
           end
           puts
           var_list.each {|k| puts "#{k[0]} = #{k[1]}"}
           print "Is everything OK? [Y/n] "
           break unless STDIN.gets.strip =~ /^n/i
        end
        # ...and actually save them
        processor.update_vars_file

        # Process every file (find and substitute every %{var_name}-style
        # macro)
        print "Processing skeleton... "
        processor.process_dir
        puts "done."

        # Clean up temp files
        print "Clean up temp files (*~)? [Y/n] "
        unless STDIN.gets.strip =~ /^n/i
           processor.cleanup_dir
           FileTest.exists?('extra.rb') && File.safe_unlink('extra.rb')
        end
    rescue => e
        puts "#{e}, #{e.inspect}:\n#{e.backtrace.join("\n")}"
    end
end
