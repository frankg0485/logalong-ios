//
//  LUser.swift
//  LogAlong
//
//  Created by Frank Gao on 12/30/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LUser {
    var name: String
    var fullName: String
    var id: Int64

    init() {
        name = ""
        fullName = ""
        id = 0
    }

    init(_ name: String, _ fullName: String, _ id: Int64) {
        self.name = name
        self.fullName = fullName
        self.id = id
    }
}
