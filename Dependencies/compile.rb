require 'yaml'

sdks = ["iphoneos", "iphonesimulator"]
deps = YAML.load_file('Dependencies.yml')
deps.each do |dependency|   
    if dependency.is_a?(Hash)
        project = dependency.first.first
        target = dependency.first.last
    else
        project = dependency
        target = dependency
    end
    sdks.each do |sdk|
        cmd = ["xcodebuild -project #{project}/#{project}.xcodeproj/",
            "-target #{target} -sdk #{sdk}",
            "SYMROOT='${SRCROOT}/../../Build/'", 
            "DSTROOT='${SRCROOT}/../../Library/${PLATFORM_NAME}'",
            "FRAMEWORK_SEARCH_PATHS='$(inherited) ${SRCROOT}/../../Library/${PLATFORM_NAME}'",
            "INSTALL_PATH=/ DWARF_DSYM_FOLDER_PATH='${DSTROOT}'",
            "VALID_ARCHS='arm64 armv7 armv7s i386 x86_64'",
            "SKIP_INSTALL=NO install"].join(" ")
        puts cmd
        abort unless system cmd
    end
end
