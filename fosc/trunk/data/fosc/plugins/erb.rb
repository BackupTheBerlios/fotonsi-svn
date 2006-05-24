# ERB plugin for FOSC

require 'plugins/base_plugin'
require 'erb'
require 'yaml'
require 'fileutils'

module Fosc
    module Plugins
        class Erb < BasePlugin
            TEMPLATE_SET_DIR = '/usr/share/fosc/erb-templates'

            def template_dir(template)
                template =~ /^\// ? template :
                                    File.join(TEMPLATE_SET_DIR, template)
            end

            def get_template_conf(template)
                template_dir = template_dir(template)
                path = File.join(template_dir, 'info.yml')
                if FileTest.readable? path
                    YAML.load_file(path)
                else
                    raise FosPluginError, "Can't find template #{template} (#{path} is not readable)"
                end
            end

            def export(db, template_set, base_path='.')
                conf = get_template_conf(template_set)
                FileUtils.mkpath(base_path)
                conf['files'].each do |_file_tpl|
                    ['input', 'output', 'scope'].each do |k|
                        _file_tpl.has_key? k or raise FosPluginError, "'#{k}' key not specified"
                    end
                    input_path = File.join(template_dir(template_set), _file_tpl['input'])
                    FileTest.readable? input_path or raise FosPluginError, "Can't read input file #{input_path}"
                    erb_processor = ERB.new(File.read(input_path))

                    # Depending on scope, behave differently
                    case _file_tpl['scope']
                    when 'db'
                        file_name = File.join(base_path, _file_tpl['output'].sub('DATABASE', db.name))
                        File.open(file_name, "w") do |file|
                            @db = db
                            file.puts erb_processor.result(binding)
                        end
                    else            # All elements or some specific kind
                        filter = _file_tpl['scope'] == 'element' ? nil : _file_tpl['scope']
                        db.elements(filter).each do |e|
                            file_name = File.join(base_path,
                                                 _file_tpl['output'].sub('ELEMENT', e.name).sub(_file_tpl['scope'].upcase, e.name))
                            File.open(file_name, "w") do |file|
                                @db, @element = db, e
                                instance_variable_set("@#{e.type}", e)
                                file.puts erb_processor.result(binding)
                            end
                        end
                    end
                end
            end
        end
    end
end
