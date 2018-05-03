=========
Changelog
=========

The format is based on `Keep a Changelog`_ 
and this project adheres to `Semantic Versioning`_.

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

.. _0.2.0: https://github.com/gnosis/safe-ios/tree/0.2.0
.. _0.1.0: https://github.com/gnosis/safe-ios/tree/0.1.0
.. _Keep a Changelog: https://keepachangelog.com/en/1.0.0/
.. _Semantic Versioning: https://semver.org/spec/v2.0.0.html
