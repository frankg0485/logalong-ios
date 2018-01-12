//
//  LAccount.swift
//  LogAlong
//
//  Created by Frank Gao on 9/12/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

class LAccount : LDbBase {
    public let ACCOUNT_SHARE_PERMISSION_READ_ONLY   = 0x01
    public let ACCOUNT_SHARE_PERMISSION_READ_WRITE  = 0x03
    public let ACCOUNT_SHARE_PERMISSION_OWNER       = 0x08
    public let ACCOUNT_SHARE_INVITED = 0x10
    public let ACCOUNT_SHARE_NA = 0x20

    var share: String
    var showBalance: Bool
    var shareIds: [Int64]
    var shareStates: [Int]
    var shareTimeStampLast: Int64

    override init() {
        self.showBalance = true
        self.share = ""
        self.shareIds = []
        self.shareStates = []
        self.shareTimeStampLast = 0
        super.init()
    }

    init(id: Int64, gid: Int64, name: String, share: String, showBalance: Bool, create: Int64, access: Int64) {
        self.share = share
        self.showBalance = showBalance
        self.shareIds = []
        self.shareStates = []
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

    func getShareIdsString() -> String {
        if (shareIds.isEmpty == true || shareStates.isEmpty == true || shareIds.count < 1 || shareStates.count < 1) {
            return ""
        }

        var str: String = ""
        for ii in 0..<shareStates.count {
            str += String(shareStates[ii]) + ","
            str += String(shareIds[ii]) + ","
        }
        str += String(shareTimeStampLast)
        return str
    }

    func setSharedIdsString(_ str: String) {
        if (!str.isEmpty) {
            let sb: [String] = str.components(separatedBy: ",")
            shareIds.removeAll()
            shareStates.removeAll()

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
    }

    func getOwner() -> Int64 {
        if (shareIds == nil || shareStates == nil) {
            return 0
        }

        for ii in 0..<shareStates.count {
            if (shareStates[ii] == ACCOUNT_SHARE_PERMISSION_OWNER) {
                return shareIds[ii]
            }
        }
        return 0
    }

    func setOwner(_ id: Int64) {
        addShareUser(id, ACCOUNT_SHARE_PERMISSION_OWNER)
    }

    func addShareUser(_ id: Int64, _ state: Int) {
        if (shareIds == nil || shareStates == nil) {
            shareIds = [Int64]()
            shareStates = [Int]()
        }

        for ii in 0..<shareIds.count {
            if (shareIds[ii] == id) {
                shareStates[ii] = state
                return
            }
        }

        shareStates.append(state)
        shareIds.append(id)
    }


}
