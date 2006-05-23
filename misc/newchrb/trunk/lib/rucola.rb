require 'yaml'

# RUby COnfiguration Layer: a generic module to read and store configuration in
# YAML format
module Rucola
    # Configuration dir specs
    CONFIGURATION_DIRS = {:regular => [['/usr/local/etc', '/etc'],
                                       lambda {|n| n+".conf"}],
                          :hidden  => [[ENV['HOME']],
                                       lambda {|n| ".#{n}.conf"}]}

    # RUCO's main class
    class Conf
        class <<self
            attr_writer :configuration_dirs

            def configuration_dirs
                defined?(@configuration_dirs) ? @configuration_dirs :
                                                CONFIGURATION_DIRS
            end
        end

        def initialize(basename)
            @conf = {}
            # Try to read hidden configuration first, then the regular one
            configuration_dirs.values.each do |spec|
                spec[0].each do |dir|
                    path = File.join(dir, spec[1].call(basename))
                    if File.readable? path
                        File.open(path) {|f| @conf = simbolize_keys(YAML::load(f))}
                        return
                    end
                end
            end
        end

        def simbolize_keys(hash)
            h = {}
            hash.each_pair do |key,value|
                h[key.to_sym] = value
            end
            h
        end

        def configuration_dirs
            self.class.configuration_dirs
        end

        def [](key)
            @conf[key.to_sym]
        end

        def []=(key)
            @conf[key.to_sym]
        end

        def to_hash
            @conf
        end
    end
end
