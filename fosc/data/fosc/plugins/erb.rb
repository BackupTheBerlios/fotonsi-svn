# Clase adaptadora para PostgreSQL

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
                templateDir = template_dir(template)
                path = File.join(templateDir, 'info.yml')
                if FileTest.readable? path
                    YAML.load_file(path)
                else
                    raise FosPluginError, "Can't find template #{template} (#{path} is not readable)"
                end
            end

            def export(db, templateSet, basePath='.')
                conf = get_template_conf(templateSet)
                FileUtils.mkpath(basePath)
                conf['files'].each do |_file_tpl|
                    ['input', 'output', 'scope'].each do |k|
                        _file_tpl.has_key? k or raise FosPluginError, "'#{k}' key not specified"
                    end
                    inputPath = File.join(template_dir(templateSet), _file_tpl['input'])
                    FileTest.readable? inputPath or raise FosPluginError, "Can't read input file #{inputPath}"
                    erbProcessor = ERB.new(File.read(inputPath))

                    # Depending on scope, behave differently
                    case _file_tpl['scope']
                    when 'db'
                        fileName = File.join(basePath, _file_tpl['output'].sub('DATABASE', db.name))
                        File.open(fileName, "w") do |file|
                            @db = db
                            file.puts erbProcessor.result(binding)
                        end
                    else            # All elements or some specific kind
                        filter = _file_tpl['scope'] == 'element' ? nil : _file_tpl['scope']
                        db.elements(filter).each do |e|
                            fileName = File.join(basePath,
                                                 _file_tpl['output'].sub('ELEMENT', e.name).sub(_file_tpl['scope'].upcase, e.name))
                            File.open(fileName, "w") do |file|
                                @db, @element = db, e
                                instance_variable_set("@#{e.type}", e)
                                file.puts erbProcessor.result(binding)
                            end
                        end
                    end
                end
            end
        end
    end
end
