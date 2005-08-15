module RemixWidgets
   module Widgets
      # Base widget class. Every widget must inherit from this one
      class Base
         attr_reader :form, :attrs

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
      end
   end
end
