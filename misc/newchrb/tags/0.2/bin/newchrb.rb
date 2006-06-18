#!/usr/bin/ruby -w

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
            $stderr.puts "Directory #{chrb_dir} already exists. Exiting."
            exit(1)
        end

        say("Unpacking #{ChrbTypes::Base.chrb_repo_dir}/#{chrb_type}...")
        begin
            type_plugin.create(chrb_dir, attrs)
        rescue ChrbTypes::Exception => e
            say(e)
            say("Aborting.")
        else
            say("Done.")
        end
    rescue Interrupt
        exit(1)
    rescue => e
        puts e
        puts e.backtrace
    end
end
