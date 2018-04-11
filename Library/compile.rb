require 'yaml'

sdks = ["iphoneos", "iphonesimulator"]
deps = YAML.load_file('Library.yml')
deps.each do |dependency|
    if dependency.is_a?(Hash)
        project = dependency.first.first
        target = dependency.first.last
    else
        project = dependency
        target = dependency
    end
    sdks.each do |sdk|
        cmd = ["xcodebuild -project #{project}/src/#{project}.xcodeproj/",
            "-target #{target} -sdk #{sdk}",
            "SYMROOT='${SRCROOT}/../../../Build/'", 
            "DSTROOT='${SRCROOT}/../../${PLATFORM_NAME}'",
            "FRAMEWORK_SEARCH_PATHS='$(inherited) ${SRCROOT}/../../${PLATFORM_NAME}'",
            "INSTALL_PATH=/ DWARF_DSYM_FOLDER_PATH='${DSTROOT}'",
            "VALID_ARCHS='arm64 armv7 armv7s i386 x86_64'"
            "SKIP_INSTALL=NO install"].join(" ")
        puts cmd
        system cmd
    end
end
