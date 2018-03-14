# Naming Conventions
1. When naming protocols, use `..Protocol` suffix (unless it's a delegate protocol).
2. Folders and groups MUST NOT contain whitespace symbols.

# Localization
We use standard `NSLocalizedString` function to wrap user-facing strings. You must provide meaningful comment with each string.

    NSLocalizedString("onboarding.start.header", comment: "Header label for Start screen")

Never localize storyboards or xibs but put all localization keys in the source code.

# Error handling
Errors are logged using LogService.shared logger. You can pass any `Error` implementation to it.

    LogService.shared.fatal("Oops! App will crash", error: MyError.error)
    LogService.shared.error("Something bad happened")
    LogService.shared.info("We reached some stage")
    LogService.shared.debug("Log debug values")

By default, we enable Crashlytics logger to record errors to crashlytics. Recommended approach is to create enum implementing `LoggableError` protocol. This will make enum cases available in the Crashlytics. 

    enum BiometricServiceError: LoggableError {
        case unexpectedBiometryType
    }

    LogService.shared.error("Received unexpected biometry type: none",
                                        error: BiometricServiceError.unexpectedBiometryType)

You can also provide underlying error:

    do {
        // something throws
    } catch let e {
        throw MyError.myCaseError.nsError(causedBy: e)
    }

# Accessibility
Assign all accessibility values (including identifiers) in source code only, no storyboards or xibs should contain accessibility values.
