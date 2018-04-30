============
Architecture
============

The architecture follows a hexagonal high-level architecture pattern. Currently, there are the following modules, from high-level to low-level.

    * safe iOS app
    * safeUIKit - components used in the app.
    * IdentityAccess - user and authentication related components.

        - IdentityAccessApplications - implementations of use-cases using domain model objects
        - IdentityAccessDomainModel - domain model objects. All business logic lives here.
        - IdentityAccessImplementations - implementations of external services and repositories of domain model and application modules.
    
    * Common - common code.

        - CommonTestSupport - common code used in tests.

Architectural Types
-------------------

From the UI perspective, the app consists of View Controllers that talk to Application Services to display data and perform use case tasks. 

Routing logic between view controllers is handled through Flow Coordinators that also may talk to Application Services to make decisions which controllers to present.

Application Services are coordinating incoming actions to invoke appropriate methods on the Domain Model objects. 
Application Services are stateless. 
Application Services send data back to clients using Data Objects, such as DraftSafe.

Domain Model objects are entities, value objects, domain services and repositories. Entities are types with identity and behavior, that may change over their lifetime.
Value Objects are types that hold value but not identity, they are replacable with objects with the same properties, and they are immutable.
Domain Services are used to implement complex operations involving many entities or complex busines processes; they are stateless.
Repositories provide access to collections of domain objects.

The figure below shows safe's current archtiecture. Libraries, frameworks and iOS app are shown in hexagons. Further lines detail important class relationships.

.. image:: png/Current\ Architecture.png
   :width: 800
