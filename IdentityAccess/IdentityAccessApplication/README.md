# IdentityAccessApplictaion module

This module contains AuthenticationApplicationService that implements application use cases related to user regsitration, 
authentication behaviors and allows to configure authentication system's parameters.

The application service implements those use cases with objects of another module, `IdentityAccessDomainModel`. 

At the same time, this module provides mock implementation of the application service - `MockAuthenticationService` that can be
used to mock different authentication behaviors in tests or demonstrations of the user interface.

The clients of the `AuthenticationApplicationService`, which are user interface layer objects, must have no direct access to 
domain model objects. That's why the application service's API uses either simple data types, such as String and Int, or data structures
that are supposed to be used by the clients.

Note, that the application service is stateless and does not have any persisted state. All state and logic delegated to the domain model
objects and protocols.
