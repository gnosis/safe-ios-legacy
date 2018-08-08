# IdentityAccessImplementations module
This module implements services and repositories defined in IdentityAccessDomainModel and IdentityAccessApplication modules. 

There are 2 alternative implementations for each repository: in-memory and database-based. For each service, real implementation
and mock service implementations are provided. In-memory and mock implementations are used in automated tests.

This module has additional Resources module which holds Localized stirngs used for biometry prompts to activate and authenticate user.
