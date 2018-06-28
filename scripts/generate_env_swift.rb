#! /usr/bin/env ruby
require 'dotenv'

dotenvfile_path = ENV['SCRIPT_INPUT_FILE_0']

Dotenv.load(dotenvfile_path)

infura_key = ENV['INFURA_API_KEY']
relay_service_url = ENV['TRANSACTION_RELAY_SERVICE_URL']
abort("error: Missing INFURA_API_KEY dotenv variable") unless infura_key
abort("error: Missing TRANSACTION_RELAY_SERVICE_URL dotenv variable") unless relay_service_url

dst_file = ENV['SCRIPT_OUTPUT_FILE_0']
dst_dir = File.dirname(dst_file)
Dir.mkdir(dst_dir) unless Dir.exist?(dst_dir)

keys_file_template = <<EOF
// Auto-gencerated file, don't modify it by hand.
// swiftlint:disable all

import Foundation

struct Keys {
    static let infuraApiKey = "#{infura_key}"
    static let transactionRelayServiceURL = URL(string: "#{relay_service_url}")!
}
EOF
File.open(dst_file, "w") { |f| f.write(keys_file_template) }
puts "Generated #{dst_file}"