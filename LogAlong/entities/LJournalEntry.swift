//
//  LJournalEntry.swift
//  LogAlong
//
//  Created by Michael Gao on 12/2/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//
import Foundation

struct LJournalEntry {

    var journalId: Int = 0
    var data: [UInt8]

    init(journalId: Int, data: [UInt8]) {
        self.journalId = journalId
        self.data = data
    }

    init(journalId: Int, datap: UnsafeMutablePointer<UInt8>, bytes: Int) {
        self.journalId = journalId
        self.data = [UInt8](repeating: 0, count: bytes);
        memcpy(UnsafeMutableRawPointer(mutating: self.data), datap, bytes)
    }
}
