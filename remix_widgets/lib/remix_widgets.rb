# RemixWidgets is an advanced web widget system that integrates the client
# side with the server side of widgets

require 'foton'
require 'remix_widgets/widgets'

module RemixWidgets
   # Exceptions
   class DuplicatedWidgetError < StandardError; end
   class WidgetFormatError     < StandardError; end
   class DuplicatedFormError   < StandardError; end



   # Represents the whole webpage, contains one or more forms
   class Page
      attr_reader :forms, :defaultForm
      attr_reader :typesLoaded
      attr_accessor :vars

      def initialize(vars={})
         @vars = vars
         @vars.kind_of? Hash or raise TypeError, "The third argument should be a Hash"

         @defaultForm = 'default'
         @forms = {}
         create_form(@defaultForm)
         # Hook state variables
         @typesLoaded = {}
      end

      def create_form(name)
         if @forms.has_key? name
            raise DuplicatedFormError, "Duplicated form '#{name}'"
         end
         @forms[name] = Form.new(self, name)
      end
   end



   # Represents a from into a page. Contains widgets.
   class Form
      attr_reader :page, :name
      attr_reader :widgets    # Widget Hash (key = :name)

      @@mandatoryKeys = [:name, :widgetType]

      def initialize(page, name)
         @page = page
         @name = name
         @page.kind_of? Page or raise TypeError, "The first argument should be a Page"
         @name.kind_of? String or raise TypeError, "The second argument should be a String"
         @widgets = {}
         # Hook state variables
         @typesLoaded = {}
      end

      # Adds a list of widgets to the form
      def add_widgets(widgetList)
         widgetList.each do |w|
            add_widget(w)
         end
      end

      # Adds one widget to the form
      def add_widget(widget)
         widget.kind_of? Hash or raise WidgetFormatError, "Widget is not a Hash"
         # Check mandatory keys
         @@mandatoryKeys.each do |key|
            widget.has_key? key or raise WidgetFormatError, "Widget has not a key ':#{key}'"
         end
         # Check for duplicated widgets
         if @widgets.has_key? widget[:name]
            raise DuplicatedWidgetError, "Widget '#{widget[:name]}' is already defined"
         end

         # Finally store the widget
         @widgets[widget[:name]] = create_widget(widget)

         # Execute widget hooks
         execute_widget_hooks(@widgets[widget[:name]])
      end


      protected

      def get_widget_class(widgetType)
         alreadyLoaded = false
         begin
            return RemixWidgets::Widgets.const_get(widgetType)
         rescue NameError
            path = "remix_widgets/widgets/#{class_to_filename(widgetType)}"
            if alreadyLoaded
               raise WidgetFormatError, "Can't load '#{widgetType}' from #{path}"
            else
               begin
                  require path
                  alreadyLoaded = true
                  retry
               rescue LoadError
                  raise WidgetFormatError, "Can't find #{path} to load '#{widgetType}'"
               end
            end
         end
      end

      def create_widget(widgetHash)
         c = get_widget_class(widgetHash[:widgetType])
         c.new(self, widgetHash)
      end

      def execute_widget_hooks(widget)
         # Per-form init
         unless @typesLoaded[widget.widgetType]
            widget.form_type_init
            @typesLoaded[widget.widgetType] = true
         end

         # Per-page init
         unless page.typesLoaded[widget.widgetType]
            widget.page_type_init
         end

         # Per-widget init
         widget.widget_init
      end
   end
end
