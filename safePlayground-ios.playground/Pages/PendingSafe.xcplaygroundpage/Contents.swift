//: [Previous](@previous)

import Foundation
import UIKit
import PlaygroundSupport
import SafeAppUI
import MultisigWalletApplication

let walletService = MockWalletApplicationService()
ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)

let controller = PendingSafeViewController.create()

PlaygroundPage.current.liveView = controller

var totalDelay: TimeInterval = 0
func delayed(for time: TimeInterval = 2, block: @escaping () throws -> Void) {
    totalDelay += time
    DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
        do {
            try block()
        } catch let error {
            print("Error: \(error)")
        }
    }
}

delayed {
    try walletService.createNewDraftWallet()
    walletService.startDeployment()
}
delayed {
    walletService.assignBlockchainAddress("0x57b2573E5FA7c7C9B5Fa82F3F03A75F53A0efdF5")
}
delayed {
    walletService.updateMinimumFunding(account: "ETH", amount: 500)
}
delayed {
    walletService.update(account: "ETH", newBalance: 300)
}
delayed {
    walletService.update(account: "ETH", newBalance: 600)
}
delayed {
    walletService.markDeploymentAcceptedByBlockchain()
}
delayed {
    walletService.markDeploymentSuccess()
}

//: [Next](@next)
