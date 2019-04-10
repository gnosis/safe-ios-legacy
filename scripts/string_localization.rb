#! /usr/bin/env ruby

class StringLoclaization 
    attr_accessor :comment, :key, :value
end

# parses .strings file and returns array of StringLocalizations
def localizations(file)
    contents = File.read(file, encoding: 'UTF-8')
    # /(?:\/\* (.*?) \*\/\n)?"(.*?)" = "(.*?)";/m
    #  (?: - start of the non-capturing group (to skip comment matching if it does not exist)
    #     \/\* - start of the comment marker "/*"
    #          (.*?) - string content of the comment. *? means non-greedy match - it will stop after first match
    #               \*\/\n - end of the comment marker */ with a newline
    #                     )? - end of the non-capturing group, means that comment is optional
    #                        "(.*?)" - key of the translation, captured group. *? means non-greedy match
    #                               = "(.*?)"; - value of the translation, captured group, *? means non-greedy match
    #                                         /m - Treat a newline as a character matched by . (any character). This 
    #                                              allows to capture newlines insid comments and translations.
    contents.scan(/(?:\/\* (.*?) \*\/\n)?"(.*?)" = "(.*?)";/m).map { |comment, key, value|
        localization = StringLoclaization.new
        localization.comment = comment
        localization.key = key
        localization.value = value
        localization
    }
end

def save(filename, localizations_array)
    File.open(filename, 'w:UTF-8') { |f|
        f.truncate(0)
        localizations_array.each do |localization|
            comment = (localization.comment.nil? || localization.comment.empty?) ? "No comment provided" 
                                                                                 : localization.comment
            f.puts "/* #{comment} */"
            f.puts "\"#{localization.key}\" = \"#{localization.value}\";"
            f.puts ""
        end
    }
end