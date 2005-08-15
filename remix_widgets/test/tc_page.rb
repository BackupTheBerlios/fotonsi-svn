require 'test/unit'
require 'remix_widgets'

class TC_Page < Test::Unit::TestCase
   def setup
      @page = RemixWidgets::Page.new
   end

   def test_default_form
      assert_equal(1, @page.forms.size, "Number of initial forms")
      assert(@page.forms.has_key?('default'), "Number of initial forms")
   end

   def test_create_form
      assert_raise(RemixWidgets::DuplicatedFormError) do
         @page.create_form('default')
      end
      assert_equal(1, @page.forms.size, "Number of forms after duplicating")
      @page.create_form('another_form')
      assert_equal(2, @page.forms.size, "Number of forms after creating another")
   end

   def teardown
      @page = nil
   end
end
