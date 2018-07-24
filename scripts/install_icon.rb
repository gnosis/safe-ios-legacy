#! /usr/bin/env ruby

source_dir = ARGV[0]
assets_dir = ARGV[1]

source_files = Dir.glob(File.join(source_dir, "*")).sort()

source_files.each do |source_file|
  destination_files = Dir.glob(File.join(assets_dir, "**", File.basename(source_file)))
  destination_files.each do |destination_file|
    command = "cp #{source_file} #{destination_file}"
    puts command
    system command
  end
end

