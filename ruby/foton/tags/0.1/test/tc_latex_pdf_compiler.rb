# Derechos de autor: Esteban Manchado Velázquez 2005
# Licencia: GPL

require 'test/unit'
require 'foton/latex_pdf_compiler'
require 'fileutils'

class TC_PdfLatexCompiler <Test::Unit::TestCase
    LATEX_TMP_DIR = 'test/latex/tmp'

    def setup
        FileUtils.mkdir_p(LATEX_TMP_DIR)
        @compiler = Foton::LatexPdfCompiler.new(LATEX_TMP_DIR)
    end

    def test_source_and_file
        test_path             = File.join('test/latex', '01.tex')
        test_result_path      = File.join(LATEX_TMP_DIR, '01.pdf')
        # Compile again, with :file and with :contents
        assert(@compiler.compile(:file => test_path))
        assert(@compiler.compile(:contents => File.read(test_path)))
    rescue Foton::LatexCompilationError => e
        $stderr.puts e.output       # Print LaTeX error, for debugging
        raise e
    end

    def test_latex_escape
        tests = {"Tengo $30, y salto\\\nde línea" => "Tengo \\$30, y salto$\\backslash$\nde línea",
                 'Prefiero las cosas "claras & limpias", mejor que {oscuras,turbias}' => 'Prefiero las cosas "{}claras \& limpias"{}, mejor que \{oscuras,turbias\}'}
        tests.each_pair do |k,v|
            assert_equal(v, @compiler.escape_latex(k))
        end
    end

    def teardown
        FileUtils.rm_rf(LATEX_TMP_DIR)
    end
end
