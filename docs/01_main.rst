==================
Architecture
==================

Bird's Eye View
================

In very broad terms, the iOS app is one subsystem of many that work together to implement a convenience and secure way to manage digital assets belonging to a user.

The whole system consists of the following parts:

* Executor App (iOS, Android)
* Authenticator App (Chrome Browser Extension)
* Ethereum Node Service (Infura JSON-RPC API)
* Gnosis Safe Relay Service (REST API)
* Gnosis Safe Notification Service (REST API)
* Google Firebase Services (Framework, Cloud Messaging for Android)
* APNS Service (iOS)
* Gnosis Safe Website (Web)
* Ethereum Browser Website (Web, Etherscan)

The iOS app is a rich client using REST backend applications (Gnosis Safe services), and other services to interact with the Ethereum - a distributed network of blockchain nodes.

iOS App Program Organization
=============================

Looking at the app's architecture, it consists of the following layers:

* User Interface Layer
* Business Logic Layer
* Service Layer

The overarching architectural pattern selected is "Ports and Adapter".
The rationale to select it was:

* We want the "core and plugin" architecture approach in order to modularize application subsystems into a conherent modules. This would increase maintainability and loose coupling since the subsystems will have few distinct responsibilities.
* We want to be able to test as much of the app as possible.
* We want to be able to easily replace service implementations or user interface and keep the business logic without changes.
* We want to be able to easily change business logic without much effect on the user interface.

Alternatives Considered
--------------------------

Apple's MVC
~~~~~~~~~~~~

This is the straightforward approach that is a default preferred architecture on iOS. It is good for small and medium-sized projects. From my experience, this architecture doesn't scale well and doesn't support flexibility and separation of concerns as good as other alternatives. 

The major issue with this approach for me is that the application is monolythic and the business logic exists in the same components as other UI code.

MVVM
~~~~~~~~

MVVM builds on the MVC with treating ``UIViewController`` as a "view" role and moving all controller and business logic into a separate "view model" object. This enables testability of the logic without testing user interface, and also enables user interface testing through mocking view models. 

Nevertheless, it seemed as a partial solution to the problem because it doesn't separate the business logic and other service components well enough. This pattern's scope is too narrow for selecting it as an architectural pattern.


Clean architecutre (VIPER)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The VIPER architectural pattern with View, Interactor, Presenter, Entity, and Router roles is a huge step into separating concerns of user interface, app navigation, business logic, putting a clear responsibilities to each role. To me it felt not as natural as ports and adapters because VIPER's approach creates far too many abstractions in place whithout need (for example, putting lots of interfaces (protocols) in between the aforementioned roles just to make each part testable and isolated). 

With some experience working with VIPER-based applications, it feels as it puts too much emphasis on the testability and separation of concerns and makes the architecture less understandable.

Uber's RIBs
~~~~~~~~~~~~

This approach is a "new" app architecture that claims testability, developer tooling and engineering team scalability as its main goals. It separates user interface and business logic concerns, and uses dependency injection and reactive approach to communicate state between objects. The approach is supported by code generation tools for scaffolding and bootstrapping. 

This is a custom architecture application that didn't have enough attention in the literature. The separation of UI and Business Logic is definitely a strenght, while decision to use DI and Rx extensively is opinionated and might not be flexible enough to support architecture evolution throughout the project life. 

The basic roles of the architecture are Router, Interactor, Presenter, View, Builder, Component and RIB. The RIB encapsulates state and is more of an Entity (similar to VIPER), and can be connected with other RIBs into a hierarchy. This RIB's state is then translated into UI (View) through the Presenter. 

Operations with different entities are belonging in Interactors. Based on Interactor actions, Router is used for managing navigation between different states of the application. All of the component roles are grouped into a module, or Component, and instantiated using Builder. 

Apparently, the arhcitecture features use of a specific object messaging technique, RX (reactive approach) with signals, filters, and subscriptions. 

To me there are several issues with this approach.

First, overly separated roles of Interactor and Entities, as it seems the Entity model is a bit anemic. 

Second, the preference of RX in object communication as the architectural decision seems immobilizing future possibilities and reducing architecture flexibility. 

Third, there seems few parallel hierarchies existing in the applicaiton: hierarchy of RIBS (Entities), hierarchy of Views (view controllers for UI), hierarchy of Presenters. 

These considerations were taken into account when considering this approach.

Closer Look At The Selected Architecture
-------------------------------------------

The **Ports and Adapter** architecture allows to separate core of the application - Domain Model - from the other concerns. The application's architecture is divided vertically into subsystems that correspond to separate subdomains found during the requirements analysis. 

These subdomains are:

* Identity and Access Context - context of system access control. It includes user authentication, session management and so on.
* Multi-signature Wallet Context - context of digital asset management using multi-signature wallet. It includes wallet, wallet transactions, signature collection processes and so on.
* Ethereum Context - Blockhain model and interaction context. It includes Ethereum types and models, such as Externally Owned Account, Contract Account, Ethereum Address, Transaction and so on.

The Multi-signature wallet context is intersecting with the Ethereum context, but does not fully include it, because the full Ethereum context is out of scope of the application (transaction hashes, blocks, and so on). Rather, the Ethereum context provides basic types (mostly value objects) for the Multi-signature wallet context. 

First two contexts are modeled as a Domain Model with a specific set of roles assigned to different types (classes). The domain models have facade providing data-object access to the model from the outside (user interface), and it also has service layer interfaces (ports) with implementations of those interfaces (adapters).

Major Building Blocks
~~~~~~~~~~~~~~~~~~~~~~

The major building blocks were mentioned above, so here we specify them explicitly and in more detail, with correspondence to actual subsystems (libraries, frameworks, app targets) in the iOS workspace.

Identity Access Context (Business Logic and Service Layers)
```````````````````````````````````````````````````````````````

Identity Access Domain Model
    models the access control context. Contains business logic for user authentication, system interaction sessions, access denial. Defines interfaces for access control-related repositories (persistence), biometric authentication services, and system clock service. This block can only talk directly to itself, and to services (Identity Access Implementations) - indirectly, through the defined ports (interfaces for persistence and other services).

Identity Access Application
    facade to the domain model that provides a data object API to the user interface. This block can only directly talk to the domain model's objects, and provide API for executing operations or reading data (in which case it returns Plain Data Objects). This block can only talk to Identity Access Domain Model. This block cannot talk to adapters (port implementations) directly, but only through Domain Model's port interfaces.

Identity Access Implementations
    adapter interfaces for the ports defined in the domain model. This includes such adapters, as SQLite Database Adapter implementing repositories, iOS Biometry adapter implementing authentication service, and iOS system clock adapter implementing clock service. This block can only talk to Domain Model objects directly, but none of other blocks - not application facade, not user interface.


Multisig Wallet Context (Business Logic and Service Layers)
`````````````````````````````````````````````````````````````````

Multisig Wallet Domain Model
    models the wallet context. Similar to Identity Access Domain Model, contains logic for the wallet creation, transaction sending, and so on. Defines interfaces for persistence, cryptographic services and network services. This block can only directly talk to the objects within itself, and indirectly with Multisig Wallet Implementations through the defined ports.

Multisig Wallet Application
    facade to the domain model, analogous to the Identity Access Application. This block can only directly use Multisig Wallet Domain Model, and indirectly Multisig Wallet Implementations through domain model's port interfaces.

Multisig Wallet Implementations
    implements services defined in the domain model. The services implemented correspond to the ones listed in the `Bird's Eye View`_. This block can only directly talk to the Multisig Wallet Domain Model to implement port interfaces.

User Interface (User Interface Layer)
``````````````````````````````````````````

Safe App UI
    the user interface, implementing the iOS app. This contains view controllers, views, and uses components defined in the Safe UI Kit. The UI talks to the facade, but not to the domain model or implementations. This block can only talk directly to Identity Access Application and Multisig Wallet Application, but not to domain models or implementations.

Safe UI Kit
    contains reusable components for the user interface. This block does not know anything about domain models, application layers, or implementations. This is only a User Interface toolkit.

safe 
    this is an iOS app target that ties together all the blocks above. This app is a place where the dependency injection is configured, the databases are initialized, and other interfaces with operating systems are used to connect everything together to work as an application. It is a good place to place a "relay" classes that facilitate communication between different domain models (hence, between different contexts) through a) implementation of one model's port interface and b) using other domain model's application facade in the port implementation.

Utilities
``````````````

Common
    includes common implementations of domain layer objects, or value objects (types) used across all other blocks.

Database
    used to define Record Set pattern-based interfaces for accessing a relational database, and implementation for the SQLite database.

CommonTestSupport
    contains utility classes and functions handy in testing.

CommonImplementations
  contains common implementation layer classes used in the "... Implementations" blocks.
