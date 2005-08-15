require 'test/unit'
require 'remix_widgets'

$LOAD_PATH << 'test'

class TC_Form < Test::Unit::TestCase
   def setup
      @page = RemixWidgets::Page.new
   end

   def test_add_widgets
      @form = RemixWidgets::Form.new(@page, 'f')
      @form.add_widgets([:name => 'firstWidget', :widgetType => 'TextBox'])
      assert_equal(1, @form.widgets.size)
      assert_equal('firstWidget', @form.widgets['firstWidget'].name)
      assert_kind_of(RemixWidgets::Widgets::Base, @form.widgets['firstWidget'])
      # Format errors
      assert_raise(RemixWidgets::WidgetFormatError) { @form.add_widget(:name => 'No type') }
      assert_raise(RemixWidgets::WidgetFormatError) { @form.add_widget(:widgetType => 'No name') }
      # Non-existent widget type
      assert_raise(RemixWidgets::WidgetFormatError) { @form.add_widget(:name => 'foo', :widgetType => 'SomeNonexistentWidget') }
      assert_raise(RemixWidgets::WidgetFormatError) { @form.add_widget(:name => 'foo', :widgetType => 'SomeBadlyDefinedWidget') }
      # Duplicated widgets
      assert_raise(RemixWidgets::WidgetFormatError) { @form.add_widgets(['name' => 'firstWidget', 'widgetType' => 'TextBox']) }
      @form = nil
   end

   def teardown
      @page = nil
   end
end
