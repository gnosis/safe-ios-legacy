# IdentityAccessDomainModel module
This module is all about registering and authenticating a user. 

There is only one user, and they authenticates by password. Authentication behavior is implemented in Gatekeeper and Session entites.
These entites are used in IdentityAccess domain service. Also, user can be authenticated by biometry, if it is available and activated.

State of authentication is stored in different repositories - SingleUserRepository, SingleGatekeeperRepository.
