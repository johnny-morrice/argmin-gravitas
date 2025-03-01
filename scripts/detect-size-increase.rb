#!/usr/bin/env ruby
# Usage: ./scripts/detect-size-increase.rb before.txt after.txt
#
# This script reads two files containing lines in the format:
#   <filename> <size>
#
# It compares the sizes for each file that appears in both and outputs
# those that increased in size.
#
# Example output:
#   _site/index.html: 1024 -> 2048

if ARGV.size != 2
    STDERR.puts "Usage: #{File.basename($0)} before_file after_file"
    exit 1
  end
  
  def read_file_sizes(file_path)
    sizes = {}
    File.foreach(file_path) do |line|
      # Expect each line to have a file name and a size.
      if line =~ /^(.*?)\s+(\d+)$/
        filename = $1
        size = $2.to_i
        sizes[filename] = size
      end
    end
    sizes
  end
  
  before_sizes = read_file_sizes(ARGV[0])
  after_sizes  = read_file_sizes(ARGV[1])
  
  # Iterate over files in the "before" snapshot and print those with an increase.
  before_sizes.each do |filename, before_size|
    if after_sizes.key?(filename)
      after_size = after_sizes[filename]
      if after_size > before_size
        puts "#{filename}: #{before_size} -> #{after_size}"
      end
    end
  end
  