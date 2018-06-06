#! /usr/bin/env ruby

VERSION = `cd safe; agvtool mvers -terse1;`.chomp

modules = [
    {
        name: "Common",
        path: "Common/Common"
    },
    {
        name: "Database",
        path: "Common/Database"
    }
]

def generate_docs(module_hash) 
    cmd = %Q(bundle exec jazzy \\
    --module-version #{VERSION} \\
    --module #{module_hash[:name]} \\
    --output docs/html/#{module_hash[:name]} \\
    --xcodebuild-arguments -workspace,safe.xcworkspace,-scheme,#{module_hash[:name]} \\
    --readme #{module_hash[:path]}/README.md
)
    puts "Generating docs for module #{module_hash[:name]}"
    puts cmd
    abort unless system(cmd)
end

if ARGV.empty? 
    modules.each { |m| generate_docs m }
else
    to_generate = modules.select { |m| ARGV.member? m[:name] }
    abort "No matching modules found. Available are: #{modules.map {|x| x[:name] }.join(", ")}" if to_generate.empty?
    to_generate.each { |m| generate_docs m }
end