module RemixWidgets
   module Widgets
      # Base widget class. Every widget must inherit from this one
      class Base
         attr_reader :form, :attrs

         # Class method to store valid argument lists
         def self.validArgs(*list)
            if list.size > 0
               dad = ancestors[1]
               @validArgs = dad.respond_to?(:validArgs) ? dad.validArgs : []
               @validArgs += list
            end
            @validArgs
         end
         validArgs "style", "class", "id"

         # Creates a new widget. Receives the form it's in, and the attribute
         # hash
         def initialize(form, attrs)
            @form  = form
            @attrs = attrs
         end

         # Basic attrs

         def name; @attrs[:name]; end
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
