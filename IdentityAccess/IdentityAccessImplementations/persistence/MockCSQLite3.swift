//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessImplementations

class MockCSQLite3: CSQLite3 {

    var openedFilename: String?
    override var SQLITE_VERSION: String { return version }
    override var SQLITE_VERSION_NUMBER: Int32 { return number }
    override var SQLITE_SOURCE_ID: String { return sourceID }
    var version: String = ""
    var number: Int32 = 0
    var sourceID: String = ""


    var libversion_result: String = ""
    var sourceid_result: String = ""
    var libversion_number_result: Int32 = 0

    var open_result: Int32 = 0
    var open_pointer_result: OpaquePointer?
    override func sqlite3_open(_ filename: UnsafePointer<Int8>!,
                               _ ppDb: UnsafeMutablePointer<OpaquePointer?>!) -> Int32 {
        if let fn = filename {
            openedFilename = String(cString: fn, encoding: .utf8)
        }
        ppDb.pointee = open_pointer_result
        return open_result
    }

    override func sqlite3_libversion_number() -> Int32 {
        return libversion_number_result
    }

    override func sqlite3_libversion() -> UnsafePointer<Int8>! {
        return libversion_result.withCString { ptr -> UnsafePointer<Int8> in ptr }

    }

    override func sqlite3_sourceid() -> UnsafePointer<Int8>! {
        return sourceid_result.withCString { ptr -> UnsafePointer<Int8> in ptr }
    }

    var close_pointer: OpaquePointer?
    var close_result: Int32 = 0
    override func sqlite3_close(_ db: OpaquePointer!) -> Int32 {
        close_pointer = db
        return close_result
    }

    var prepare_in_db: OpaquePointer?
    var prepare_in_zSql: UnsafePointer<Int8>?
    var prepare_in_nByte: Int32?
    var prepare_result: Int32 = 0
    var prepare_out_ppStmt: OpaquePointer?
    var prepare_out_pzTail: UnsafePointer<Int8>?
    override func sqlite3_prepare_v2(_ db: OpaquePointer!,
                                     _ zSql: UnsafePointer<Int8>!,
                                     _ nByte: Int32,
                                     _ ppStmt: UnsafeMutablePointer<OpaquePointer?>!,
                                     _ pzTail: UnsafeMutablePointer<UnsafePointer<Int8>?>!) -> Int32 {
        prepare_in_db = db
        prepare_in_zSql = zSql
        prepare_in_nByte = nByte
        ppStmt.pointee = prepare_out_ppStmt
        pzTail.pointee = prepare_out_pzTail
        return prepare_result
    }
}
