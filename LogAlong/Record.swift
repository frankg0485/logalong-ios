//
//  Record.swift
//  LogAlong
//
//  Created by Frank Gao on 3/11/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit

class Record {
    
    var category: String?
    var amount: Int
    var account: String
    var payee: String?
    var notes: String?
    
    
    
    init?(category: String?, amount: Int, account: String, payee: String?, notes: String?) {
        
        guard !account.isEmpty else {
            return nil
        }
        
        self.category = category ?? ""
        self.amount = amount
        self.account = account
        self.payee = payee ?? ""
        self.notes = notes ?? ""
        
        
    }
}
