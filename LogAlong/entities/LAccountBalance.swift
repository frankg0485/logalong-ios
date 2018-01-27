//
//  LAccountBalance.swift
//  LogAlong
//
//  Created by Michael Gao on 1/26/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

class LAccountBalance {
    var accountId: Int64
    var balances: [Int: [Double]]

    init(accountId: Int64) {
        self.accountId = accountId
        self.balances = [:]
    }

    func setYearBalance(year: Int, balance: String) {
        let ayb = LAccountYearBalance(id: 0, accountId: accountId, year: year, balance: balance)
        balances.removeValue(forKey: year)
        balances[year] = ayb.getBalanceValues()
    }

    func getYearBalance(year: Int) -> String {
        if let balance = balances[year] {
            let ayb = LAccountYearBalance(id: 0, accountId: accountId, year: year, balance: "")
            ayb.setBalanceValues(balance)
            return ayb.balance
        } else {
            return ""
        }
    }

    func modify(year: Int, month: Int, amount: Double) {
        balances[year]![month] += amount
    }

    func getYearBalanceAccumulated(year: Int) -> [Double] {
        var values = [Double](repeating: 0, count: 12)
        var value: Double = 0

        for y in balances.keys {
            if let bal = balances[y] {
                if (y < year) {
                    for ii in 0..<bal.count {
                        value += bal[ii]
                    }
                } else if (y == year) {
                    for ii in 0..<bal.count {
                        values[ii] = bal[ii]
                    }
                }
            }
        }

        var vOfNow:Double = 0
        for ii in 0..<values.count {
            vOfNow += values[ii];
            values[ii] = value + vOfNow;
        }

        return values
    }

    func getLatestBalance() -> Double {
        var value: Double = 0
        for year in balances.keys {
            if let bal = balances[year] {
                for ii in 0..<bal.count {
                    value += bal[ii]
                }
            }
        }
        return value
    }
}
