=========
Changelog
=========

The format is based on `Keep a Changelog`_ 
and this project adheres to `Semantic Versioning`_.

Unreleased
==========
Added
-----
- Implementation of IdentityAccess logic with User, Gatekeeper, AuthenticationApplicationService and others.
- SQLite database implementation of repositories.
- New safe flow with setting up mnemonic and QR code detection for chrome browser extension integration.
- Added RSBarcodes dependency
- Added CHANGELOG.rst (this file)

Removed
-------
- Old code for Account and all related things.

Changed
-------
- Dependency configuration is now done through Dependencies folder with git submodules and Library subproject.
- PortAdapter changed to Implementations.

`0.1.0`_ - 2018-04-05
==================
Added
-----
- Setting master password
- Unlocking app

.. _0.1.0: https://github.com/gnosis/safe-ios/tree/0.1.0
.. _Keep a Changelog: https://keepachangelog.com/en/1.0.0/
.. _Semantic Versioning: https://semver.org/spec/v2.0.0.html
