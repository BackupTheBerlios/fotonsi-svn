#!/usr/bin/ruby -w

require 'ftools'
require 'fileutils'

module UCLPW
   VERSION = '0.21'
end

class SkeletonProcessor
   attr_reader :vars, :varsFile
   attr_reader :skeletonDirs
   attr_writer :ignoreList

   def initialize(projectName, skeletonDirs = ['/usr/share/uclpw/skeletons'])
      @vars             = { 'APPLICATION_ID' => projectName, }
      @varsFile         = 'vars'
      @ignoreList       = ['*.jpg', '*.png', '*.gif', '*.gz', '*.bzip2', '*.mdb']
      self.skeletonDirs = skeletonDirs
   end

   def projectName
      @vars['APPLICATION_ID']
   end

   def skeletonDirs=(newSkeletonDirs)
      @skeletonDirs = (newSkeletonDirs.kind_of? Array) ? newSkeletonDirs :
                                                         [ newSkeletonDirs ]
   end

   # Gets skeleton
   def get_skeleton(skeletonName)
      @skeletonDirs.each do |d|
         skeletonDir = File.join(d, skeletonName)
         if FileTest.exists? skeletonDir
            FileUtils.cp_r skeletonDir, projectName
            return true
         end
      end
      return false
   end

   # Find every file recursively and substitutes %{var_name}-style macros
   def process_dir(dir)
      Dir.foreach(dir) do |f|
         next if f =~ /^\.\.?$/
         next if @ignoreList.find { |pat| File.fnmatch(pat, f) }

         f = File.join(dir, f)
         if FileTest.directory? f
            process_dir(f)
         else
            f_temp = f + "~"
            File.move(f, f_temp)
            File.open(f, "w") do |out_f|
               File.foreach(f_temp) do |l|
                  out_f.puts l.gsub(/%\{([a-zA-Z0-9_]+)\}/) {|s|
                                 vars.key?($1) ? vars[$1] : s
                             }
               end
            end
         end
      end
   end

   def update_vars_file(file = nil)
      file ||= @varsFile
      tmp_file   = file + '.tmp'
      # Read everything, dump to a temp file...
      File.open(tmp_file, "w") do |out_f|
         File.foreach(file) do |line|
            out_f.puts line.gsub(/^([A-Z_]+)\s*=\s*(.*)/) {|s| "#{$1} = #{vars.key?($1) ? vars[$1] : $2}"}
         end
      end
      # ...then move the temp file to the original path
      File.move(tmp_file, file)
   end

   def cleanup_dir(dir)
      Dir.foreach(dir) do |f|
         next if f =~ /^\.\.?$/
         f = File.join(dir, f)
         if FileTest.directory? f
            cleanup_dir(f)
         elsif f =~ /~$/      # Temp file
            File.safe_unlink(f)
         end
      end
   end
end


if $0 == __FILE__
    projectName = ARGV.shift
    skeleton    = ARGV.shift || 'default'

    if projectName.nil?
       $stderr.puts "Usage: uclpw new-project-name [skeleton-name]"
       exit(1)
    end

    processor = SkeletonProcessor.new(projectName)

    # Get skeleton
    if FileTest.exists? processor.projectName
       $stderr.puts "uclpw: ERROR: '#{processor.projectName}' already exists"
       exit(1)
    end
    if not processor.get_skeleton(skeleton)
       $stderr.puts "uclpw: Couldn't get skeleton '#{skeleton}'"
       exit(1)
    end

    # Change directory to the new skeleton copy
    Dir.chdir processor.projectName

    # Load variables from the 'vars' file
    begin
       varList = []
       File.foreach(processor.varsFile) do |line|
          next if line =~ /^#/    # Drop comment lines
          line =~ /([A-Z_]+)\s*=(.*)/
          var, default_value = $1, $2
          varList << var
          processor.vars[var] = default_value.strip
       end
    end

    # Load the skeleton 'extra' module
    begin
       # We're already in the skeleton copy directory
       require 'extra'
    rescue LoadError
       $stderr.puts "No extra actions to execute"
    end

    # Find out variable values ...
    while true
       varList.each do |k|
          print processor.vars[k] ? "#{k} [#{processor.vars[k]}]\t= " : "#{k}\t= "
          input = gets.strip
          processor.vars[k] = input if input != ''
       end
       puts
       varList.each {|k| puts "#{k} = #{processor.vars[k]}"}
       print "Is everything OK? [Y/n] "
       break unless gets.strip =~ /^n/i
    end
    # ...and actually save them
    processor.update_vars_file

    # Pre-processing hook
    begin
       processor.pre_process
    rescue NameError => e
       raise unless e.name == :pre_process
    end

    # Process every file (find and substitute every %{var_name}-style macro)
    print "Processing skeleton... "
    processor.process_dir('.')
    puts "done."

    # Post-processing hook
    begin
       processor.post_process
    rescue NameError => e
       raise unless e.name == :post_process
    end

    # Clean up temp files
    print "Clean up temp files (*~)? [Y/n] "
    unless gets.strip =~ /^n/i
       processor.cleanup_dir('.')
       FileTest.exists?('extra.rb') && File.safe_unlink('extra.rb')
    end
end
