#! /usr/bin/env ruby

# This script takes one Localizable.strings file that needs linting (source file)
# as a first argument, and a remote Localizable.strings file that
# is a source of translations (translations file) 
# Script compares them and prints out warnings when:
#   - source file contains keys that do not exist in translation files
#   - source file contains duplicate translations, i.e. different keys but same values
#   - translations file has empty translation values
#   - translation file contains keys that do not exist in source files

require_relative 'string_localization'

source = localizations(ARGV[0])
translations = localizations(ARGV[1])

source_keys = source.collect { |l| l.key }.to_set
translation_keys = translations.collect { |l| l.key }.to_set

in_source_not_in_translations = source_keys - translation_keys
in_translations_not_in_source = translation_keys - source_keys
in_translations_empty_values = translations.select { |l| l.value.empty? }.collect { |l| l.key }

# duplicate keys lookup
# re-arrange all keys by values in a hash map
by_value = Hash.new
source.each do |loc|
    values = by_value[loc.value]
    if values.nil?
        by_value[loc.value] = [loc.key]
    elsif !values.include?(loc.key)
        values << loc.key
        by_value[loc.value] = values
    end
end

# select only those that have more than one value and sort them alphabetically by value
duplicates = by_value.select { |k, v| v.length > 1 }.sort { |a, b| a[0] <=> b[0] }

# reporting

def print_keys(key_set, warning)
    return if key_set.empty?
    puts warning
    print "\t"
    puts key_set.to_a.sort.join("\n\t")
end

print_keys(in_translations_empty_values, "[WARNING] These keys are not translated:")
print_keys(in_translations_not_in_source, "[WARNING] These keys exist in the TRANSLATIONS but not in SOURCE:")
print_keys(in_source_not_in_translations, "[WARNING] These keys exist in the SOURCE, but not in TRANSLATIONS:")

unless duplicates.empty?
    puts "[WARNING] These values are duplicated across several keys:"
    duplicates.each do |key, values|
        puts key
        values.each { |v| puts "\t#{v}" }
        puts
    end    
    puts
end
