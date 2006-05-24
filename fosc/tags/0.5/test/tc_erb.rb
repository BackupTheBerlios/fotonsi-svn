# Derechos de autor: Esteban Manchado Velázquez 2004
# Licencia: GPL

require 'test/unit'
require 'plugins/erb'
require 'fosc'

require 'fileutils'
require 'find'

class TC_Erb <Test::Unit::TestCase
   def setup
      @conv = Fosc::FosConverter.new
      @plugin = Fosc::Plugins::Erb.new
      @db = @conv.convert_file('test/test-erb1.fos')
   end
   def test_db
      outputDir         = 'test/erb-output'
      expectedOutputDir = 'test/expected-erb-output'
      FileUtils.mkpath(outputDir)
      @plugin.export(@db, File.join(FileUtils.pwd,
                                    'test/erb-templates/test-template'),
                          outputDir)

      Find.find(expectedOutputDir) do |f|
         next if f.split(File::SEPARATOR).include? '.svn'
         unless FileTest.directory? f
            outputFile = f.sub(expectedOutputDir, outputDir)
            assert(FileUtils.compare_file(f, outputFile), "test-erb1: #{f}")
         end
      end
      FileUtils.rm_rf(outputDir)
   end
   def teardown
      @conv = nil
   end
end
