require 'fosc/db'
require 'foton'

$DEBUG = nil
$LOAD_PATH << '/usr/share/fosc'

module Fosc
   VERSION = 0.3

   class FosConverter
      attr_reader :dataBase

      def initialize(options={})
         @options = options
      end

      def convert_file(file)
         state = '' # '', 'element', 'extra'
         @lineNumber = 0
         @dataBase = Fosc::DataBase.new(file)

         elementDriver = nil
         elementData   = ""
         File.foreach(file) do |line|
            @lineNumber = @lineNumber.next
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
               elementData += line + "\n"
            else
               # Skip blank lines
               next if line == ''
               # Define the element we have now
               define_element(elementDriver, elementData)
               elementData = ""
               # Check if the element name is correct
               line.strip!
               if line !~ /^\s*([a-z_]+)\s*(\(([a-z_]+)\)\s*)?$/i
                  $stderr.puts "Expected element name, found '#{line}' at line #{@lineNumber}"
                  $stderr.puts "Perhaps you left a blank line inside an element definition? Aborting."
                  exit 1
               end
               # New element begins
               elementName, elementType = $1, $3 || 'table'
               state = 'element'
               # Dynamically load the element driver
               begin
                  require "elements/#{elementType}"
                  className = filename_to_class(elementType)
                  # Store the element driver in a safe place
                  elementDriver = Fosc::Elements.const_get(className).
                                                            new(elementName)
               rescue LoadError
                  $stderr.puts "Could not load 'elements/#{elementType}' for element #{elementName}"
                  exit 1
               rescue NameError
                  $stderr.puts "Unknown element type '#{elementType}' (could not find Fosc::Elements::#{className})"
                  exit 1
               end
               $stderr.puts "New element: #{line} -----------" if $DEBUG
            end
         end

         # Define the last element
         define_element(elementDriver, elementData)

         lt = @options['limit_tables'] 
         if lt and not lt.empty?
            $stderr.puts "WARNING: Undefined tables: " + lt.join(", ")
         end

         @dataBase
      end

      protected

      def define_element(driver, lines)
         if driver
            begin
               driver.import(lines)
               lt = @options['limit_tables']
               if not driver.empty? and (lt.nil? or lt.include?(driver.name))
                  lt and lt.delete(driver.name)
                  @dataBase.new_element(driver)
               end
            rescue Fosc::Elements::FosSyntaxError => e
               $stderr.puts "Error processing element '#{driver.name}' (of type '#{driver.type}'):"
               $stderr.puts "#{@lineNumber+e.line-1}: #{e.msg}"
               $stderr.puts e.details if e.details
            end
         end
      end
   end
end
