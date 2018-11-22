=================
Coding Guidelines
=================

The most rules of coding style are verified during build steps with ``swiftlint`` rules.
Here we mention some rules that are not implemented in the tool.

Method arguments line breaks
----------------------------

Put all arguments on the same line, or put each on a separate line, breaking after comma.

Valid::

    self.imageView.frame = CGRect(x: frame.minX,
                                  y: frame.minY + IdenticonView.shadowOffset,
                                  width: frame.width,
                                  height: frame.height)

Invalid because the linebreak is after parenthesis::

    self.imageView.frame = CGRect(
        x: frame.minX,
        y: frame.minY + IdenticonView.shadowOffset,
        width: frame.width,
        height: frame.height)

Using extensions for code grouping and protocol implementations
---------------------------------------------------------------

If a type adopts a protocol, then it is a valid case for implementing protocol methods in an extension on that type.

Valid::

    final class MainFlowCoordinator: FlowCoordinator {
        ...
    }

    ...

    extension MainFlowCoordinator: TransactionsTableViewControllerDelegate {
    
        func didSelectTransaction(id: String) {
            let controller = TransactionDetailsViewController.create(transactionID: id)
            controller.delegate = self
            push(controller)
        }

    }

If a class inherits from another class that implements a protocol and overrides base class' implementation of the protocol methods, then we do not use extensions to separate overriden methods from the class body.

Valid::

    final class MenuTableViewController: UITableViewController { 
        ...

        // MARK: - Table view data source

        override func numberOfSections(in tableView: UITableView) -> Int {
            return menuItems.count
        }
        ...
    }

Invalid because override happens in the extension::

    final class MenuTableViewController: UITableViewController { 
        ...
    }
    
    extension MenuTableViewController {

        override func numberOfSections(in tableView: UITableView) -> Int {
            return menuItems.count
        }
        ...
    }

Naming Conventions
-------------------
Folders and groups MUST NOT contain whitespace symbols (because genstrings ignores paths with whitespaces).

Localization
-------------
We use ``NSLocalizedString`` function or custom ``LocalizedString`` function to wrap user-facing strings. You must provide meaningful comment with each string.

::

    LocalizedString("onboarding.start.header", "Header label for Start screen")

Never localize storyboards or xibs but put all localization keys in the source code.

Error handling
--------------

Errors are logged using LogService.shared logger. You can pass any ``Error`` implementation to it.

::

    LogService.shared.fatal("Oops! App will crash", error: MyError.error)
    LogService.shared.error("Something bad happened")
    LogService.shared.info("We reached some stage")
    LogService.shared.debug("Log debug values")

By default, we enable Crashlytics logger to record errors to crashlytics. Recommended approach is to create enum implementing ``LoggableError`` protocol. This will make enum cases available in the Crashlytics. 

::

    enum BiometricServiceError: LoggableError {
        case unexpectedBiometryType
    }

    LogService.shared.error("Received unexpected biometry type: none",
                                        error: BiometricServiceError.unexpectedBiometryType)

You can also provide underlying error::

    do {
        // something throws
    } catch let e {
        throw MyError.myCaseError.nsError(causedBy: e)
    }

Accessibility
-------------
Assign all accessibility values (including identifiers) in source code only, no storyboards or xibs should contain accessibility values.
