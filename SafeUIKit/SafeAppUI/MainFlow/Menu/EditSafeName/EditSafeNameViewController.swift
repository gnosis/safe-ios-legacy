//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class EditSafeNameViewController: UIViewController {

    let verifiableInput = VerifiableInput()
    var saveButton: UIBarButtonItem!
    let maxCharsCount = 120

    enum Strings {
        static let title = LocalizedString("edit_safe_name", comment: "Edit Safe name")
        static let tooShort = LocalizedString("name_cannot_be_blank", comment: "The name can not be empty")
        static let tooLong = LocalizedString("name_too_long", comment: "The name is too long. Max 120 characters.")
        static let save = LocalizedString("save", comment: "Save")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title
        view.backgroundColor = .white
        saveButton = UIBarButtonItem(title: Strings.save, style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveButton
        configureVerifiableInput()
    }

    private func configureVerifiableInput() {
        verifiableInput.text = "Safe"
        verifiableInput.delegate = self
        verifiableInput.showErrorsOnly = true
        verifiableInput.maxLength = 120
        verifiableInput.validateEmptyText = true
        verifiableInput.addRule(Strings.tooShort) { !$0.isEmpty }
        verifiableInput.addRule(Strings.tooLong) { [unowned self] in
            $0.count <= self.maxCharsCount
        }
        verifiableInput.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verifiableInput)
        NSLayoutConstraint.activate([
            verifiableInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            verifiableInput.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            verifiableInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func save() {
        navigationController?.popViewController(animated: true)
    }

}

extension EditSafeNameViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        save()
    }

    func verifiableInputWillEnter(_ verifiableInput: VerifiableInput, newValue: String) {
        saveButton.isEnabled = !newValue.isEmpty && newValue.count <= maxCharsCount
    }

}
