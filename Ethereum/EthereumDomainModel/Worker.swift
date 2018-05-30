//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class Worker: Assertable {

    enum Error: String, LocalizedError, Hashable {
        case invalidRepatingTimeInterval
    }

    private let block: (Worker) -> Void
    private let interval: TimeInterval
    private var timer: Timer?

    private static var workers = [Worker]()

    private static var syncQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    public static func start(repeating interval: TimeInterval, block: @escaping (Worker) -> Void) throws {
        let worker = try Worker(repeating: interval, block: block)
        add(worker: worker)
        worker.start()
    }

    private static func add(worker: Worker) {
        syncQueue.addOperation {
            self.workers.append(worker)
        }
    }

    private static func remove(worker: Worker) {
        syncQueue.addOperation {
            if let index = self.workers.index(where: { $0 === worker }) {
                self.workers.remove(at: index)
            }
        }
    }

    public init(repeating interval: TimeInterval, block: @escaping (Worker) -> Void) throws {
        self.interval = interval
        self.block = block
        try assertTrue(interval > 0, Error.invalidRepatingTimeInterval)
    }

    public func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let `self` = self else { return }
            self.block(self)
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        Worker.remove(worker: self)
    }

}
