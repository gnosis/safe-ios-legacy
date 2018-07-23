#! /usr/bin/env ruby

# This script takes .yml config file and optional configuration name
# and flattens the config hashes into xcconfig variable names.

require 'yaml'

# Recursively go through hashes and convert nested keys into full names
# Example: { "a": { "b": { "c": "value" } } } => "a_b_c": value
# Array values are joined with comma: { "a": [1, 2] } => "a": "1,2"
#   - hash: hash to convert
#   - path: needed for recursion
#   - f: block called with 2 parameters: key and value
def visit(hash, path = [], &f)
  hash.each do |key, value|
    path.push(key)
    if value.is_a?(Hash)
      visit(value, path, &f)
    else 
      var_name = path.join("_").upcase()
      var_value = value.is_a?(Array) ? value.join(",") : value
      f.call(var_name, var_value)
    end
    path.pop()
  end
end

config = YAML.load(File.read(ARGV[0]))
config = ARGV.count > 1 ? config[ARGV[1]] : config

visit(config) do |key, value|
  puts "#{key}=#{(value.is_a?(String) ? value.gsub("//", "/$()/") : value)}"
end
