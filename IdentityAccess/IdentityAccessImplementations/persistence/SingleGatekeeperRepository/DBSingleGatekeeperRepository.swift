//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel
import Common
import Database
import CommonImplementations

/// Database storage for the gatekeeper entity.
public class DBSingleGatekeeperRepository: DBEntityRepository<Gatekeeper, GatekeeperID>, SingleGatekeeperRepository {

    public func gatekeeper() -> Gatekeeper? {
        return findFirst()
    }

    public func nextId() -> GatekeeperID {
        return nextID()
    }

    public override var table: TableSchema {
        return .init("tbl_gatekeeper",
                     "gatekeeper_id TEXT NOT NULL PRIMARY KEY",
                     "session_id TEXT",
                     "session_duration DOUBLE",
                     "session_started_at TEXT",
                     "session_ended_at TEXT",
                     "session_updated_at TEXT",
                     "policy_session_duration DOUBLE NOT NULL",
                     "policy_max_failed_attempts INTEGER NOT NULL",
                     "policy_block_duration DOUBLE NOT NULL",
                     "failed_attempt_count INTEGER NOT NULL",
                     "access_denied_at TEXT")
    }

    public override func insertionBindings(_ object: Gatekeeper) -> [SQLBindable?] {
        return [object.id.serializedValue,
        object.session?.id.serializedValue,
        object.session?.duration,
        object.session?.startedAt?.serializedValue,
        object.session?.endedAt?.serializedValue,
        object.session?.updatedAt?.serializedValue,
        object.policy.sessionDuration,
        object.policy.maxFailedAttempts,
        object.policy.blockDuration,
        object.failedAttemptCount,
        object.accessDeniedAt?.serializedValue]
    }

    public override func objectFromResultSet(_ rs: ResultSet) throws -> Gatekeeper? {
        guard let id: String = rs["gatekeeper_id"],
            let policySessionDuration: TimeInterval = rs["policy_session_duration"],
            let policyMaxFailedAttempts: Int = rs["policy_max_failed_attempts"],
            let policyBlockDuration: TimeInterval = rs["policy_block_duration"],
            let failedAttemptCount: Int = rs["failed_attempt_count"] else { return nil }
        var session: Session?
        if let sessionId: String = rs["session_id"],
            let sessionDuration: TimeInterval = rs["session_duration"] {
            session = try Session(id: SessionID(sessionId),
                                  duration: sessionDuration,
                                  startedAt: Date(serializedValue: rs["session_started_at"]),
                                  endedAt: Date(serializedValue: rs["session_ended_at"]),
                                  updatedAt: Date(serializedValue: rs["session_updated_at"]))
        }
        let policy = try AuthenticationPolicy(sessionDuration: policySessionDuration,
                                              maxFailedAttempts: policyMaxFailedAttempts,
                                              blockDuration: policyBlockDuration)
        let gatekeeper = Gatekeeper(id: GatekeeperID(id),
                                    session: session,
                                    policy: policy,
                                    failedAttemptCount: failedAttemptCount,
                                    accessDeniedAt: Date(serializedValue: rs["access_denied_at"]))
        return gatekeeper
    }

}
