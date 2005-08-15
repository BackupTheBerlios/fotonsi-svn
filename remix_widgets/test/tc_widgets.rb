require 'test/unit'
require 'remix_widgets'

class TC_Widgets < Test::Unit::TestCase
   def setup
      @page = RemixWidgets::Page.new
   end

   def test_create
      assert_raise(RemixWidgets::WidgetFormatError) do
         @page.add_widget(:name => 'foo', :widgetType => 'TextBox',
                                          :someNonexistentAttr => true)
      end
      @page.add_widget(:name => 'foo', :widgetType => 'TextBox', :size => 2)
      assert_equal(1, @page.widgets.size)
   end

   def teardown
      @page = nil
   end
end
