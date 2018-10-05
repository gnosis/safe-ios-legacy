=========
Changelog
=========

The format is based on `Keep a Changelog`_ 
and this project adheres to `Semantic Versioning`_.

`0.7.0`_ - 2018-10-05
=====================
Added
-----
- Manage tokens functionality:
    - Display tokens on Main screen
    - Manage tokens screen
    - Add new token screen
    - Syncronization of tokens with service
    - Syncronization of balances with blockchain
- Share address
- Design adjustments for main screen and menu

Changed
-------
- Updated to swift 4.2
- Dropped iOS 10 support
- Optimized Travis build time
- WalletApplicationService refactored

`0.6.0`_ - 2018-08-09
=====================
Added
-----
- Configuration management in the AppConfig.yml file
- Sending ETH transaction from mobile app
- Handling incoming accept and reject transaction notifications from browser extension
- Source code documentation of IdentityAccess* modules and MultisigWalletDomainModel module

Changed
-------
- Fixed TODOs in code

0.5.0 - 2018-07-18
=====================
Added
-----
- Firebase SDK integration
- Push notification authorization and sending / receiving
- Notification to browser extension when safe is created

Changed
-------
- Merged Ethereum subproject with MultisigWallet subproject
- Refactored error handling

`0.4.1`_ - 2018-07-11
==========
Changed
-------
- Fixed bug in safe creation arised because of API response format change.

`0.4.0`_ - 2018-07-09
==========
Added
-----
- Added source code documentation to common modules.
- Added UI stubs for the screens of main flow:
    - Main screen
    - New transaction configuration screen
    - Pending transaction screen
    - Transaction details
    - Menu screen
- Added ``Transaction`` entity in MultisigWalletDomainModel.
- Added transaction repository with SQLite database implementation.
- Implemented QR code payload verification for pairing with browser extension.
    - Extracting owner address
    - Check expiration date
    - Sign extension address
- Implemented pairing request to notification service (HTTPNotificationService).
- Added copy mnemonic and copy safe address buttons in onboarding.
- Added TokenInput component with separate fields for integer and fractional parts.
- Added various ``eth_`` methods to Infura service.
- Added integration tests for transaction sending.
- Added integration test for safe creation, start to end.
- Added integration test for pairing with browser extension.
- Implemented GnosisTransactionRelayService calls:
    - POST /safes/
    - PUT /safes/<address>/funded
    - GET /safes/<address>/funded

Changed
-------
- Replaced mock services with real service implementations in ``AppDelegate.swit``.
- Moved integration tests to ``safeTests`` target and to separate scheme.


`0.3.0`_ - 2018-06-11
==========
Added
-----
- Created new ``MultisigWallet`` project with DomainModel, Application and Implementations libraries.
- New ``Wallet``, ``Portfolio`` and ``Owner`` objects
- New ``Ethereum`` project
- New Pending Safe screen and basic UI main screen.
- Mock implementations of Transaction Relay Service and Infura service.

Changed
-------
- Moved all view controllers and flow coordinators to new SafeAppUI framework.
- Renamed safeUIKit* targets to capitalized names: SafeUIKit*.
- Moved ``Database`` and SQLite implementations into ``Database`` library.

`0.2.0`_ - 2018-05-03
==========
Added
-----

- New safe configuration screen.
- Browser extension screen with QR code reading.
- Mnemonic generation and confirmation screens.
- Added RSBarcodes dependency.
- Added CHANGELOG.rst (this file).
- SQLite database implementation.
- Documentation of architecture in the docs folder.

Removed
-------
- Old code for Account and all related things.

Changed
-------
- Dependency configuration is now done through Dependencies folder with git submodules and Library subproject.
- Implementation of IdentityAccess domain logic with User, Gatekeeper, AuthenticationApplicationService and others.

`0.1.0`_ - 2018-04-05
==================
Added
-----
- Setting master password
- Unlocking app

.. _0.7.0: https://github.com/gnosis/safe-ios/tree/0.7.0
.. _0.6.0: https://github.com/gnosis/safe-ios/tree/0.6.0
.. _0.4.1: https://github.com/gnosis/safe-ios/tree/0.4.1
.. _0.4.0: https://github.com/gnosis/safe-ios/tree/0.4.0
.. _0.3.0: https://github.com/gnosis/safe-ios/tree/0.3.0
.. _0.2.0: https://github.com/gnosis/safe-ios/tree/0.2.0
.. _0.1.0: https://github.com/gnosis/safe-ios/tree/0.1.0
.. _Keep a Changelog: https://keepachangelog.com/en/1.0.0/
.. _Semantic Versioning: https://semver.org/spec/v2.0.0.html
