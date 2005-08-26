# Clase adaptadora para PostgreSQL

require 'erb'
require 'yaml'
require 'fileutils'

module Fosc
    module Plugins
        class Erb < BasePlugin
            TEMPLATE_DIR = '/usr/share/fosc/erb-templates'

            def template_dir(template)
                template =~ /^\// ? template :
                                    File.join(TEMPLATE_DIR, template)
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

            def export(db, template, basePath='.')
                conf = get_template_conf(template)
                FileUtils.mkpath(basePath)
                conf['files'].each do |f|
                    ['input', 'output', 'scope'].each do |k|
                        f.has_key? k or raise FosPluginError, "'#{k}' key not specified"
                    end
                    inputPath = File.join(template_dir(template), f['input'])
                    FileTest.readable? inputPath or raise FosPluginError, "Can't read input file #{inputPath}"
                    erbProcessor = ERB.new(File.read(inputPath))

                    # Depending on scope, behave differently
                    case f['scope']
                    when 'db'
                        fileName = File.join(basePath, f['output'].sub('DATABASE', db.name))
                        File.open(fileName, "w") do |f|
                            @db = db
                            f.puts erbProcessor.result(binding)
                        end
                    else            # All elements or some specific kind
                        filter = f['scope'] == 'element' ? nil : f['scope']
                        db.elements(filter).each do |e|
                            fileName = File.join(basePath,
                                                 f['output'].sub('ELEMENT', e.name).sub(f['scope'].upcase, e.name))
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
