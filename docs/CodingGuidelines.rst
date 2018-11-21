=================
Coding Guidelines
=================

The most rules of coding style are verified during build steps with `swiftlint` rules.
Here we mention some rules that are not implemented in the tool.

Method arguments line breaks
----------------------------

Put all arguments on the same line, or put each on a separate lines, breaking after comma.

Valid:

    self.imageView.frame = CGRect(x: frame.minX,
                                y: frame.minY + IdenticonView.shadowOffset,
                                width: frame.width,
                                height: frame.height)

Invalid because the linebreak is after parenthesis:

    self.imageView.frame = CGRect(
        x: frame.minX,
        y: frame.minY + IdenticonView.shadowOffset,
        width: frame.width,
        height: frame.height)

Using extensions for code grouping and protocol implementations
---------------------------------------------------------------

If a type adopts protocol, then it is a valid case for implementing protocol methods in an extension on that type.

Valid:

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



If a class inherits from another class that implements protocol, and then overrides protocol implementation methods, then we do not use extensions to separate overriden methods from the class body.

Valid:

    final class MenuTableViewController: UITableViewController { 
        ...

        // MARK: - Table view data source

        override func numberOfSections(in tableView: UITableView) -> Int {
            return menuItems.count
        }
        ...
    }

Invalid because override happens in the extension:

    final class MenuTableViewController: UITableViewController { 
        ...
    }

    extension MenuTableViewController {

        override func numberOfSections(in tableView: UITableView) -> Int {
            return menuItems.count
        }
        ...
    }
