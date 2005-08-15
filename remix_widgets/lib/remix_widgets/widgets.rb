module RemixWidgets
   module Widgets
      # Base widget class. Every widget must inherit from this one
      class Base
         attr_reader :form, :args

         # Class method to store valid argument lists
         def self.validArgs(*list)
            unless defined? @validArgs
               dad = superclass
               @validArgs = dad.respond_to?(:validArgs) ? dad.validArgs : []
            end
            if list.size > 0
               @validArgs += list
            end
            @validArgs
         end
         validArgs :name, :widgetType, :style, :class, :id

         # Creates a new widget. Receives the form it's in, and the argument
         # hash
         def initialize(form, args)
            @form = form
            @args = args

            # Check arguments
            unknownArgs = []
            @args.keys.each do |arg|
               self.class.validArgs.include? arg or unknownArgs << arg
            end
            unknownArgs.empty? or raise WidgetFormatError, "One or more arguments is not valid: #{unknownArgs.join(', ')}"
         end

         # Basic attributes

         def name; @args[:name]; end
         def widgetType
            self.class.name.sub(/^RemixWidgets::Widgets::/, '')
         end
         def page; @form.page; end

         # Widget hooks

         def form_type_init; end
         def page_type_init; end
         def widget_init; end

         # Regular methods

         def render; "[#{name}: please overload the 'render' method for widget type '#{widgetType}']"; end
      end
   end
end
