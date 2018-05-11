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

class LAccountBalances {
    var balances = [LAccountBalance]()
    var accounts = [LAccount]()
    var total: Double = 0

    func scan(all: Bool = true) {
        accounts.removeAll()
        balances.removeAll()
        total = 0
        for account in DBAccount.instance.getAll() {
            if (!all && !account.showBalance) {
                continue
            }
            if let ayb = DBAccountBalance.instance.get(accountId: account.id) {
                let ab = LAccountBalance(accountId: account.id)
                for b in ayb {
                    ab.setYearBalance(year: b.year, balance: b.balance)
                }

                balances.append(ab)
                accounts.append(account)
                total += ab.getLatestBalance()
            }
        }
    }

    func getBalance(year: Int, month: Int) -> Double {
        var val: Double = 0
        for b in balances {
            let yba = b.getYearBalanceAccumulated(year: year)
            val += yba[month]
        }
        return val
    }

    func getBalance(accountId: Int64, year: Int, month: Int) -> Double {
        var val: Double = 0

        for b in balances {
            if b.accountId == accountId {
                let yba = b.getYearBalanceAccumulated(year: year)
                val = yba[month]
            }
        }
        return val
    }

    func getBalance() -> Double {
        return total
    }

    func getBalance(accountIds: [Int64], year: Int, month: Int) -> Double {
        var val: Double  = 0
        for aid in accountIds {
            val += getBalance(accountId: aid, year: year, month: month)
        }
        return val
    }
}
