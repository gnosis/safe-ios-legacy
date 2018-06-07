#! /usr/bin/env ruby

# Hello, developer! Please don't mind comments in this file
# since I'm not expecting every fellow project developer to know Ruby.
# -- @DmitryBespalov

# get project version and remove trailing newline char with chomp
# all caps variables are constants that can be globally access within the script.
VERSION = `cd safe; agvtool mvers -terse1;`.chomp

# This array is used later to generate docs for each module
modules = [
    {
        name: "Common",
        path: "Common/Common" # path to README folder
    },
    {
        name: "Database",
        path: "Common/Database"
    }
]

# Runs jazzy (https://github.com/realm/Jazzy) to generate docs
def generate_docs(module_hash) 
    # compose a shell command, substituting module name and VERSION where necessary.
    cmd = %Q(bundle exec jazzy \\
    --module-version #{VERSION} \\
    --module #{module_hash[:name]} \\
    --output docs/html/#{module_hash[:name]} \\
    --xcodebuild-arguments -workspace,safe.xcworkspace,-scheme,#{module_hash[:name]} \\
    --readme #{module_hash[:path]}/README.md
)
    # Printing status and shell command before executing it.
    puts "Generating docs for module #{module_hash[:name]}"
    puts cmd
    # execute command in variable `cmd` and abort script if there was an error
    abort unless system(cmd)
end

# if script arguments empty, generate docs for all modules
if ARGV.empty? 
    modules.each { |m| generate_docs m }
else
    # if script arguments not empty, find modules with names matching command line arguments
    to_generate = modules.select { |m| ARGV.member? m[:name] }
    # stop if nothing found
    abort "No matching modules found. Available are: #{modules.map {|x| x[:name] }.join(", ")}" if to_generate.empty?
    # generate docs for each found module
    to_generate.each { |m| generate_docs m }
end
