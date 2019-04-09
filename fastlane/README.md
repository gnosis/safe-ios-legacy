fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs tests
### ios test_all
```
fastlane ios test_all
```
Runs all tests
### ios fabric
```
fastlane ios fabric
```
Build and distribute build to Fabric Beta
### ios prerelease
```
fastlane ios prerelease
```
Submit a new PreRelease Rinkeby Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios release
```
fastlane ios release
```
Submit new Release (Production Mainnet) Build to Apple TestFlight

This will also make sure the provisioning profile is up to date
### ios testflight_dsyms
```
fastlane ios testflight_dsyms
```
Download latest dsyms
### ios add_devices
```
fastlane ios add_devices
```
Adds devices from the ../gnosis-ios-certificates/devices.txt file

Provide your FASTLANE_USER and FASTLANE_PASSWORD in environment variables.
### ios produce_app_ids
```
fastlane ios produce_app_ids
```
Creates necessary App IDs.

Provide your FASTLANE_USER and FASTLANE_PASSWORD in environment variables.
### ios certificates
```
fastlane ios certificates
```
Downloads provisioning profiles and certificates. Creates missing ones if passed 'force:true' option.

If you pass 'force:true', then provide your FASTLANE_USER and FASTLANE_PASSWORD in environment variables.
### ios translate
```
fastlane ios translate
```
Downloads translations from Lokalise and updates all Localizable.strings files in the project

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
