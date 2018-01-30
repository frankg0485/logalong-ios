//
//  LAccountShareRequest.swift
//  LogAlong
//
//  Created by Frank Gao on 1/24/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import Foundation

class LAccountShareRequest {
    var userId: Int64
    var userName: String
    var userFullName: String
    var accountName: String
    var accountGid: Int64

    init(userId: Int64, userName: String, userFullName: String, accountName: String, accountGid: Int64) {
        self.userId = userId
        self.userName = userName
        self.userFullName = userFullName
        self.accountName = accountName
        self.accountGid = accountGid
    }
}
