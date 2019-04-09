#! /usr/bin/env ruby

# This script copies translations from one strings file to another.
# First argument is the destination strings file, second argument is the source.
#
# Only keys existing both in the source and destination are affected,
# in other words, non-translated destination keys are not translated.
#
# If translation value (source value) is an empty string, then it is not used.

require_relative 'string_localization'

destination = localizations(ARGV[0])
source = localizations(ARGV[1])

# create hash map of non-empty source localizations
translations = Hash[source.select { |s| !s.value.empty? }.collect { |s| [s.key, s] } ]

# for each key in destination, if translation, then update the value
updated = destination.collect do |d|
    result = StringLoclaization.new
    result.comment = d.comment
    result.key = d.key
    result.value = translations.has_key?(d.key) ? translations[d.key].value : d.value
    result
end

# updated translations override destination
save(ARGV[0], updated)