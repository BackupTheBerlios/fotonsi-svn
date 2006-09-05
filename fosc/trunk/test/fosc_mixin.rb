module FoscMixin
    def each_fosc_output_line(file, additional_opts = "")
        File.popen("ruby -w -Ilib -Idata/fosc bin/fosc test/#{file} #{additional_opts} 2>&1") do |f|
            f.each_line do |line|
                yield line
            end
        end
    end

    def assert_fosc_output(expected_output, file, additional_opts="", user_opts={})
        opts = {:skip_lines => 0}.merge(user_opts)
        output_str = ""
        line_number = 0
        each_fosc_output_line(file, additional_opts) do |line|
            output_str += line if line_number >= opts[:skip_lines]
            line_number += 1
        end
        assert_equal(expected_output.strip, output_str.strip)
    end
end
