=========
Changelog
=========

The format is based on `Keep a Changelog`_ 
and this project adheres to `Semantic Versioning`_.

.. copy-paste the latest version update format and remember to add URL
   at the end of this file.

`1.11.1`_ - 2019-12-16
======================
Changed
--------
- Using new MultiSend contract instead of old one.
- Process push notifications on app startup if the notification was not opened manually.
- Fix crash in resuming recovery for some user.

`1.11.0`_ - 2019-12-09
======================
Added
------
- Batch Transactions from WalletConnect (`gs_multi_send`)

Changed
--------
- Reveal password button on password inputs
- Gnosis Authenticator usage is restricted only to the receovery of the safe.
- Fixed crashing when safe creation transaction hash is not available during safe creation.

`1.10.0`_ - 2019-11-20
======================
Added
--------
- ENS name option for address input on send, recover, and address book entry screens
- ENS reverse resolution of the address book entry's address

Changed
--------
- Fixed crash for devices running iOS 12.4.3
- Fixed bugs and crashes

`1.9.1`_ - 2019-11-07
======================
Changed
--------
- Fix for the Authenticator: safeCreation with owner list
- Fix for crash on startup due to wrong migration
- Fix for crash on startup due to inconsistent data (Portfolio table)

`1.9.0`_ - 2019-11-01
======================
Added
--------
- Address Book

Changed
--------
- Safe names are now stored as address book entries
- Stability improvements

`1.8.1`_ - 2019-10-09
======================
Changed
--------
- Enabled iOS 12 support
- Fixed issue with Contract Upgrade Onboarding's "Next" button

`1.8.0`_ - 2019-10-04
======================
Changed
--------
- Menu structure changed: added recover and create safe from menu.
- Improvements in memory management

Added
-------
- Support for multiple safes
- Switch Safe command
- Remove Safe flow

`1.7.0`_ - 2019-09-20
======================
Changed
--------
- All static libraries in the project converted to frameworks to workaround
  bug in Xcode with static Swift libraries.
- 2-factor authentication flows changed to select between Gnosis Authenticator
  and Status Keycard. Flows affected:
  
  + Create Safe - added new onboarding screens, added 3-step header to the screens.
  + Recover Safe
  + Connect Authenticator -> renamed to Enable 2FA
  + Disconnect Authenticator -> renamed to Disable 2FA
  + Replace Authenticator -> renamed to Replace 2FA

- UI adjustments, crash and bug fixes

Added
-------
- iOS 13 support - dark mode temporary opted out
- Added Keycard.swift and secp256k1.swift as Swift PM dependencies
- Status Keycard support as a 2-factor authenticator
  
  + Pairing with a Keycard - SKPairViewController
  + Initializing the Keycard - SKActivateViewController
  + Signing with the Keycard - SKSignWIthPinViewController

`1.6.0`_ - 2019-08-27
======================
Changed
--------
- WalletConnect - handle optional fields in eth_sendTransaction
- Minor bugs fixes

Added
-------
- Contract upgrade up to version 1.0.0 for old contract version users

`1.5.0`_ - 2019-08-06
======================
Changed
--------
- Rebranding - updated colors and texts
- Updated README.md with notes on how to build the project
- Fixed bug with refresh of push tokens

Added
-------
- Auto-cleanup of stale (invisible) transactions
- Get In Touch screen from Menu
- Incoming transactions containing data or delegateCalls are blocked now
- "Rate app" in the Menu
- Using new endpoint to check if the safe was already created

`1.4.0`_ - 2019-07-23
======================
Changed
--------
- Various stability improvements
- Updated README.md with notes on how to build the project

Added
-------
- Added support for WalletConnect protocol v1.0.0-beta

`1.3.1`_ - 2019-06-19
======================
Changed
-------
- Fixed various issues with networking and crashes
- If Touch ID or Face ID cancelled then we don't block the interface
- Fixed bug coming from private key derivation (31 byte vs 32 bytes)
- Fixed broken gesture of "swipe to go back"

`1.3.0`_ - 2019-06-06
======================
Added
-----
- Ability to pay with a ERC20 token for any safe transaction

Changed
-------
- Using safe contracts v1.0.0

  + Changed API calls to v2 for safe creation, transaction estimation
  + Changed hashing scheme based on master copy contract address

- Updated UI designs of most of the screens

  + Menu redesign
  + Send flow
  + Onboarding screens
  + Create Safe flow
  + Recover Safe flow
  + All owner modification flows
  + Main screens
  + Added 'success' screens to all transaction flows

- Refactored various parts of the app

  + Merged several flow coordinators into MainFlowCoordinator
  + Merged SegmentViewController into MainViewController
  + To enable token payment, touched everywhere where gas token was used.
  + Renamed flows and view controllers according to project's unified screen names.

- Improved stability in database migrations


`1.2.0`_ - 2019-04-24
======================
Added
-----
- Tracking of all screen views
- Change password in menu
- Localization keys aligned on all screens
- Firebase performance tracking library added
- New "Licenses" item in menu

Changed
-------
- Setup password screens redesign
- Push token endpoint changed to /v2/auth
- App version string in menu
- Swift 5 update
- Bug fixes and stability improvements

`1.1.0`_ - 2019-03-19
======================
Added
-----
- Manage safe browser extension

  + Replace browser extension
  + Connect browser extension
  + Disconnect browser extension
  + Resync with browser extension
  
- Tracking

  + Onboarding main actions tracking

Changed
-------
- Fixed app freezing after unlocking a phone
- Changed tokens endpoint

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

.. _1.11.1: https://github.com/gnosis/safe-ios/tree/1.11.1
.. _1.11.0: https://github.com/gnosis/safe-ios/tree/1.11.0
.. _1.10.0: https://github.com/gnosis/safe-ios/tree/1.10.0
.. _1.9.1: https://github.com/gnosis/safe-ios/tree/1.9.1
.. _1.9.0: https://github.com/gnosis/safe-ios/tree/1.9.0
.. _1.8.1: https://github.com/gnosis/safe-ios/tree/1.8.1
.. _1.8.0: https://github.com/gnosis/safe-ios/tree/1.8.0
.. _1.7.0: https://github.com/gnosis/safe-ios/tree/1.7.0
.. _1.6.0: https://github.com/gnosis/safe-ios/tree/1.6.0
.. _1.5.0: https://github.com/gnosis/safe-ios/tree/1.5.0
.. _1.4.0: https://github.com/gnosis/safe-ios/tree/1.4.0
.. _1.3.1: https://github.com/gnosis/safe-ios/tree/1.3.1
.. _1.3.0: https://github.com/gnosis/safe-ios/tree/1.3.0
.. _1.2.0: https://github.com/gnosis/safe-ios/tree/1.2.0
.. _1.1.0: https://github.com/gnosis/safe-ios/tree/1.1.0
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
