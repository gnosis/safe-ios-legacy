#! /usr/bin/env ruby
require 'yaml'

filter_deps = ARGV
sdks = ["iphoneos", "iphonesimulator"]
deps = YAML.load_file('Dependencies.yml')
deps.each do |dependency|   
    if dependency.is_a?(Hash)
        dependency_name = dependency.first.first 
        value = dependency.first.last
        if value.is_a?(Hash)
          project = value.first.first
          target = value.first.last
        else
          project = "#{dependency_name}/#{dependency_name}.xcodeproj"
          target = value
        end
    else
        dependency_name = dependency
        project = "#{dependency}/#{dependency}.xcodeproj"
        target = dependency
    end
    unless filter_deps.empty? || filter_deps.member?(dependency_name)
      next
    end
    sdks.each do |sdk|
        cmd = ["xcodebuild -project #{project}",
            "-target #{target} -sdk #{sdk}",
            "-configuration Release",
            "SYMROOT='${SRCROOT}/../../Build/'", 
            "DSTROOT='${SRCROOT}/../../Library/${PLATFORM_NAME}'",
            "FRAMEWORK_SEARCH_PATHS='${SRCROOT}/../../Library/${PLATFORM_NAME}'",
            "LIBRARY_SEARCH_PATHS='${SRCROOT}/../../Library/${PLATFORM_NAME}'",
            "HEADER_SEARCH_PATHS='${SRCROOT}/../../Library/${PLATFORM_NAME}/include'",
            # PromiseKit couldn't be built because the emitted objc-header "PromiseKit-Swift.h"
            # could not be found by the build system. Commenting the INSTALL_PATH
            # solved it, but that means we have to move the products after
            # the command finishes instead of relying on Xcode's installation.
            # "INSTALL_PATH=/", 
            "DWARF_DSYM_FOLDER_PATH='${DSTROOT}'",
            "DEBUG_INFORMATION_FORMAT=dwarf-with-dsym",
            "COPY_PHASE_STRIP=NO",
            "GCC_GENERATE_DEBUGGING_SYMBOLS=YES",
            "VALID_ARCHS='arm64 armv7 armv7s i386 x86_64'",
            "SKIP_INSTALL=NO install"].join(" ")
        puts cmd
        abort unless system cmd

        # move the built products to the destination because the INSTALL_PATH 
        # could not be used.
        destination = "../Library/#{sdk}/"
        installation_dir = "../Library/#{sdk}/Library/Frameworks"
        product = "#{dependency_name}.framework"
        abort unless system "mv #{installation_dir}/#{product} #{destination}"
        abort unless system "rm -rf #{installation_dir}"
    end
end
