# Updating a dependency to the new version

Checkout new version in submodule:

```
cd Dependencies
git -C <DepName> <tag>
```

Then run compile script which will build and install new version:

```
ruby compile.rb <DepName>
```

# Adding 3rd party dependency as a submodule.

- Add submodule:

```
cd Dependencies
git submodule add --name <name> <link>
```

- Add new framework to Library project targets
- Remove added framework folder from Library project

For added framework 

- Remove in build settings:
  - iOS deployment target
  - Debug information format
  - Info.plist
  - Defines module
- Remove all build phases
- Remove build settings from the framework target
- Target -> General -> Uncheck 'Automatically manage signing'
- Add runscript build phase:
  - Add Shell script `bash ${SRCROOT}/copy-framework.sh`
  - Add Input File `$(SRCROOT)/${PLATFORM_NAME}/${PRODUCT_NAME}.framework`
  - Add Output File `${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework`
  - Add Output File `${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.framework.dSYM`

You need to add the new framework to all dependent projects like safe, SafeUIKIt, unit tests and UI test targets where it needed.

For example, if you link the framework to SafeAppUI target, then you have to embed or link it to everywhere the SafeAppUI is used: in SafeUIKitDemo target (embed framework), safe target in safe project, and unit test target SafeAppUIUintTests.
Also, for unit test target, remember to add the framework to 'Copy Files' phase so that framework is present when unit test target executes. Also add the framework to linked frameworks in SafeUIKitTests. Finally, add your library as a Target Dependency to SafeUIKitDemo target so that it builds before the demo app.

