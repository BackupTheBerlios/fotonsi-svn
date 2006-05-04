# Foton Sistemas Inteligentes' misc Ruby module

# This function converts a class name to a filename containing that class,
# according to the standard Ruby conventions
def class_to_filename (c)
   c.gsub(/([A-Z])/, '_\1').sub(/_/, '').downcase
end

# This function converts a filename containing a class to the name of that
# class, according to the standard Ruby conventions
def filename_to_class (f)
   f.capitalize.gsub(/_([a-z])/) {|s| $1.upcase }
end
