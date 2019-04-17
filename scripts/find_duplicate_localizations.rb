#! /usr/bin/env ruby

# This script takes a Localizable.strings file as an input argument
# and then lists all keys that have duplicate values

require_relative 'string_localization'

locs = localizations(ARGV[0])

# re-arrange all keys by values in a hash map
by_value = Hash.new
locs.each do |loc|
    values = by_value[loc.value]
    if values.nil?
        by_value[loc.value] = [loc]
    else
        values << loc
        by_value[loc.value] = values
    end
end

# select only those that have more than one value and sort them alphabetically by value
duplicates = by_value.select { |k, v| v.length > 1 }.sort { |a, b| a[0] <=> b[0] }

# print it out
duplicates.each do |key, values|
    puts key
    values.each { |v| puts "\t#{v.key}" }
    puts
end
