require 'fosc/db'
require 'foton'

$DEBUG = nil
$LOAD_PATH << '/usr/share/fosc'

module Fosc
    VERSION = '0.5'

    class FosConverter
        attr_reader :database
        alias_method :dataBase, :database

        def initialize(options={})
            @options = options
        end

        def convert_file(file)
            state = '' # '', 'element', 'extra'
            @line_number = 0
            @database = Fosc::DataBase.new(file)

            element_driver = nil
            element_data   = ""
            File.foreach(file) do |line|
                @line_number = @line_number.next
                line.chomp!
                next if line =~ /^\s*#/
                line.gsub!(/\s*#.*/, '')         # '#' comments
                line.gsub!(/ +--([^-].*)?/, '')  # '--' comments
                next if line =~ /^---/           # Separator

                # Behave according to the current internal state
                if state == 'element'
                    # Table definition ends
                    if line == ''
                        state = ''
                        next
                    end
                    element_data += line + "\n"
                else
                    # Skip blank lines
                    next if line == ''
                    # Define the element we have now
                    define_element(element_driver, element_data)
                    element_data = ""
                    # Check if the element name is correct
                    line.strip!
                    if line !~ /^\s*([a-z_]+)\s*(\(([a-z_]+)\)\s*)?$/i
                        $stderr.puts "Expected element name, found '#{line}' at line #{@line_number}"
                        $stderr.puts "Perhaps you left a blank line inside an element definition? Aborting."
                        exit 1
                    end
                    # New element begins
                    element_name, element_type = $1, $3 || 'table'
                    state = 'element'
                    # Dynamically load the element driver
                    begin
                        require "elements/#{element_type}"
                        class_name = filename_to_class(element_type)
                        # Store the element driver in a safe place
                        element_driver = Fosc::Elements.const_get(class_name).
                            new(element_name)
                    rescue LoadError => e
                        raise Fosc::Elements::NonExistentElementError.new(element_type, e)
                    rescue NameError => e
                        if [:Elements, class_name.to_sym].include? e.name
                            raise Fosc::Elements::InvalidElementError.new(element_type, e)
                        else
                            raise
                        end
                    end
                    $stderr.puts "New element: #{line} -----------" if $DEBUG
                end
            end

            # Define the last element
            define_element(element_driver, element_data)

            lt = @options['limit_tables'] 
            if lt and not lt.empty?
                $stderr.puts "WARNING: Undefined tables: " + lt.join(", ")
            end

            @database
        end

        protected

        def define_element(driver, lines)
            if driver
                begin
                    driver.import(lines)
                    lt = @options['limit_tables']
                    if not driver.empty? and (lt.nil? or lt.include?(driver.name))
                        lt and lt.delete(driver.name)
                        @database.new_element(driver)
                    end
                rescue Fosc::Elements::FosSyntaxError => e
                    $stderr.puts "Error processing element '#{driver.name}' (of type '#{driver.type}'):"
                    $stderr.puts "#{@line_number+e.line-1}: #{e.msg}"
                    $stderr.puts e.details if e.details
                end
            end
        end
    end
end
