require 'tempfile'

module Foton
    # Compilation-related exception
    class LatexCompilationError < RuntimeError
        attr_reader :output, :cmdLine, :latexSource

        def initialize(msg, output=nil, cmdLine=nil, latexSource=nil)
            super(msg)
            @output      = output
            @cmdLine     = cmdLine
            @latexSource = latexSource
        end
    end


    # LaTeX to PDF compiler
    class LatexPdfCompiler
        def initialize(tmpDir = '/tmp', pdflatexBin = '/usr/bin/pdflatex',
                       pdflatexOptions = "--interaction nonstopmode")
            @tmpDir          = tmpDir
            @pdflatexBin     = pdflatexBin
            @pdflatexOptions = pdflatexOptions
        end

        # Compiles a LaTeX source and returns the compiled PDF data
        # Gets the following +options+:
        # [:file] LaTeX source file path
        # [:contents] LaTeX string
        # [:add_options] additional pdflatex call options
        # [:replace_options] pdflatex call options, ignoring default ones
        def compile_latex(options)
            latexFilePath = options[:file]
            unless latexFilePath
                Tempfile.open('latex', @tmpDir) do |f|
                    latexFilePath = f.path
                    f.puts options[:contents]
                end
            end

            # Always use absolute paths
            if FileTest.readable? latexFilePath
                require 'pathname'
                latexFilePath = Pathname.new(latexFilePath).realpath
            else
                latexFilePath = File.join(@tmpDir, latexFilePath)
            end
            FileTest.readable? latexFilePath or
                    raise LatexCompilationError.new("Can't find #{latexFilePath}. Try passing a valid, readable absolute path to the :file option, or some LaTeX to the :contents options _and_ a writable tmpDir (it's currently '#{@tmpDir}') to the compiler constructor")

            finalOptions =  @pdflatexOptions
            finalOptions += options[:add_options]     if options[:add_options]
            finalOptions =  options[:replace_options] if options[:replace_options]

            command = "cd #{@tmpDir} && #{@pdflatexBin} #{finalOptions} #{latexFilePath}"
            output = `#{command}`
            $? == 0 or raise LatexCompilationError.new("pdflatex terminated with an error", output, command, File.read(latexFilePath))
            output =~ /Output written on (.*\.pdf)/
            $1 or raise LatexCompilationError.new("Can't find output file produced by pdflatex.", output, command, File.read(File.join(@tmpDir, latexFilePath)))
            File.read(File.join(@tmpDir, $1))
        end

        alias_method :compile, :compile_latex



        # Escapes the following text to be legal LaTeX that shows literally the
        # given text
        def escape_latex(text)
            text.to_s.gsub(/\$/, '\\\$').
                gsub(/\\([^\$])/, '$\\backslash$\1').
                gsub(/\\$/, '$\\backslash$').
                gsub(/&/, '\\\&').
                gsub(/\{/, '\\{').
                gsub(/\}/, '\\}').
                gsub(/_/, '\\_').
                gsub(/"/, '"{}').
                gsub(/%/, '\\%').
                gsub(/\x80/, '\\EUR').
                gsub(/\x96/, '---')
        end
    end
end
