# Derechos de autor: Esteban Manchado Velázquez 2005
# Licencia: GPL

require 'test/unit'
require 'foton/plugin_utils'

class TC_Foton_Plugin_Utils <Test::Unit::TestCase
   def test_load_plugin
       require 'test_plugin'
       p = Foton::PluginUtils.load_plugin('Simple', TestPlugin)
       assert_equal('TestPlugin::Simple', p.to_s,
                                            "load_plugin - Simple plugin name")
       assert_raise(Foton::PluginUtils::BadPluginError) do
           Foton::PluginUtils.load_plugin('WithoutModule', TestPlugin)
       end

       assert_raise(Foton::PluginUtils::NonExistentPluginError) do
           Foton::PluginUtils.load_plugin('IDontExist', TestPlugin)
       end
   end

   def test_deep_paths
       require 'deep/plugin'
       p = Foton::PluginUtils.load_plugin('Still::Deeper', Deep::Plugin)
       assert_equal('Deep::Plugin::Still::Deeper', p.to_s,
                                            "load_plugin - Still::Deeper")
   end
end
