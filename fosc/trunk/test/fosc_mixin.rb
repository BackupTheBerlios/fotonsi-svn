module FoscMixin
    def each_fosc_output_line(file, additional_opts = "")
        File.popen("ruby -w -Ilib -Idata/fosc bin/fosc test/#{file} #{additional_opts} 2>&1") do |f|
            f.each_line do |line|
                yield line
            end
        end
    end

    def assert_fosc_output(expected_output, file, additional_opts = "")
        output_str = ""
        each_fosc_output_line(file, additional_opts) do |line|
            output_str += line
        end
        assert_equal(expected_output.strip, output_str.strip)
    end
end
