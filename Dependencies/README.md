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
