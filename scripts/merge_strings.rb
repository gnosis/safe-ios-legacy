#! /usr/bin/env ruby

#
# This script expects 2 arguments: base and localized strings files (UTF-8 ONLY!)
# It expects strings files to be alphabetically sorted by keys (this is so for genstrings generfated files)
# Then, it updateds comments in the localized file + adds new keys + removes keys not present in the base file.
# The script overrides localized strings file.

class StringLoclaization 
    attr_accessor :comment, :key, :value
end

# parses .strings file and returns array of StringLocalizations
def localizations(file)
    contents = File.open(file, 'rb:UTF-8') { |f| f.read }
    contents.scan(/\/\* (.*?) \*\/\n"(.*?)" = "(.*?)";/m).map { |comment, key, value|
        localization = StringLoclaization.new
        localization.comment = comment
        localization.key = key
        localization.value = value
        localization
    }
end

base = localizations(ARGV[0])
locale = localizations(ARGV[1])
merged = []

leftIdx = 0
rightIdx = 0

# Merge localizations from base (left) and localized (right) strings
while leftIdx < base.count && rightIdx < locale.count do
    left = base[leftIdx]
    right = locale[rightIdx]

    # Whatever is in left, will be in the output
    out = StringLoclaization.new
    out.comment = left.comment
    out.key = left.key
    
    if left.key == right.key
        # preserve localization if the key exists in the right
        out.value = right.value
        merged << out
        leftIdx += 1
        rightIdx += 1
    elsif left.key < right.key
        # the key does not exist in the right, add it from the left
        out.value = left.value
        merged << out
        leftIdx += 1
    else
        # the key exists in the right but not in the left - skip this key
        rightIdx += 1
    end
end

# append keys left in the left
while leftIdx < base.count
    merged << base[leftIdx]
    leftIdx += 1
end

# output merged strings file, overwriting localized file.
File.open(ARGV[1], 'w:UTF-8') { |f|
    f.truncate(0)
    merged.each do |localization|
        f.puts "/* #{localization.comment} */"
        f.puts "\"#{localization.key}\" = \"#{localization.value}\";"
        f.puts ""
    end
}
