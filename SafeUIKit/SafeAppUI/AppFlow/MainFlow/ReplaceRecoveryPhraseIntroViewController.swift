//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import MultisigWalletApplication
import SafeUIKit

public class ReplaceRecoveryPhraseIntroViewController: UIViewController {

    var state: State.StateType {
        get {
            return currentState.state
        }
        set {
            currentState = .create(newValue, vc: self)
        }
    }
    private var currentState: State!

    var transaction: TransactionData?

    @IBOutlet var retryButtonItem: UIBarButtonItem!
    @IBOutlet var cancelButtonItem: UIBarButtonItem!
    @IBOutlet var startButtonItem: UIBarButtonItem!
    var activityButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var transactionFeeView: TransactionFeeView!
    var activityIndicator = UIActivityIndicatorView(style: .gray)

    var statusText: String?

    public static func create() -> ReplaceRecoveryPhraseIntroViewController {
        return StoryboardScene.Main.replaceRecoveryPhraseIntroViewController.instantiate()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    func enter(state: State.StateType) {
        self.state = state
        currentState.enter()
    }

    func commonInit() {
        startButtonItem.title = Strings.start
        activityButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.leftBarButtonItems = [cancelButtonItem]
        navigationItem.rightBarButtonItems = [startButtonItem]
        state = .initial
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        currentState.enter()
    }

    @IBAction func cancel(_ sender: Any) {

    }

    @IBAction func start(_ sender: Any) {

    }

    @IBAction func retry(_ sender: Any) {
    }

}

extension ReplaceRecoveryPhraseIntroViewController {

    enum Strings {

        static let cancel = LocalizedString("cancel", comment: "Cancel")
        static let start = LocalizedString("replace_phrase.start", comment: "Start")

    }

    class State {

        enum StateType {
            case initial
            case loading
        }

        var state: StateType { preconditionFailure("Not implemented") }
        unowned var vc: ReplaceRecoveryPhraseIntroViewController

        static func create(_ type: StateType, vc: ReplaceRecoveryPhraseIntroViewController) -> State {
            switch type {
            case .initial: return InitialState(vc: vc)
            case .loading: return LoadingState(vc: vc)
            }
        }

        init(vc: ReplaceRecoveryPhraseIntroViewController) {
            self.vc = vc
        }

        func enter() {
            // empty
        }

    }

    class InitialState: State {

        enum Strings {
            static let status = LocalizedString("replace_recovery.intro.initial.status", comment: "Initial status text")
        }

        override var state: ReplaceRecoveryPhraseIntroViewController.State.StateType { return .initial }

        private func updateUI() {
            vc.cancelButtonItem.isEnabled = false
            vc.startButtonItem.isEnabled = false
            vc.statusText = Strings.status
        }

        override func enter() {
            updateUI()
            dispatch.async(.global) {
                guard self.vc.transaction == nil else { return }
                self.vc.transaction = ApplicationServiceRegistry.settingsService.createRecoveryPhraseTransaction()
            }.then(.main) {
                self.vc.enter(state: .loading)
            }
        }

    }

    class LoadingState: State {

        enum Strings {
            static let status = LocalizedString("replace_recovery.intro.loading.status", comment: "Loading status text")
        }

        override var state: ReplaceRecoveryPhraseIntroViewController.State.StateType { return .loading }

        private func updateUI() {
            vc.cancelButtonItem.isEnabled = true
            vc.startButtonItem.isEnabled = false
            vc.activityIndicator.startAnimating()
            vc.statusText = Strings.status
        }

        override func enter() {
            updateUI()
        }
    }

}

