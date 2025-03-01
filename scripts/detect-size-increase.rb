#!/usr/bin/env ruby
# Usage: ./scripts/detect-size-increase.rb before.txt after.txt
#
# This script reads two files containing lines in the format:
#   <filename> <size>
#
# It compares the sizes for each file that appears in either snapshot and outputs:
#   - Increased, decreased, or unchanged sizes for files present in both snapshots.
#   - "ADDED" for files only in the "after" snapshot.
#   - "DELETED" for files only in the "before" snapshot.
#
# Example output:
#   _site/index.html: 1024 -> 2048 (increased by 1024)
#   _site/style.css: 2048 -> 1024 (decreased by 1024)
#   _site/new.js: ADDED (size: 512)
#   _site/old.js: DELETED (size: 256)

if ARGV.size != 2
    STDERR.puts "Usage: #{File.basename($0)} before_file after_file"
    exit 1
  end
  
  def read_file_sizes(file_path)
    sizes = {}
    File.foreach(file_path) do |line|
      # Expect each line to have a file name and a size.
      if line =~ /^(.*?)\s+(\d+)$/
        filename = $1.strip
        size = $2.to_i
        sizes[filename] = size
      end
    end
    sizes
  end
  
  before_sizes = read_file_sizes(ARGV[0])
  after_sizes  = read_file_sizes(ARGV[1])
  
  # Compute the union of all filenames in both snapshots.
  all_files = before_sizes.keys | after_sizes.keys
  
  all_files.sort.each do |filename|
    before_size = before_sizes[filename]
    after_size  = after_sizes[filename]
  
    if before_size && after_size
      if after_size > before_size
        diff = after_size - before_size
        puts "#{filename}: #{before_size} -> #{after_size} (increased by #{diff})"
      elsif after_size < before_size
        diff = before_size - after_size
        puts "#{filename}: #{before_size} -> #{after_size} (decreased by #{diff})"
      else
        puts "#{filename}: #{before_size} -> #{after_size} (unchanged)"
      end
    elsif before_size && !after_size
      puts "#{filename}: DELETED (size was #{before_size})"
    elsif after_size && !before_size
      puts "#{filename}: ADDED (size is #{after_size})"
    end
  end
  