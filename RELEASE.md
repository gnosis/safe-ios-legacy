- [ ] 0. Create release task in ticket tracker.
- [ ] 1. Notify Product Owner and QA about expected time of submission to the App Store
so that all of the meta texts (descriptions, titles, keywords) are ready on time.
- [ ] 2. Create and push the release branch

```
    $> git checkout master -b release/X.Y.Z
    $> git push -u origin release/X.Y.Z
```

- [ ] 3. Update app version.

```
    $> cd safe; agvtool new-marketing-version X.Y.Z;cd ..
```

- [ ] 4. Edit CHANGELOG.rst and add info about new version.
- [ ] 5. Create pull-request with these changes and merge it.

- [ ] 6. Test AdHoc version. Fix found defects and improvements. Then test again. Test the functionality that was touched (added, changed, or removed) during the release. Remember about translations, tracking and minor details.

  - [ ] a. Run translation script: `bundle exec fastlane translate`
  - [ ] b. Look through the pull requests merged since the last release to identify areas of change.

- [ ] 7. For production (Mainnet) app version:

  - [ ] a. Create new version number in the App Store Connect.
  - [ ] b. Submit new build for release.

```
  $> bundle exec fastlane release
```
- 
  - [ ] c. Wait until the build is processed. Submit new version for the TestFlight Beta Review.

- [ ] 8. For prerelease (Rinkeby) app version:

  - [ ] a. Change the version number in the App Store Connect.
  - [ ] b. Submit new build for prerelease. 

```
  $> bundle exec fastlane prerelease
```
- 
  - [ ] c. Wait until the build is processed. Submit new version for the TestFlight Beta Review.

- [ ] 9. When both builds are available for testers and groups, notify QA and the team.
- [ ] 10. Fix all critical issues found by QA and other testers. Repeat steps 6 - 10.
- [ ] 11. Get the approval from QA and Product Owner. 
  Verify that all required texts are updated in the App Store Connect. 
  Check that all of the information and the app contents
  comply with the [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/).
  Submit the app for review. Notify the team that release was submitted using the template below:

```
@here Hi everyone! We have submitted new iOS app vX.Y.Z for review to the App Store.
```

- [ ] 12. Pull the dSYM (debug symbols) from the App Store and push them to Fabric (Crashlytics)

```
  $> bundle exec fastlane testflight_dsyms
```

- [ ] 13. Release the app when it is approved by App Store Review team. Notify the team using the following template:

```
@here Hi everyone! We have released the iOS app vX.Y.Z to the App Store and it will soon be available for download.
```

- [ ] 14. Tag the latest commit in the release branch

```
   $> git tag -am "X.Y.Z" X.Y.Z
   $> git push --tags
```

- [ ] 15. Merge the release branch to master branch via new pull-request.
