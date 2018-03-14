#! /usr/bin/env ruby


class StringLoclaization 
    attr_accessor :comment, :key, :value
end

def localizations(file)
    contents = File.open(file, 'rb:UTF-16LE') { |f| f.read.encode('UTF-8') }
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

while leftIdx < base.count && rightIdx < locale.count do
    left = base[leftIdx]
    right = locale[rightIdx]
    out = StringLoclaization.new
    out.comment = left.comment
    out.key = left.key
    if left.key == right.key
        out.value = right.value
        merged << out
        leftIdx += 1
        rightIdx += 1
    elsif left.key < right.key
        out.value = left.value
        merged << out
        leftIdx += 1
    else
        rightIdx += 1
    end
end

while leftIdx < base.count
    merged << base[leftIdx]
    leftIdx += 1
end

File.open(ARGV[1], 'w:UTF-16LE') { |f|
    f.truncate(0)
    bom_marker = "\uFEFF"
    f.write bom_marker
    merged.each do |localization|
        f.puts "/* #{localization.comment} */"
        f.puts "\"#{localization.key}\" = \"#{localization.value}\";"
        f.puts ""
    end
}
