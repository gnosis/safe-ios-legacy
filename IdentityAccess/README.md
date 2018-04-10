# IdentityAccess module

IdentityAccess module consists of 3 main pieces:

  * Domain Model - models of Identity and Access domain. Declares Dependency Interfaces - protocols for external (to domain model) services.
  * Application - application services implementing application-related use case
  * Implementations - concrete implementations and mocks of Dependency Interfaces declared in Domain Model

In addition, there are test targets for each of the modules above and one fake app target for Integration testing.

The dependency graph of static library targets is the following:

    IdentityAccessDomainModel -> Common
    IdentityAccessImplementations -> IdentityAccessDomainModel, CommonTestSupport, 
                                    static external frameworks: Crashlytics, Fabric, 
                                    dynamic external frameworks: EthereumKit, APIKit, CryptoSwift, Result
    IdentityAccessApplication -> Common, IdentityAccessDomainModel
    
All of the test targets depend on IdentityAccessImplementations target because they use mix of  real implementations and mocks, where needed.
IdentityAccessImplementations target depends on several dynamic frameworks, therefore these frameworks are not embedded into
the target but must be provided with the executable. That means, wherever the IdentityAccessImplementations is used either in the 
app or in a test target, that app or test target must embed those dynamic frameworks. Hence, the test targets also depend on the same
dynamic frameworks.

    Assume that DEPS means [IdentityAccessImplementations, Crashlytics, Fabric, EthereumKit, APIKit, CryptoSwift, Result]
    IdentityAccessImplementationTests -> DEPS
    IdentityAccessDomainModelTests -> CommonTestSupport, IdentityAccessDomainModel, DEPS
    IdentityAccessApplicationTests -> CommonTestSupport, IdentityAccessApplication, DEPS
    IdentityAccessIntegrationTests -> IdentityAccessIntegration, DEPS
