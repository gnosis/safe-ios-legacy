#! /usr/bin/env ruby

#
# This script expects 2 arguments: generated and existing strings files (UTF-8 ONLY!)
# It expects strings files to be alphabetically sorted by keys (this is so for genstrings generfated files)
# Then, it updateds comments in the localized file + adds new keys + removes keys not present in the generatedLocalizations file.
# The script overrides localized strings file.

class StringLoclaization 
    attr_accessor :comment, :key, :value
end

# parses .strings file and returns array of StringLocalizations
def localizations(file)
    puts "Parsing file #{file}"
    contents = File.read(file, encoding: 'UTF-8')
    contents.scan(/\/\* (.*?) \*\/\n"(.*?)" = "(.*?)";/m).map { |comment, key, value|
        localization = StringLoclaization.new
        localization.comment = comment
        localization.key = key
        localization.value = value
        localization
    }
end

generatedLocalizations = localizations(ARGV[0])
existingLocalizations = localizations(ARGV[1])
mergedLocalizations = []

generatedLocalizationsIdx = 0
existingLocalizationsIdx = 0

# Merge localizations from generatedLocalizations (generatedLocalization) and localized (existingLocalization) strings
while generatedLocalizationsIdx < generatedLocalizations.count && existingLocalizationsIdx < existingLocalizations.count do
    generatedLocalization = generatedLocalizations[generatedLocalizationsIdx]
    existingLocalization = existingLocalizations[existingLocalizationsIdx]

    # Whatever is in generatedLocalization, will be in the output
    mergedLocalization = StringLoclaization.new
    mergedLocalization.comment = generatedLocalization.comment
    mergedLocalization.key = generatedLocalization.key
    
    if generatedLocalization.key == existingLocalization.key
        # preserve localization if the key exists in the existingLocalization
        mergedLocalization.value = existingLocalization.value
        mergedLocalizations << mergedLocalization
        generatedLocalizationsIdx += 1
        existingLocalizationsIdx += 1
    elsif generatedLocalization.key < existingLocalization.key
        # the key does not exist in the existingLocalization - add it from the generatedLocalization
        mergedLocalization.value = generatedLocalization.value
        mergedLocalizations << mergedLocalization
        generatedLocalizationsIdx += 1
    else
        # the key exists in the existingLocalization but not in the generatedLocalization - skip this key
        existingLocalizationsIdx += 1
    end
end

# append remaining keys from generatedLocalizations
while generatedLocalizationsIdx < generatedLocalizations.count
    mergedLocalizations << generatedLocalizations[generatedLocalizationsIdx]
    generatedLocalizationsIdx += 1
end

# output mergedLocalizations strings file, overwriting localized file.
File.open(ARGV[1], 'w:UTF-8') { |f|
    f.truncate(0)
    mergedLocalizations.each do |localization|
        f.puts "/* #{localization.comment} */"
        f.puts "\"#{localization.key}\" = \"#{localization.value}\";"
        f.puts ""
    end
}
