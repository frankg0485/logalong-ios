//
//  LAccount.swift
//  LogAlong
//
//  Created by Frank Gao on 9/12/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

class LAccount : LDbBase {
    public static let ACCOUNT_SHARE_PERMISSION_READ_ONLY   = 0x01
    public static let ACCOUNT_SHARE_PERMISSION_READ_WRITE  = 0x03
    public static let ACCOUNT_SHARE_PERMISSION_OWNER       = 0x08
    public static let ACCOUNT_SHARE_INVITED = 0x10
    public static let ACCOUNT_SHARE_NA = 0x20

    var share: String
    var showBalance: Bool
    var shareTimeStampLast: Int64

    override init() {
        self.showBalance = true
        self.share = ""
        self.shareTimeStampLast = 0
        super.init()
    }

    init(id: Int64, gid: Int64, name: String, share: String, showBalance: Bool, create: Int64, access: Int64) {
        self.share = share
        self.showBalance = showBalance

        self.shareTimeStampLast = 0
        super.init(id: id, gid: gid, name: name, create: create, access: access)
    }

    convenience init(name: String, share: String, showBalance: Bool) {
        self.init()
        self.name = name
        self.share = share
        self.showBalance = showBalance
    }

    convenience init(id: Int64, name: String, share: String, showBalance: Bool) {
        self.init(name: name, share: share, showBalance: showBalance)
        self.id = id
    }

    convenience init(name: String) {
        self.init(id: 0, name: name, share: "", showBalance: true)
    }

    convenience init(id: Int64, name: String) {
        self.init(name: name)
        self.id = id
    }

    convenience init(id: Int64, gid: Int64, name: String) {
        self.init(id: id, name: name)
        self.gid = gid
    }

    func removeShareUser(_ id: Int64) {
        var shareIds: [Int64] = getShareIdsStates().shareIds
        var shareStates: [Int] = getShareIdsStates().shareStates

        if (shareIds.isEmpty || shareStates.isEmpty) {
            return
        }

        var iicpy = 0
        for _ in 0..<shareIds.count {
            if (shareIds[iicpy] == id) {
                shareIds.remove(at: iicpy)
                shareStates.remove(at: iicpy)
                iicpy -= 1
            }
            iicpy += 1
        }

        setShareIdsStates(shareIds: shareIds, shareStates: shareStates)
    }

    func getShareIdsStates() -> (shareIds: [Int64], shareStates: [Int]) {
        var shareIds = [Int64]()
        var shareStates = [Int]()

        if (!share.isEmpty) {
            let sb: [String] = share.components(separatedBy: ",")

            for ii in 0..<(sb.count / 2) {
                shareStates.append(Int(sb[2 * ii])!)
                shareIds.append(Int64(sb[2 * ii + 1])!)
            }

            if ((sb.count % 2) == 0) {
                shareTimeStampLast = 0
            } else {
                shareTimeStampLast = Int64(sb[sb.count - 1])!
            }
        }

        return (shareIds, shareStates)
    }

    func setShareIdsStates(shareIds: [Int64], shareStates: [Int]) {
        if (shareIds.isEmpty == true || shareStates.isEmpty == true || shareIds.count < 1 || shareStates.count < 1) {
            share = ""
            return
        }

        var str: String = ""
        for ii in 0..<shareStates.count {
            str += String(shareStates[ii]) + ","
            str += String(shareIds[ii]) + ","
        }
        str += String(shareTimeStampLast)
        share = str
    }

    func getOwner() -> Int64 {
        let shareIds: [Int64] = getShareIdsStates().shareIds
        let shareStates: [Int] = getShareIdsStates().shareStates

        if (shareIds.isEmpty || shareStates.isEmpty) {
            return 0
        }

        for ii in 0..<shareStates.count {
            if (shareStates[ii] == LAccount.ACCOUNT_SHARE_PERMISSION_OWNER) {
                return shareIds[ii]
            }
        }
        return 0
    }

    func setOwner(_ id: Int64) {
        addShareUser(id, LAccount.ACCOUNT_SHARE_PERMISSION_OWNER)
    }

    func addShareUser(_ id: Int64, _ state: Int) {
        var shareIds: [Int64] = getShareIdsStates().shareIds
        var shareStates: [Int] = getShareIdsStates().shareStates

        for ii in 0..<shareIds.count {
            if (shareIds[ii] == id) {
                shareStates[ii] = state
                setShareIdsStates(shareIds: shareIds, shareStates: shareStates)
                return
            }
        }

        shareStates.append(state)
        shareIds.append(id)

        setShareIdsStates(shareIds: shareIds, shareStates: shareStates)
    }

    func getShareUserState(_ id: Int64) -> Int {
        let shareIds: [Int64] = getShareIdsStates().shareIds
        let shareStates: [Int] = getShareIdsStates().shareStates

        if (shareIds.isEmpty || shareStates.isEmpty) {
            return LAccount.ACCOUNT_SHARE_NA
        }
        for ii in 0..<shareIds.count {
            if (shareIds[ii] == id) {
                return shareStates[ii]
            }
        }
        return LAccount.ACCOUNT_SHARE_NA
    }

}
