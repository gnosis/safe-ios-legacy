=========
Changelog
=========

The format is based on `Keep a Changelog`_ 
and this project adheres to `Semantic Versioning`_.

`1.0.1`_ - 2019-01-23
======================
Changed
-------
- Stability improvements

  + Fixing crash in background
  + Fixing random crash after transaction submission
  + Fixing crash on review transaction screen when network is lossy

`1.0.0`_ - 2018-12-18
=====================
Changed
-------
- Bug fixes

`0.10.0`_ - 2018-12-13
======================
Added
-----
- Safe recovery
- Replace recovery phrase

`0.9.1`_ - 2018-12-05
=====================
Changed
-------
- New repository implementations
- Changed token list JSON structure and udpated with new list

Added
-----
- Ability to run migrations in future app updates. Note, that current update is still incompatible with previous versions. Users must delete previous app before installing this version.

`0.9.0`_ - 2018-11-30
=====================
Changed
-------
- UI design changes and use of components 😻
    - Backgrounds changed to white
    - Confirm Transaction screen
    - Send Transaction screen
    - Transaction details screen (incl. empty state)
    - Transaction list screen
- Fixed crashes 💥
- Coding guidelines extended
- Fixed UX bugs 🐛
    - Manage tokens (hiding glitch, adding delay)
    - Cancelling and restarting safe creation
    - Comma/dot in the amount input field in Send screen
    - Screen titles and back button wordings
    - Blockies images (identicons) aligned with other platforms
    - Added "Continue" button to password setup screens
    - "No tripple character" password reuirement behavior fixed
    - Mnemonic word inputs trim whitespaces now
- New lanes added in Fastfile
- ``DesignableView`` changed to ``BaseCustomView``, ``BaseCustomLabel`` and ``BaseCustomButton``
- Moved from Travis CI to Jenkins! 👏

Added
-----
- New UI components 😻
    - TransactionHeaderView
    - TransactionFeeView
    - TransferView
    - TransactionConfirmationView
    - AmountLabel
    - AddressInput
    - EthereumAddressLabel
    - FullEthereumAddressLabel
- Implemented ``sendTransaction`` push handling 📣
- Notification Service Extension to load localized message

`0.8.2`_ - 2018-11-13
=====================
Changed
-------
- Forced to use always encrypted AppConfig for PreRelease and Release configurations

`0.8.1`_ - 2018-11-08
=====================
Changed
-------
- Fixed confusing setup password wording

`0.8.0`_ - 2018-10-28
=====================
Added
-----
- Terms of Use screen
- Guidelines screen
- Input components in SafeUIKit
    - TextInput
    - VerifiableInput
    - TokenInput
    - AddressInput
- Proxy classes for contracts communication (ERC20, safe)
- Transaction list screen functionality implementation
    - Querying the database
    - Synchronization of pending transactions
- Transaction details screen functionality implementation
    - Subscribing on transaction updates
- Sending ERC20 tokens
- Made browser extension
- PreRelease configuration (production-rinkeby services)

Changed
-------
- Hashing of transactions according to EIP712 implementation
- Changed confirmation counts for wallet from 2/3 to 1/3 and 2/4
- Nonce is fetched from relay service instead of the contract
- Designs of onboarding screens

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
==================
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
=====================
Changed
-------
- Fixed bug in safe creation arised because of API response format change.

`0.4.0`_ - 2018-07-09
=====================
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
=====================
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
=====================
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
=====================
Added
-----
- Setting master password
- Unlocking app

.. _1.0.1: https://github.com/gnosis/safe-ios/tree/1.0.1
.. _1.0.0: https://github.com/gnosis/safe-ios/tree/1.0.0
.. _0.10.0: https://github.com/gnosis/safe-ios/tree/0.10.0
.. _0.9.1: https://github.com/gnosis/safe-ios/tree/0.9.1
.. _0.9.0: https://github.com/gnosis/safe-ios/tree/0.9.0
.. _0.8.2: https://github.com/gnosis/safe-ios/tree/0.8.2
.. _0.8.1: https://github.com/gnosis/safe-ios/tree/0.8.1
.. _0.8.0: https://github.com/gnosis/safe-ios/tree/0.8.0
.. _0.7.0: https://github.com/gnosis/safe-ios/tree/0.7.0
.. _0.6.0: https://github.com/gnosis/safe-ios/tree/0.6.0
.. _0.4.1: https://github.com/gnosis/safe-ios/tree/0.4.1
.. _0.4.0: https://github.com/gnosis/safe-ios/tree/0.4.0
.. _0.3.0: https://github.com/gnosis/safe-ios/tree/0.3.0
.. _0.2.0: https://github.com/gnosis/safe-ios/tree/0.2.0
.. _0.1.0: https://github.com/gnosis/safe-ios/tree/0.1.0
.. _Keep a Changelog: https://keepachangelog.com/en/1.0.0/
.. _Semantic Versioning: https://semver.org/spec/v2.0.0.html
