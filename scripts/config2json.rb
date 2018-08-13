#! /usr/bin/env ruby
# This script takes .yml config file and converts it to JSON
require 'yaml'
require 'json'

config = YAML.load(File.read(ARGV[0]))
config = ARGV.count > 1 ? config[ARGV[1]] : config
puts JSON.pretty_generate(config)
