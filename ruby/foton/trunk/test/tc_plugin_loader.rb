# Derechos de autor: Esteban Manchado Velázquez 2005
# Licencia: GPL

require 'test/unit'
require 'test/plugin_base'
require 'foton/plugin_loader'

class TC_Foton_Plugin_Loader <Test::Unit::TestCase
   def setup
      @pluginLoader = Foton::PluginLoader.new('test/plugindir')
      @pluginLoaderBaseClass = Foton::PluginLoader.new('test/plugindir', PluginBase)
   end

   def test_without_base_class
      assert_equal(['Bar', 'DoesntWork', 'Foo'],
                   @pluginLoader.availPlugins.sort,"availPlugins")
      loadError = 0
      begin
         doesntWorkPlugin = @pluginLoader.plugin('DoesntWork')
      rescue Foton::PluginLoadError => e
         loadError = 1
      end
      assert_equal(1, loadError,                   "can't load DoesntWork plugin")
      fooPlugin = @pluginLoader.plugin("Foo")
      assert_equal(Foo, fooPlugin.class,           "load Foo plugin")

      loadError = 0
      begin
         whatever = @pluginLoader.plugin('foo')
      rescue Foton::PluginLoadError => e
         loadError = 1
      end
      assert_equal(1, loadError,                   "bad name")
   end

   def test_with_base_class
      loadError = 0
      begin
         doesntWorkPlugin = @pluginLoaderBaseClass.plugin('Foo')
      rescue Foton::PluginBaseClassError => e
         loadError = 1
      end
      assert_equal(1, loadError,                   "can't load Foo plugin")
      barPlugin = @pluginLoaderBaseClass.plugin("Bar")
      assert_equal(Bar, barPlugin.class,           "load Bar plugin")
   end

   def teardown
      @pluginLoader = nil
      @pluginLoaderBaseClass = nil
   end
end
