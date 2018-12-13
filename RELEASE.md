- [ ] 0. Create release task in ticket tracker.
- [ ] 1. Create and push the release branch

```
    $> git checkout master -b release/X.Y.Z
    $> git push -u origin release/X.Y.Z
```

- [ ] 2. Update app version.

```
    $> cd safe; agvtool new-marketing-version x.x.x;cd ..
```

- [ ] 3. Edit CHANGELOG.rst and add info about new version.
- [ ] 4. Create pull-request with these changes and merge it.
- [ ] 5. Test AdHoc version.
- [ ] 6. Release to testers or to app store
- [ ] 7. Tag the released commit and push tags

```
   $> git tag -am "x.x.x" x.x.x
   $> git push --tags
```
