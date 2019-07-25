//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

final class QRCodeViewController: UIViewController {

    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var qrCodeView: QRCodeView!

    override func viewDidLoad() {
        super.viewDidLoad()
        qrCodeView.padding = 5
        qrCodeView.value = "Gnosis Safe"
        qrCodeView.layer.borderWidth = 1
        qrCodeView.layer.borderColor = ColorName.black.color.cgColor
        qrCodeView.layer.cornerRadius = 4
        input.delegate = self
    }

}

extension QRCodeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.nonNilText as NSString)
            .replacingCharacters(in: range, with: string)
        qrCodeView.value = updatedText
        return true
    }
}

fileprivate extension UITextField {

    var nonNilText: String {
        return text ?? ""
    }

}
