# safe-ios 

[![Build Status](https://padmeamidala.ngrok.io/buildStatus/icon?job=safe-ios/master)](https://padmeamidala.ngrok.io/job/safe-ios/job/master/) [![codecov.io](https://codecov.io/gh/gnosis/safe-ios/branch/master/graphs/badge.svg)](https://codecov.io/gh/gnosis/safe-ios/branch/master)

[<img src="https://user-images.githubusercontent.com/1630974/54477357-3ef93080-4807-11e9-9af5-d7c1311e7da5.png" alt="Download in the AppStore" width="200">](https://appstore.com/gnosissafesmartwallet)

# Getting Started

To set up all project dependencies, run from the project directory in terminal:

```
$> scripts/bootstrap.sh
```

To get the app built, copy example files:

```
$> cp .env.default.example .env.default
$> cp AppConfig.example.yml AppConfig.yml
$> cp GoogleService-Info.example.plist safe/safe/GoogleService-Info.plist
```

Then comment out the lines 40-43 in the safe/safe/AppDelegate.swift file to disable Firebase. This will make your app running in simulator.
