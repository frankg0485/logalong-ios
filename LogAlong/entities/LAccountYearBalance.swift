//
//  LAccountYearBalance.swift
//  LogAlong
//
//  Created by Michael Gao on 1/26/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

class LAccountYearBalance : LDbBase {
    var accountId: Int64
    var year: Int
    var balance: String

    override init() {
        self.accountId = 0
        self.year = 0
        self.balance = ""
        super.init()
    }

    init (id: Int64, accountId: Int64, year: Int, balance: String) {
        self.accountId = accountId
        self.year = year
        self.balance = balance
        super.init()
        self.id = id
    }

    func setBalanceValues(_ balances: [Double]) {
        balance = "";

        for ii in 0..<balances.count - 1 {
            balance += String(balances[ii]) + ",";
        }
        balance += String(balances[balances.count - 1]);
    }

    func getBalanceValues() -> [Double] {
        var values = [Double](repeating: 0, count: 12)
        if (!balance.isEmpty) {
            let sb: [String] = balance.components(separatedBy: ",")

            for ii in 0..<sb.count {
                values[ii] = Double(sb[ii]) ?? 0
            }
        }
        return values
    }
}
