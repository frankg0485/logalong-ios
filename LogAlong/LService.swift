//
//  LService.swift
//  LogAlong
//
//  Created by Michael Gao on 12/5/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation

class LService {
    static let instance = LService()
    var pollingCount = 0
    var journalPostErrorCount = 0

    private static let NOTIFICATION_UPDATE_USER_PROFILE: UInt16 = 0x001
    private static let NOTIFICATION_ADD_SHARE_USER: UInt16 = 0x002
    private static let NOTIFICATION_ADD_ACCOUNT: UInt16 = 0x010
    private static let NOTIFICATION_UPDATE_ACCOUNT: UInt16 = 0x011
    private static let NOTIFICATION_DELETE_ACCOUNT: UInt16 = 0x012
    private static let NOTIFICATION_UPDATE_ACCOUNT_GID: UInt16 = 0x013
    private static let NOTIFICATION_ADD_CATEGORY: UInt16 = 0x020
    private static let NOTIFICATION_UPDATE_CATEGORY: UInt16 = 0x021
    private static let NOTIFICATION_DELETE_CATEGORY: UInt16 = 0x022
    private static let NOTIFICATION_ADD_TAG: UInt16 = 0x030
    private static let NOTIFICATION_UPDATE_TAG: UInt16 = 0x031
    private static let NOTIFICATION_DELETE_TAG: UInt16 = 0x032
    private static let NOTIFICATION_ADD_VENDOR: UInt16 = 0x040
    private static let NOTIFICATION_UPDATE_VENDOR: UInt16 = 0x041
    private static let NOTIFICATION_DELETE_VENDOR: UInt16 = 0x042
    private static let NOTIFICATION_GET_RECORD: UInt16 = 0x050
    private static let NOTIFICATION_UPDATE_RECORD: UInt16 = 0x051
    private static let NOTIFICATION_DELETE_RECORD: UInt16 = 0x052
    private static let NOTIFICATION_GET_RECORDS: UInt16 = 0x053
    private static let NOTIFICATION_ADD_SCHEDULE: UInt16 = 0x060
    private static let NOTIFICATION_UPDATE_SCHEDULE: UInt16 = 0x061
    private static let NOTIFICATION_DELETE_SCHEDULE: UInt16 = 0x062
    private static let NOTIFICATION_REQUEST_ACCOUNT_SHARE: UInt16 = 0x101
    private static let NOTIFICATION_DECLINE_ACCOUNT_SHARE: UInt16 = 0x102
    private static let NOTIFICATION_UPDATE_ACCOUNT_USER: UInt16 = 0x103
    private static let NOTIFICATION_GET_ACCOUNT_RECORDS: UInt16 = 0x201
    private static let NOTIFICATION_GET_ACCOUNTS: UInt16 = 0x202
    private static let NOTIFICATION_GET_CATEGORIES: UInt16 = 0x203
    private static let NOTIFICATION_GET_VENDORS: UInt16 = 0x204
    private static let NOTIFICATION_GET_TAGS: UInt16 = 0x205
    private static let NOTIFICATION_GET_ACCOUNT_SCHEDULES: UInt16 = 0x211

    func start() {
        LBroadcast.register(LBroadcast.ACTION_LOG_IN, cb: #selector(self.login), listener: self)
        LBroadcast.register(LBroadcast.ACTION_NEW_JOURNAL_AVAILABLE, cb: #selector(self.newJournalAvailable), listener: self)
        LBroadcast.register(LBroadcast.ACTION_POST_JOURNAL, cb: #selector(self.postJournal), listener: self)
        LBroadcast.register(LBroadcast.ACTION_PUSH_NOTIFICATION, cb: #selector(self.pushNotification), listener: self)
        LBroadcast.register(LBroadcast.ACTION_POLL, cb: #selector(self.poll), listener: self)
        LBroadcast.register(LBroadcast.ACTION_POLL_ACK, cb: #selector(self.pollAck), listener: self)
    }

    func stop() {
        LBroadcast.unregister(LBroadcast.ACTION_LOG_IN, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_NEW_JOURNAL_AVAILABLE, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_PUSH_NOTIFICATION, listener: self)
    }

    @objc func login(notification: Notification) {
        LJournal.instance.flush()
    }

    @objc func newJournalAvailable(notification: Notification) {
        LJournal.instance.flush()
    }

    @objc func postJournal(notification: Notification) {
        if let bdata = notification.userInfo as? [String: Any] {
            var moreJournal = true
            let ret = bdata["status"] as! Int
            let journalId = bdata["journalId"] as! Int
            LLog.d("\(self)", "post journal: \(journalId) status: \(ret)")

            if (LProtocol.RSPS_OK == ret || LProtocol.RSPS_MORE == ret) {
                let jrqstId : UInt16 = bdata["jrqstId"] as! UInt16
                let jret : UInt16 = bdata["jret"] as! UInt16
                LLog.d("\(self)", "post journal rsps ok, rqstId: \(jrqstId) status: \(jret)")
                if (LProtocol.RSPS_OK != jret) {
                    LLog.w("\(self)", "journal request \(jrqstId) failed.")
                } else {
                    switch (jrqstId) {
                    case LProtocol.JRQST_ADD_ACCOUNT:
                        let id = bdata["id"] as! Int64
                        let gid = bdata["gid"] as! Int64
                        let uid = bdata["uid"] as! Int64

                        let dbAccount = DBAccount.instance
                        var account = dbAccount.get(gid: gid)
                        if (nil != account) {
                            if (account!.id != id) {
                                LLog.e("\(self)", "unexpected error, account GID: \(gid) already taken by \(account!.name)")
                                //this is an unrecoverable error, we'll delete the dangling account
                                dbAccount.remove(id: account!.id)
                            }
                        }

                        account = dbAccount.get(id: id)
                        if (nil != account) {
                            //TODO: account!.setOwner(uid)
                            account!.gid = gid
                            dbAccount.update(account!)
                        }

                    case LProtocol.JRQST_GET_ACCOUNTS:
                        let gid = bdata["gid"] as! Int64
                        let uid = bdata["uid"] as! Int64
                        let name = bdata["name"] as! String

                        if let account = DBAccount.instance.get(gid: gid) {
                            //account.setOwner(uid)
                            account.name = name
                            _ = DBAccount.instance.update(account)
                        } else {
                            var account = LAccount()
                            //account.setOwner(uid)
                            account.gid = gid
                            account.name = name
                            _ = DBAccount.instance.add(&account)
                        }
                        _ = LJournal.instance.getAccountUsers(gid)

                    case LProtocol.JRQST_GET_ACCOUNT_USERS:
                        let gid = bdata["aid"] as! Int64

                        let dbAccount = DBAccount.instance
                        if let account = dbAccount.get(gid: gid) {
                            //account.setSharedIdsString(intent.getStringExtra("users"))
                            _ = dbAccount.update(account)
                        } else {
                            LLog.w("\(self)", "account: \(gid) no longer exists")
                        }

                        /*
                         case LProtocol.JRQST_ADD_CATEGORY:
                         id = intent.getLongExtra("id", 0L)
                         gid = intent.getLongExtra("gid", 0L)

                         DBCategory dbCategory = DBCategory.getInstance()
                         LCategory category = dbCategory.getByGid(gid)
                         if (null != category) {
                         if (category.getId() != id) {
                         LLog.e("\(self)", "unexpected error, category GID: " + gid + " already taken " +
                         "by " + category.getName())
                         dbCategory.deleteById(category.getId())
                         }
                         }
                         dbCategory.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid)
                         break
                         case LProtocol.JRQST_ADD_TAG:
                         id = intent.getLongExtra("id", 0L)
                         gid = intent.getLongExtra("gid", 0L)

                         DBTag dbTag = DBTag.getInstance()
                         LTag tag = dbTag.getByGid(gid)
                         if (null != tag) {
                         if (tag.getId() != id) {
                         LLog.e("\(self)", "unexpected error, tag GID: " + gid + " already taken " +
                         "by " + tag.getName())
                         dbTag.deleteById(tag.getId())
                         }
                         }
                         dbTag.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid)
                         break
                         case LProtocol.JRQST_ADD_VENDOR:
                         id = intent.getLongExtra("id", 0L)
                         gid = intent.getLongExtra("gid", 0L)

                         DBVendor dbVendor = DBVendor.getInstance()
                         LVendor vendor = dbVendor.getByGid(gid)
                         if (null != vendor) {
                         if (vendor.getId() != id) {
                         LLog.e("\(self)", "unexpected error, vendor GID: " + gid + " already taken " +
                         "by " + vendor.getName())
                         dbVendor.deleteById(vendor.getId())
                         }
                         }
                         dbVendor.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid)
                         break
                         case LProtocol.JRQST_ADD_RECORD:
                         DBTransaction dbTransaction = DBTransaction.getInstance()
                         id = intent.getLongExtra("id", 0L)
                         gid = intent.getLongExtra("gid", 0L)

                         LTransaction transaction = dbTransaction.getByGid(gid)
                         if (null != transaction) {
                         if (transaction.getId() == id) {
                         LLog.e("\(self)", "unexpected error, record GID: " + gid + " already taken ")
                         }
                         dbTransaction.deleteById(transaction.getId())
                         }
                         dbTransaction.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid)
                         break
                         case LProtocol.JRQST_ADD_SCHEDULE:
                         DBScheduledTransaction dbSchTransaction = DBScheduledTransaction.getInstance()
                         id = intent.getLongExtra("id", 0L)
                         gid = intent.getLongExtra("gid", 0L)

                         LScheduledTransaction scheduledTransaction = dbSchTransaction.getByGid(gid)
                         if (null != scheduledTransaction) {
                         if (scheduledTransaction.getId() == id) {
                         LLog.e("\(self)", "unexpected error, schedule GID: " + gid + " already taken ")
                         }
                         dbSchTransaction.deleteById(scheduledTransaction.getId())
                         }
                         dbSchTransaction.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid)
                         break
                         */

                    case LProtocol.JRQST_GET_CATEGORIES:
                         let gid = bdata["gid"] as! Int64
                         let name = bdata["name"] as! String
                         let dbCategory = DBCategory.instance
                         var category = dbCategory.get(gid: gid)
                         if (nil != category) {
                            category!.name = name
                            _ = dbCategory.update(category!)
                         } else {
                            category = LCategory()
                            category!.gid = gid
                            category!.name = name
                            _ = dbCategory.add(&category!)
                         }

                    case LProtocol.JRQST_GET_TAGS:
                         let gid = bdata["gid"] as! Int64
                         let name = bdata["name"] as! String
                         let dbTag = DBTag.instance
                         var tag = dbTag.get(gid: gid)
                         if (nil != tag) {
                            tag!.name = name
                            _ = dbTag.update(tag!)
                         } else {
                            tag = LTag()
                            tag!.gid = gid
                            tag!.name = name
                            _ = dbTag.add(&tag!)
                         }

                    case LProtocol.JRQST_GET_VENDORS:
                         let gid = bdata["gid"] as! Int64
                         //let type = bdata["type"] as! Int
                         let name = bdata["name"] as! String
                         let dbVendor = DBVendor.instance
                         var vendor = dbVendor.get(gid: gid)
                         if (nil != vendor) {
                            vendor!.name = name
                            //vendor!.type = type
                            _ = dbVendor.update(vendor!)
                         } else {
                            vendor = LVendor()
                            vendor!.gid = gid
                            vendor!.name = name
                            //vendor!.type = type
                            _ = dbVendor.add(&vendor!)
                         }

                    case LProtocol.JRQST_GET_RECORD: fallthrough
                    case LProtocol.JRQST_GET_RECORDS: fallthrough
                    case LProtocol.JRQST_GET_ACCOUNT_RECORDS:
                        let gid = bdata["gid"] as! Int64
                        let aid = bdata["aid"] as! Int64
                        let aid2 = bdata["aid2"] as! Int64
                        let cid = bdata["cid"] as! Int64
                        let tid = bdata["tid"] as! Int64
                        let vid = bdata["vid"] as! Int64
                        let type = bdata["type"] as! UInt8 //LTransaction.TRANSACTION_TYPE_EXPENSE
                        let amount = bdata["amount"] as! Double
                        let rid = bdata["recordId"] as! Int64
                        let timestamp = bdata["timestamp"] as! Int64
                        //let createUid = bdata["createBy"] as! Int64
                        let changeUid = bdata["changeBy"] as! Int64
                        let createTime = bdata["createTime"] as! Int64
                        let changeTime = bdata["changeTime"] as! Int64
                        let note = bdata["note"] as! String
                        let dbTransaction = DBTransaction.instance
                        var transaction = dbTransaction.get(gid: gid)
                        var create = true
                         if (nil != transaction) {
                            create = false
                         } else {
                            if (type == TransactionType.TRANSFER.rawValue) {
                                transaction = dbTransaction.getTransfer(rid: rid, copy: false)
                            } else if (type == TransactionType.TRANSFER_COPY.rawValue) {
                                transaction = dbTransaction.getTransfer(rid: rid, copy: true)
                            }
                            if (nil != transaction) {
                                create = false
                            } else {
                                transaction = LTransaction()
                            }
                        }
                        let dbAccount = DBAccount.instance
                        transaction!.gid = gid
                        transaction!.accountId = dbAccount.getId(gid: aid)!
                        transaction!.accountId2 = dbAccount.getId(gid: aid2) ?? 0
                        transaction!.categoryId = DBCategory.instance.getId(gid: cid) ?? 0
                        transaction!.tagId = DBTag.instance.getId(gid: tid) ?? 0
                        transaction!.vendorId = DBVendor.instance.getId(gid: vid) ?? 0
                        transaction!.type = TransactionType(rawValue: type)!
                        transaction!.amount = amount
                        //transaction!.setCreateBy(createUid)
                        transaction!.by = changeUid
                        transaction!.rid = rid
                        transaction!.timestamp = timestamp
                        transaction!.timestampCreate = createTime
                        transaction!.timestampAccess = changeTime
                        transaction!.note = note

                        if (create) {
                            _ = dbTransaction.add(&transaction!)
                        } else {
                            _ = dbTransaction.update(transaction!)
                        }

                        /*
                         case LProtocol.JRQST_GET_SCHEDULE:
                         case LProtocol.JRQST_GET_SCHEDULES:
                         case LProtocol.JRQST_GET_ACCOUNT_SCHEDULES:
                         gid = intent.getLongExtra("gid", 0L)
                         aid = intent.getLongExtra("aid", 0)
                         aid2 = intent.getLongExtra("aid2", 0)
                         cid = intent.getLongExtra("cid", 0)
                         tid = intent.getLongExtra("tid", 0)
                         vid = intent.getLongExtra("vid", 0)
                         type = intent.getByteExtra("type", (byte) LTransaction.TRANSACTION_TYPE_EXPENSE)
                         amount = intent.getDoubleExtra("amount", 0)
                         rid = intent.getLongExtra("recordId", 0L)
                         timestamp = intent.getLongExtra("timestamp", 0L)
                         createUid = intent.getLongExtra("createBy", 0)
                         changeUid = intent.getLongExtra("changeBy", 0)
                         createTime = intent.getLongExtra("createTime", 0L)
                         changeTime = intent.getLongExtra("changeTime", 0L)
                         note = intent.getStringExtra("note")

                         long nextTime = intent.getLongExtra("nextTime", 0L)
                         byte interval = intent.getByteExtra("interval", (byte) 0)
                         byte unit = intent.getByteExtra("unit", (byte) 0)
                         byte count = intent.getByteExtra("count", (byte) 0)
                         boolean enabled = intent.getByteExtra("count", (byte) 0) == 0 ? false : true

                         dbSchTransaction = DBScheduledTransaction.getInstance()
                         scheduledTransaction = dbSchTransaction.getByGid(gid)

                         create = true
                         if (null != scheduledTransaction) {
                         create = false
                         } else {
                         scheduledTransaction = new LScheduledTransaction()
                         }
                         dbAccount = DBAccount.getInstance()
                         scheduledTransaction.setGid(gid)
                         scheduledTransaction.setAccount(dbAccount.getIdByGid(aid))
                         scheduledTransaction.setAccount2(dbAccount.getIdByGid(aid2))
                         scheduledTransaction.setCategory(DBCategory.getInstance().getIdByGid(cid))
                         scheduledTransaction.setTag(DBTag.getInstance().getIdByGid(tid))
                         scheduledTransaction.setVendor(DBVendor.getInstance().getIdByGid(vid))
                         scheduledTransaction.setType(type)
                         scheduledTransaction.setValue(amount)
                         scheduledTransaction.setCreateBy(createUid)
                         scheduledTransaction.setChangeBy(changeUid)
                         scheduledTransaction.setRid(rid)
                         scheduledTransaction.setTimeStamp(timestamp)
                         scheduledTransaction.setTimeStampCreate(createTime)
                         scheduledTransaction.setTimeStampLast(changeTime)
                         scheduledTransaction.setNote(note)

                         scheduledTransaction.setNextTime(nextTime)
                         scheduledTransaction.setRepeatInterval(interval)
                         scheduledTransaction.setRepeatUnit(unit)
                         scheduledTransaction.setRepeatCount(count)
                         scheduledTransaction.setEnabled(enabled)

                         if (create) dbSchTransaction.add(scheduledTransaction)
                         else dbSchTransaction.update(scheduledTransaction)

                         break
                         */
                    case LProtocol.JRQST_UPDATE_ACCOUNT: break
                    case LProtocol.JRQST_DELETE_ACCOUNT: break
                    case LProtocol.JRQST_UPDATE_CATEGORY: break
                    case LProtocol.JRQST_DELETE_CATEGORY: break
                    case LProtocol.JRQST_UPDATE_TAG: break
                    case LProtocol.JRQST_DELETE_TAG: break
                    case LProtocol.JRQST_UPDATE_VENDOR: break
                    case LProtocol.JRQST_DELETE_VENDOR: break
                    case LProtocol.JRQST_UPDATE_RECORD: break
                    case LProtocol.JRQST_DELETE_RECORD: break
                    case LProtocol.JRQST_UPDATE_SCHEDULE: break
                    case LProtocol.JRQST_DELETE_SCHEDULE: break
                    case LProtocol.JRQST_CONFIRM_ACCOUNT_SHARE: break
                    case LProtocol.JRQST_ADD_USER_TO_ACCOUNT: break
                    default:
                        LLog.w("\(self)", "unknown journal request: \(jrqstId)")
                    }
                }

                if (LProtocol.RSPS_OK == ret) {
                    DBJournal.instance.remove(id: journalId)
                    LLog.d("\(self)", "flushing journal upon completion ...")
                    moreJournal = LJournal.instance.flush()
                }
            } else {
                // try a few more times, then bail, so not to lock out polling altogether

                if (journalPostErrorCount < 3) {
                    journalPostErrorCount += 1
                    LLog.w("\(self)", "unexpected journal post error: \(ret)")
                    //retry happens when one of the following happens
                    // - new journal request
                    // - polling timer expired
                    moreJournal = false
                } else {
                    journalPostErrorCount = 0
                    LLog.e("\(self)", "fatal journal post error, journal skipped")
                    DBJournal.instance.remove(id: journalId)
                    moreJournal = LJournal.instance.flush()
                }
            }

            //no more active journal, start polling
            if (!moreJournal) {
                _ = UiRequest.instance.UiPoll()
                //serviceHandler.postDelayed(pollRunnable, NETWORK_IDLE_POLLING_MS)
            }
        }
    }


    @objc func pushNotification(notification: Notification) {
        LLog.d("\(self)", "poll upon push notification")
        //reset polling count upon receiving push notification from server
        //we'll keep polling up to MAX_POLLING_COUNT_UPON_PUSH_NOTIFICATION times, till a positive
        //polling result from server: this is to handle the case where server sends the notification
        //but underlying database hasn't got a chance to flush.
        pollingCount = 0

        if !LJournal.instance.flush() {
            _ = UiRequest.instance.UiPoll()
        }
    }

    @objc func poll(notification: Notification) {
        if let bdata = notification.userInfo as? [String: Any] {
            if (LProtocol.RSPS_OK == (bdata["status"]) as! Int) {
                let id: Int64 = bdata["id"] as! Int64
                let nid: UInt16 = bdata["nid"] as! UInt16

                switch (nid) {
                case LService.NOTIFICATION_ADD_ACCOUNT:
                    let gid = bdata["int1"] as! Int64
                    let uid = bdata["int2"] as! Int64
                    let name = bdata["txt1"] as! String

                    let dbAccount = DBAccount.instance
                    if let account = dbAccount.get(gid: gid) {
                        //TODO
                        //account.setOwner(uid)
                        account.name = name
                        _ = dbAccount.update(account)
                    } else {
                        if let account = dbAccount.get(name: name) {
                            //TODO: account.setOwner(uid)
                            account.gid = gid
                            _ = dbAccount.update(account)
                        } else {
                            var account = LAccount()
                            //TODO: account.setOwner(uid)
                            account.gid = gid
                            account.name = name
                            _ = dbAccount.add(&account)
                        }
                    }
                    LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_ACCOUNT, sender: nil, data: bdata)

                case LService.NOTIFICATION_UPDATE_ACCOUNT:
                    let gid = bdata["int1"] as! Int64
                    let name = bdata["txt1"] as! String

                    let dbAccount = DBAccount.instance
                    if let account = dbAccount.get(gid: gid) {
                        account.name = name
                        _ = dbAccount.update(account)
                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_ACCOUNT, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_DELETE_ACCOUNT:
                    let gid = bdata["int1"] as! Int64
                    let dbAccount = DBAccount.instance
                    if let account = dbAccount.get(gid: gid) {
                        //TODO: LTask.start(new DBAccount.MyAccountDeleteTask(), account.getId())
                        _ = dbAccount.remove(id: account.id)
                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_ACCOUNT, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_UPDATE_ACCOUNT_GID:
                    let gid = bdata["int1"] as! Int64
                    let gid2 = bdata["int2"] as! Int64

                    let dbAccount = DBAccount.instance
                    if let account = dbAccount.get(gid: gid) {
                        account.gid = gid2
                        _ = dbAccount.update(account)
                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_ACCOUNT, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_ADD_CATEGORY:
                    let gid = bdata["int1"] as! Int64
                    //let pid = bdata["int2"] as! Int64
                    let name = bdata["txt1"] as! String
                    let dbCategory = DBCategory.instance
                    if let category = dbCategory.get(gid: gid) {
                        category.name = name
                        //category.pid = pid
                        _ = dbCategory.update(category)
                    } else {
                        if let category = dbCategory.get(name: name) {
                            category.gid = gid
                            //category.pid = pid
                            _ = dbCategory.update(category)
                        } else {
                            var category = LCategory()
                            category.gid = gid
                            category.name = name
                            _ = dbCategory.add(&category)
                        }
                    }
                    LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_CATEGORY, sender: nil, data: bdata)

                case LService.NOTIFICATION_UPDATE_CATEGORY:
                    let gid = bdata["int1"] as! Int64
                    //let pid = bdata["int2"] as! Int64
                    let name = bdata["txt1"] as! String
                    let dbCategory = DBCategory.instance
                    if let category = dbCategory.get(gid: gid) {
                        category.name = name
                        //category.pid = pid
                        _ = dbCategory.update(category)
                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_CATEGORY, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_DELETE_CATEGORY:
                    let gid = bdata["int1"] as! Int64
                    let dbCategory = DBCategory.instance
                    if let category = dbCategory.get(gid: gid) {
                        _ = dbCategory.remove(id: category.id)
                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_CATEGORY, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_ADD_TAG:
                    let gid = bdata["int1"] as! Int64
                    let name = bdata["txt1"] as! String
                    let dbTag = DBTag.instance
                    if let tag = dbTag.get(gid: gid) {
                        tag.name = name
                        _ = dbTag.update(tag)
                    } else {
                        if let tag = dbTag.get(name: name) {
                            tag.gid = gid
                            _ = dbTag.update(tag)
                        } else {
                            var tag = LTag()
                            tag.gid = gid
                            tag.name = name
                            _ = dbTag.add(&tag)
                        }
                    }
                    LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_TAG, sender: nil, data: bdata)

                case LService.NOTIFICATION_UPDATE_TAG:
                    let gid = bdata["int1"] as! Int64
                    let name = bdata["txt1"] as! String
                    let dbTag = DBTag.instance
                    if let tag = dbTag.get(gid: gid) {
                        tag.name = name
                        _ = dbTag.update(tag)
                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_TAG, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_DELETE_TAG:
                    let gid = bdata["int1"] as! Int64
                    let dbTag = DBTag.instance
                    if let tag = dbTag.get(gid: gid) {
                        _ = dbTag.remove(id: tag.id)
                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_TAG, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_ADD_VENDOR:
                    let gid = bdata["int1"] as! Int64
                    let type = bdata["int2"] as! Int64
                    let name = bdata["txt1"] as! String
                    let dbVendor = DBVendor.instance
                    if let vendor = dbVendor.get(gid: gid) {
                        vendor.name = name
                        vendor.type = VendorType(rawValue: UInt8(type))!
                        _ = dbVendor.update(vendor)
                    } else {
                        if let vendor = dbVendor.get(name: name) {
                            vendor.gid = gid
                            _ = dbVendor.update(vendor)
                        } else {
                            var vendor = LVendor()
                            vendor.gid = gid
                            vendor.name = name
                            vendor.type = VendorType(rawValue: UInt8(type))!
                            _ = dbVendor.add(&vendor)
                        }
                    }
                    LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_VENDOR, sender: nil, data: bdata)

                case LService.NOTIFICATION_UPDATE_VENDOR:
                    let gid = bdata["int1"] as! Int64
                    let type = bdata["int2"] as! Int64
                    let name = bdata["txt1"] as! String
                    let dbVendor = DBVendor.instance
                    if let vendor = dbVendor.get(gid: gid) {
                        vendor.name = name
                        vendor.type = VendorType(rawValue: UInt8(type))!
                        _ = dbVendor.update(vendor)
                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_VENDOR, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_DELETE_VENDOR:
                    let gid = bdata["int1"] as! Int64
                    let dbVendor = DBVendor.instance
                    if let vendor = dbVendor.get(gid: gid) {
                        _ = dbVendor.remove(id: vendor.id)
                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_VENDOR, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_GET_RECORD: fallthrough
                case LService.NOTIFICATION_UPDATE_RECORD:
                    let gid = bdata["int1"] as! Int64
                    _ = LJournal.instance.getRecord(gid)

                case LService.NOTIFICATION_DELETE_RECORD:
                    let gid = bdata["int1"] as! Int64
                    let dbTransaction = DBTransaction.instance
                    if let transaction = dbTransaction.get(gid: gid) {
                        _ = dbTransaction.remove(id: transaction.id)
                    }

                case LService.NOTIFICATION_GET_RECORDS:
                    let blob = bdata["blob"] as! [UInt8]
                    let data = LBuffer(buf: blob)
                    var ids = [Int64](repeating: 0, count: blob.count / 8)
                    for ii in 0..<ids.count {
                        ids[ii] = data.getLongAutoInc()
                    }
                    _ = LJournal.instance.getRecords(ids)

                    /*
                case NOTIFICATION_ADD_SCHEDULE:
                case NOTIFICATION_UPDATE_SCHEDULE:
                    gid = intent.getLongExtra("int1", 0L)
                    journal.getSchedule(gid)
                    break

                case NOTIFICATION_DELETE_SCHEDULE:
                    gid = intent.getLongExtra("int1", 0L)
                    DBScheduledTransaction dbScheduledTransaction = DBScheduledTransaction.getInstance()
                    LScheduledTransaction scheduledTransaction = dbScheduledTransaction.getByGid(gid)
                    if (null != scheduledTransaction) {
                        dbScheduledTransaction.deleteById(scheduledTransaction.getId())
                    }
                    break
                     */

                case LService.NOTIFICATION_UPDATE_USER_PROFILE:
                    LPreferences.setUserName(bdata["txt1"] as! String)
                    LBroadcast.post(LBroadcast.ACTION_UPDATE_USER_PROFILE, sender: nil, data: bdata)
                    break

                case LService.NOTIFICATION_ADD_SHARE_USER:
                    let uid = bdata["int1"] as! Int64
                    LPreferences.setShareUserId(uid, bdata["txt1"] as! String)
                    LPreferences.setShareUserName(uid, bdata["txt2"] as! String)

                case LService.NOTIFICATION_REQUEST_ACCOUNT_SHARE:
                    let aid = bdata["int1"] as! Int64
                    let uid = bdata["int2"] as! Int64
                    //TODO:
/*                    let shareAccept = LPreferences.getShareAccept(uid)
                    if ((shareAccept != 0) && (shareAccept + 24 * 3600 * 1000 > NSDate().timeIntervalSince1970 * 1000)) {
                        LJournal.instance.confirmAccountShare(aid, uid, true)
                    } else {
                        name = bdata["txt1"]
                        LAccountShareRequest shareRequest = new LAccountShareRequest(uid, LPreferences
                            .getShareUserId(uid), LPreferences.getShareUserName(uid), name, aid)
                        LPreferences.addAccountShareRequest(shareRequest)
                     }
 */
                        LBroadcast.post(LBroadcast.ACTION_UI_SHARE_ACCOUNT, sender: nil, data: bdata)

                case LService.NOTIFICATION_DECLINE_ACCOUNT_SHARE:
                    let aid = bdata["int1"] as! Int64
                    let uid = bdata["int2"] as! Int64
                    let dbAccount = DBAccount.instance

                    if let account = dbAccount.get(gid: aid) {
                        //only remove if share state is INVITED, in other words, do not
                        //unshare a previously confirmed share here
                        if (LAccount.ACCOUNT_SHARE_INVITED == account.getShareUserState(uid)) {
                            account.removeShareUser(uid)
                            dbAccount.update(account)
                           LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_ACCOUNT, sender: nil, data: bdata)
                        }

                    }

                case LService.NOTIFICATION_UPDATE_ACCOUNT_USER:
                    let aid = bdata["int1"] as! Int64
                    let dbAccount = DBAccount.instance
                    let account = dbAccount.get(gid: aid)
                    if (nil != account) {
                        account!.share = bdata["txt1"] as! String
                        _ = dbAccount.update(account!)

                        LBroadcast.post(LBroadcast.ACTION_UI_UPDATE_ACCOUNT, sender: nil, data: bdata)
                    }

                case LService.NOTIFICATION_GET_ACCOUNT_RECORDS:
                    let aid = bdata["int1"] as! Int64
                    _ = LJournal.instance.getAccountRecords(aid)

                case LService.NOTIFICATION_GET_ACCOUNT_SCHEDULES:
                    let aid = bdata["int1"] as! Int64
                    _ = LJournal.instance.getAccountSchedules(aid)

                case LService.NOTIFICATION_GET_ACCOUNTS:
                    _ = LJournal.instance.getAllAccounts()

                case LService.NOTIFICATION_GET_CATEGORIES:
                    _ = LJournal.instance.getAllCategories()

                case LService.NOTIFICATION_GET_VENDORS:
                    _ = LJournal.instance.getAllVendors()

                case LService.NOTIFICATION_GET_TAGS:
                    _ = LJournal.instance.getAllTags()

                default:
                    break
                }

                //pollingCount = MAX_POLLING_COUNT_UPON_PUSH_NOTIFICATION
                _ = UiRequest.instance.UiPollAck(id)

            } else {
                //no more
                LLog.d("\(self)", "flushing journal upon polling ends ...")
                if (!LJournal.instance.flush()) {
                    /*if (LFragmentActivity.upRunning) {
                     //server.UiUtcSync()
                     if (pollingCount++ < MAX_POLLING_COUNT_UPON_PUSH_NOTIFICATION) {
                     serviceHandler.postDelayed(pollRunnable, NETWORK_IDLE_POLLING_MS)
                     }

                     Intent uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
                     .ACTION_UI_NET_IDLE))
                     LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent)
                     } else {
                     LLog.d(TAG, "no activity visible, shutdown now")
                     serviceHandler.postDelayed(serviceShutdownRunnable,
                     SERVICE_SHUTDOWN_MS)
                     }*/
                }
            }
        }
    }

    @objc func pollAck(notification: Notification) {
        if (!LJournal.instance.flush()) {
            _ = UiRequest.instance.UiPoll()
        }
    }
}
