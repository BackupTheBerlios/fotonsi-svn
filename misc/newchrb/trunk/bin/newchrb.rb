#!/usr/bin/ruby -w

require 'fileutils'
require 'commandline'
require 'highline'
require 'rucola'
require 'foton/misc'
require 'foton/plugin_utils'

require 'newchrb'
$LOAD_PATH << '/usr/share/newchrb'
require 'chrb_types'

class NewChrbApp < CommandLine::Application
    def initialize
        version           NewChrb::VERSION
        author            "Fotón Sistemas Inteligentes"
        copyright         "2006 Fotón Sistemas Inteligentes"
        short_description "Chrb creator"
        long_description  "Creates a new chrb from a template"
        synopsis          "[-r /chrb/repo] chrb_type [destination_dir]"

        option :help
        option :names => %w(--chrb-repo -r), :arity => 1,
               :opt_found => lambda {|o,r,a| @repo_dir = a}

        expected_args [1,2]
    end

    def main
        chrb_type, destination_dir = @args
        destination_dir ||= '.'

        @conf = Rucola::Conf.new('newchrb')
        @repo_dir = nil unless defined? @repo_dir
        ChrbTypes::Base.chrb_repo_dir = @repo_dir || @conf[:repo_dir] || '.'
        ChrbTypes::Base.fakeroot_path = @conf[:fakeroot_path] || '/usr/bin/fakeroot'

        unless File.directory? destination_dir and File.writable? destination_dir
            $stderr.puts "Directory #{destination_dir} is not a directory or isn't writable"
            exit(1)
        end

        begin
            type_plugin = Foton::PluginUtils.load_plugin(filename_to_class(chrb_type), ChrbTypes)
            # Ignore result; just to check it doesn't throw an exception
            type_plugin.chrb_template
        rescue Foton::PluginUtils::Exception, ChrbTypes::Exception => e
            $stderr.puts "Can't load plugin '#{chrb_type}' (details follow):\n#{e}"
            exit(1)
        end
        say(%Q(<%= color("Preparing new chrb of type '#{chrb_type}'", BOLD) %>))
        say("----------------------------#{'-' * chrb_type.size}-")
        attrs = NewChrb.retrieve_chrb_property_values(type_plugin.properties)

        chrb_dir = File.join(destination_dir, attrs[:chrb_name])

        if File.exists? chrb_dir
            say("<%= color('Directory #{chrb_dir} already exists.', BOLD) %>")
            say("<%= color(\"You'll have to WIPE that directory out if\", BOLD) %>")
            say("<%= color('you want to create a new chrb with that name.', BOLD) %>")
            if choose do |menu|
                   menu.layout  = :one_line
                   menu.prompt  = "WIPE directory? [n] "
                   menu.default = 'n'
                   menu.choice 'y' do value = true  end
                   menu.choice 'n' do value = false end
               end
                say("Wiping #{chrb_dir}... ")
                FileUtils.rm_rf chrb_dir
                say("done.")
            else
                $stderr.puts "Exiting."
                exit(1)
            end
        end

        say("Unpacking #{type_plugin.chrb_template} in '#{destination_dir}'... ")
        begin
            type_plugin.create(chrb_dir, attrs)
        rescue ChrbTypes::Exception => e
            say("\n")
            say(e)
            say("ABORTING.")
        else
            say("done.")
            if not attrs[:chrb_image] then
                say("Your new chrb is now in #{chrb_dir}.")
            else
                say("Compressing #{chrb_dir}...")
                require 'pathname'
                cmd ="tar zcf #{attrs[:chrb_name].tar.gz} #{chrb_dir}"
                output = `#{cmd} 2>&1`
                if $?.exitstatus !=0
                    raise PackError, "tar exited with an error: #{cmd}: #{output}"
                end
                say("Wiping #{chrb_dir}... ")
                FileUtils.rm_rf chrb_dir
            end
        end
    rescue Interrupt
        exit(1)
    rescue PackError => e
        puts e
        exit(1)
    rescue => e
        puts e
        puts e.backtrace
    end
end
