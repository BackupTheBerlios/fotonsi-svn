require 'yaml'

# RUby COnfiguration Layer: a generic module to read and store configuration in
# YAML format
module Rucola
    # Configuration dir specs
    CONFIGURATION_DIRS = {:regular => [['/usr/local/etc', '/etc'],
                                       lambda {|n| n}],
                          :hidden  => [[ENV['HOME']],
                                       lambda {|n| ".#{n}"}]}

    # RUCO's main class
    class Conf
        class <<self
            attr_writer :configuration_dirs

            def configuration_dirs
                defined?(@configuration_dirs) ? @configuration_dirs :
                                                CONFIGURATION_DIRS
            end
        end

        attr_reader :conf

        def initialize(basename)
            @conf = {}
            # Try to read hidden configuration first, then the regular one
            configuration_dirs.values.each do |spec|
                spec[0].each do |dir|
                    path = File.join(dir, spec[1].call(basename))
                    if File.readable? path
                        File.open(path) {|f| @conf = YAML::load(f)}
                        return
                    end
                end
            end
        end

        def configuration_dirs
            self.class.configuration_dirs
        end
    end
end
