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
            var moreJournal = true;
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
                            //TODO: account!.setOwner(uid);
                            account!.gid = gid
                            dbAccount.update(account!);
                        }
                        break;

                        /*
                         case LProtocol.JRQST_ADD_CATEGORY:
                         id = intent.getLongExtra("id", 0L);
                         gid = intent.getLongExtra("gid", 0L);

                         DBCategory dbCategory = DBCategory.getInstance();
                         LCategory category = dbCategory.getByGid(gid);
                         if (null != category) {
                         if (category.getId() != id) {
                         LLog.e("\(self)", "unexpected error, category GID: " + gid + " already taken " +
                         "by " + category.getName());
                         dbCategory.deleteById(category.getId());
                         }
                         }
                         dbCategory.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid);
                         break;
                         case LProtocol.JRQST_ADD_TAG:
                         id = intent.getLongExtra("id", 0L);
                         gid = intent.getLongExtra("gid", 0L);

                         DBTag dbTag = DBTag.getInstance();
                         LTag tag = dbTag.getByGid(gid);
                         if (null != tag) {
                         if (tag.getId() != id) {
                         LLog.e("\(self)", "unexpected error, tag GID: " + gid + " already taken " +
                         "by " + tag.getName());
                         dbTag.deleteById(tag.getId());
                         }
                         }
                         dbTag.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid);
                         break;
                         case LProtocol.JRQST_ADD_VENDOR:
                         id = intent.getLongExtra("id", 0L);
                         gid = intent.getLongExtra("gid", 0L);

                         DBVendor dbVendor = DBVendor.getInstance();
                         LVendor vendor = dbVendor.getByGid(gid);
                         if (null != vendor) {
                         if (vendor.getId() != id) {
                         LLog.e("\(self)", "unexpected error, vendor GID: " + gid + " already taken " +
                         "by " + vendor.getName());
                         dbVendor.deleteById(vendor.getId());
                         }
                         }
                         dbVendor.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid);
                         break;
                         case LProtocol.JRQST_ADD_RECORD:
                         DBTransaction dbTransaction = DBTransaction.getInstance();
                         id = intent.getLongExtra("id", 0L);
                         gid = intent.getLongExtra("gid", 0L);

                         LTransaction transaction = dbTransaction.getByGid(gid);
                         if (null != transaction) {
                         if (transaction.getId() == id) {
                         LLog.e("\(self)", "unexpected error, record GID: " + gid + " already taken ");
                         }
                         dbTransaction.deleteById(transaction.getId());
                         }
                         dbTransaction.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid);
                         break;
                         case LProtocol.JRQST_ADD_SCHEDULE:
                         DBScheduledTransaction dbSchTransaction = DBScheduledTransaction.getInstance();
                         id = intent.getLongExtra("id", 0L);
                         gid = intent.getLongExtra("gid", 0L);

                         LScheduledTransaction scheduledTransaction = dbSchTransaction.getByGid(gid);
                         if (null != scheduledTransaction) {
                         if (scheduledTransaction.getId() == id) {
                         LLog.e("\(self)", "unexpected error, schedule GID: " + gid + " already taken ");
                         }
                         dbSchTransaction.deleteById(scheduledTransaction.getId());
                         }
                         dbSchTransaction.updateColumnById(id, DBHelper.TABLE_COLUMN_GID, gid);
                         break;
                         case LProtocol.JRQST_GET_ACCOUNTS:
                         gid = intent.getLongExtra("gid", 0L);
                         uid = intent.getLongExtra("uid", 0L);
                         String name = intent.getStringExtra("name");

                         dbAccount = DBAccount.getInstance();
                         account = dbAccount.getByGid(gid);
                         if (null != account) {
                         account.setOwner(uid);
                         account.setName(name);
                         dbAccount.update(account);
                         } else {
                         account = new LAccount();
                         account.setOwner(uid);
                         account.setGid(gid);
                         account.setName(name);
                         dbAccount.add(account);
                         }
                         journal.getAccountUsers(gid);
                         break;
                         case LProtocol.JRQST_GET_ACCOUNT_USERS:
                         gid = intent.getLongExtra("aid", 0L);
                         dbAccount = DBAccount.getInstance();
                         account = dbAccount.getByGid(gid);
                         if (null != account) {
                         account.setSharedIdsString(intent.getStringExtra("users"));
                         dbAccount.update(account);
                         } else {
                         LLog.w("\(self)", "account: " + gid + " no longer exists");
                         }
                         break;

                         case LProtocol.JRQST_GET_CATEGORIES:
                         gid = intent.getLongExtra("gid", 0L);
                         name = intent.getStringExtra("name");
                         dbCategory = DBCategory.getInstance();
                         category = dbCategory.getByGid(gid);
                         if (null != category) {
                         category.setName(name);
                         dbCategory.update(category);
                         } else {
                         category = new LCategory();
                         category.setGid(gid);
                         category.setName(name);
                         dbCategory.add(category);
                         }
                         break;
                         case LProtocol.JRQST_GET_TAGS:
                         gid = intent.getLongExtra("gid", 0L);
                         name = intent.getStringExtra("name");
                         dbTag = DBTag.getInstance();
                         tag = dbTag.getByGid(gid);
                         if (null != tag) {
                         tag.setName(name);
                         dbTag.update(tag);
                         } else {
                         tag = new LTag();
                         tag.setGid(gid);
                         tag.setName(name);
                         dbTag.add(tag);
                         }
                         break;
                         case LProtocol.JRQST_GET_VENDORS:
                         gid = intent.getLongExtra("gid", 0L);
                         int type = intent.getIntExtra("type", LVendor.TYPE_PAYEE);
                         name = intent.getStringExtra("name");
                         dbVendor = DBVendor.getInstance();
                         vendor = dbVendor.getByGid(gid);
                         if (null != vendor) {
                         vendor.setName(name);
                         vendor.setType(type);
                         dbVendor.update(vendor);
                         } else {
                         vendor = new LVendor();
                         vendor.setGid(gid);
                         vendor.setName(name);
                         vendor.setType(type);
                         dbVendor.add(vendor);
                         }
                         break;
                         case LProtocol.JRQST_GET_RECORD:
                         case LProtocol.JRQST_GET_RECORDS:
                         case LProtocol.JRQST_GET_ACCOUNT_RECORDS:
                         gid = intent.getLongExtra("gid", 0L);
                         long aid = intent.getLongExtra("aid", 0);
                         long aid2 = intent.getLongExtra("aid2", 0);
                         long cid = intent.getLongExtra("cid", 0);
                         long tid = intent.getLongExtra("tid", 0);
                         long vid = intent.getLongExtra("vid", 0);
                         type = intent.getByteExtra("type", (byte) LTransaction.TRANSACTION_TYPE_EXPENSE);
                         double amount = intent.getDoubleExtra("amount", 0);
                         long rid = intent.getLongExtra("recordId", 0L);
                         long timestamp = intent.getLongExtra("timestamp", 0L);
                         long createUid = intent.getLongExtra("createBy", 0);
                         long changeUid = intent.getLongExtra("changeBy", 0);
                         long createTime = intent.getLongExtra("createTime", 0L);
                         long changeTime = intent.getLongExtra("changeTime", 0L);
                         String note = intent.getStringExtra("note");
                         dbTransaction = DBTransaction.getInstance();
                         transaction = dbTransaction.getByGid(gid);
                         boolean create = true;
                         if (null != transaction) {
                         create = false;
                         } else {
                         if (type == LTransaction.TRANSACTION_TYPE_TRANSFER)
                         transaction = dbTransaction.getByRid(rid, false);
                         else if (type == LTransaction.TRANSACTION_TYPE_TRANSFER_COPY)
                         transaction = dbTransaction.getByRid(rid, true);
                         if (null != transaction) {
                         create = false;
                         } else
                         transaction = new LTransaction();
                         }
                         dbAccount = DBAccount.getInstance();
                         transaction.setGid(gid);
                         transaction.setAccount(dbAccount.getIdByGid(aid));
                         transaction.setAccount2(dbAccount.getIdByGid(aid2));
                         transaction.setCategory(DBCategory.getInstance().getIdByGid(cid));
                         transaction.setTag(DBTag.getInstance().getIdByGid(tid));
                         transaction.setVendor(DBVendor.getInstance().getIdByGid(vid));
                         transaction.setType(type);
                         transaction.setValue(amount);
                         transaction.setCreateBy(createUid);
                         transaction.setChangeBy(changeUid);
                         transaction.setRid(rid);
                         transaction.setTimeStamp(timestamp);
                         transaction.setTimeStampCreate(createTime);
                         transaction.setTimeStampLast(changeTime);
                         transaction.setNote(note);

                         if (create) dbTransaction.add(transaction);
                         else dbTransaction.update(transaction);

                         break;

                         case LProtocol.JRQST_GET_SCHEDULE:
                         case LProtocol.JRQST_GET_SCHEDULES:
                         case LProtocol.JRQST_GET_ACCOUNT_SCHEDULES:
                         gid = intent.getLongExtra("gid", 0L);
                         aid = intent.getLongExtra("aid", 0);
                         aid2 = intent.getLongExtra("aid2", 0);
                         cid = intent.getLongExtra("cid", 0);
                         tid = intent.getLongExtra("tid", 0);
                         vid = intent.getLongExtra("vid", 0);
                         type = intent.getByteExtra("type", (byte) LTransaction.TRANSACTION_TYPE_EXPENSE);
                         amount = intent.getDoubleExtra("amount", 0);
                         rid = intent.getLongExtra("recordId", 0L);
                         timestamp = intent.getLongExtra("timestamp", 0L);
                         createUid = intent.getLongExtra("createBy", 0);
                         changeUid = intent.getLongExtra("changeBy", 0);
                         createTime = intent.getLongExtra("createTime", 0L);
                         changeTime = intent.getLongExtra("changeTime", 0L);
                         note = intent.getStringExtra("note");

                         long nextTime = intent.getLongExtra("nextTime", 0L);
                         byte interval = intent.getByteExtra("interval", (byte) 0);
                         byte unit = intent.getByteExtra("unit", (byte) 0);
                         byte count = intent.getByteExtra("count", (byte) 0);
                         boolean enabled = intent.getByteExtra("count", (byte) 0) == 0 ? false : true;

                         dbSchTransaction = DBScheduledTransaction.getInstance();
                         scheduledTransaction = dbSchTransaction.getByGid(gid);

                         create = true;
                         if (null != scheduledTransaction) {
                         create = false;
                         } else {
                         scheduledTransaction = new LScheduledTransaction();
                         }
                         dbAccount = DBAccount.getInstance();
                         scheduledTransaction.setGid(gid);
                         scheduledTransaction.setAccount(dbAccount.getIdByGid(aid));
                         scheduledTransaction.setAccount2(dbAccount.getIdByGid(aid2));
                         scheduledTransaction.setCategory(DBCategory.getInstance().getIdByGid(cid));
                         scheduledTransaction.setTag(DBTag.getInstance().getIdByGid(tid));
                         scheduledTransaction.setVendor(DBVendor.getInstance().getIdByGid(vid));
                         scheduledTransaction.setType(type);
                         scheduledTransaction.setValue(amount);
                         scheduledTransaction.setCreateBy(createUid);
                         scheduledTransaction.setChangeBy(changeUid);
                         scheduledTransaction.setRid(rid);
                         scheduledTransaction.setTimeStamp(timestamp);
                         scheduledTransaction.setTimeStampCreate(createTime);
                         scheduledTransaction.setTimeStampLast(changeTime);
                         scheduledTransaction.setNote(note);

                         scheduledTransaction.setNextTime(nextTime);
                         scheduledTransaction.setRepeatInterval(interval);
                         scheduledTransaction.setRepeatUnit(unit);
                         scheduledTransaction.setRepeatCount(count);
                         scheduledTransaction.setEnabled(enabled);

                         if (create) dbSchTransaction.add(scheduledTransaction);
                         else dbSchTransaction.update(scheduledTransaction);

                         break;

                         case LProtocol.JRQST_UPDATE_ACCOUNT:
                         case LProtocol.JRQST_DELETE_ACCOUNT:
                         case LProtocol.JRQST_UPDATE_CATEGORY:
                         case LProtocol.JRQST_DELETE_CATEGORY:
                         case LProtocol.JRQST_UPDATE_TAG:
                         case LProtocol.JRQST_DELETE_TAG:
                         case LProtocol.JRQST_UPDATE_VENDOR:
                         case LProtocol.JRQST_DELETE_VENDOR:
                         case LProtocol.JRQST_UPDATE_RECORD:
                         case LProtocol.JRQST_DELETE_RECORD:
                         case LProtocol.JRQST_UPDATE_SCHEDULE:
                         case LProtocol.JRQST_DELETE_SCHEDULE:
                         case LProtocol.JRQST_CONFIRM_ACCOUNT_SHARE:
                         case LProtocol.JRQST_ADD_USER_TO_ACCOUNT:
                         break;
                         */
                    default:
                        LLog.w("\(self)", "unknown journal request: \(jrqstId)")
                    }
                }

                if (LProtocol.RSPS_OK == ret) {
                    DBJournal.instance.remove(id: journalId)
                    LLog.d("\(self)", "flushing journal upon completion ...");
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
                    moreJournal = false;
                } else {
                    journalPostErrorCount = 0;
                    LLog.e("\(self)", "fatal journal post error, journal skipped");
                    DBJournal.instance.remove(id: journalId)
                    moreJournal = LJournal.instance.flush()
                }
            }

            //no more active journal, start polling
            if (!moreJournal) {
                UiRequest.instance.UiPoll()
                //serviceHandler.postDelayed(pollRunnable, NETWORK_IDLE_POLLING_MS);
            }
        }
    }


    @objc func pushNotification(notification: Notification) {
        LLog.d("\(self)", "poll upon push notification");
        //reset polling count upon receiving push notification from server
        //we'll keep polling up to MAX_POLLING_COUNT_UPON_PUSH_NOTIFICATION times, till a positive
        //polling result from server: this is to handle the case where server sends the notification
        //but underlying database hasn't got a chance to flush.
        pollingCount = 0;

        if !LJournal.instance.flush() {
            UiRequest.instance.UiPoll()
        }
    }

    @objc func poll(notification: Notification) {
        if let bdata = notification.userInfo as? [String: Any] {
            if (LProtocol.RSPS_OK == (bdata["status"]) as! Int) {
                let id: Int64 = bdata["id"] as! Int64
                let nid: UInt16 = bdata["nid"] as! UInt16

                switch (nid) {
                case LService.NOTIFICATION_UPDATE_USER_PROFILE:
                    LPreferences.setUserName(bdata["txt1"] as! String)

                    LBroadcast.post(LBroadcast.ACTION_UPDATE_USER_PROFILE, sender: nil, data: bdata)

                    break
                default:
                    break
                }

                //pollingCount = MAX_POLLING_COUNT_UPON_PUSH_NOTIFICATION;
                UiRequest.instance.UiPollAck(id)

            } else {
                //no more
                LLog.d("\(self)", "flushing journal upon polling ends ...");
                if (!LJournal.instance.flush()) {
                    /*if (LFragmentActivity.upRunning) {
                     //server.UiUtcSync();
                     if (pollingCount++ < MAX_POLLING_COUNT_UPON_PUSH_NOTIFICATION) {
                     serviceHandler.postDelayed(pollRunnable, NETWORK_IDLE_POLLING_MS);
                     }

                     Intent uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
                     .ACTION_UI_NET_IDLE));
                     LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
                     } else {
                     LLog.d(TAG, "no activity visible, shutdown now");
                     serviceHandler.postDelayed(serviceShutdownRunnable,
                     SERVICE_SHUTDOWN_MS);
                     }*/
                }
            }
        }
            /*
             case NOTIFICATION_UPDATE_USER_PROFILE:
             LPreferences.setUserName(intent.getStringExtra("txt1"));
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_USER_PROFILE));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             break;
             */
            /*
             if (LProtocol.RSPS_OK == ret) {
             long id = intent.getLongExtra("id", 0);
             short nid = intent.getShortExtra("nid", (short) 0);
             switch (nid) {
             case NOTIFICATION_ADD_ACCOUNT:
             long gid = intent.getLongExtra("int1", 0L);
             long uid = intent.getLongExtra("int2", 0L);
             String name = intent.getStringExtra("txt1");

             DBAccount dbAccount = DBAccount.getInstance();
             LAccount account = dbAccount.getByGid(gid);
             if (null != account) {
             account.setOwner(uid);
             account.setName(name);
             dbAccount.update(account);
             } else {
             account = dbAccount.getByName(name);
             if (null != account) {
             account.setOwner(uid);
             account.setGid(gid);
             dbAccount.update(account);
             } else {
             account = new LAccount();
             account.setOwner(uid);
             account.setGid(gid);
             account.setName(name);
             dbAccount.add(account);
             }
             }
             Intent uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_ACCOUNT));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             break;

             case NOTIFICATION_UPDATE_ACCOUNT:
             gid = intent.getLongExtra("int1", 0L);
             name = intent.getStringExtra("txt1");

             dbAccount = DBAccount.getInstance();
             account = dbAccount.getByGid(gid);
             if (null != account) {
             account.setName(name);
             dbAccount.update(account);
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_ACCOUNT));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_DELETE_ACCOUNT:
             gid = intent.getLongExtra("int1", 0L);
             dbAccount = DBAccount.getInstance();
             account = dbAccount.getByGid(gid);
             if (null != account) {
             LTask.start(new DBAccount.MyAccountDeleteTask(), account.getId());
             dbAccount.deleteById(account.getId());
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_ACCOUNT));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_UPDATE_ACCOUNT_GID:
             gid = intent.getLongExtra("int1", 0L);
             long gid2 = intent.getLongExtra("int2", 0L);

             dbAccount = DBAccount.getInstance();
             account = dbAccount.getByGid(gid);
             if (null != account) {
             account.setGid(gid2);
             dbAccount.update(account);
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_ACCOUNT));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_ADD_CATEGORY:
             gid = intent.getLongExtra("int1", 0L);
             long pid = intent.getLongExtra("int2", 0L);
             name = intent.getStringExtra("txt1");
             DBCategory dbCategory = DBCategory.getInstance();
             LCategory category = dbCategory.getByGid(gid);
             if (null != category) {
             category.setName(name);
             //category.setPid(pid);
             dbCategory.update(category);
             } else {
             category = dbCategory.getByName(name);
             if (null != category) {
             category.setGid(gid);
             //category.setPid(pid);
             dbCategory.update(category);
             } else {
             category = new LCategory();
             category.setGid(gid);
             category.setName(name);
             dbCategory.add(category);
             }
             }
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_CATEGORY));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             break;

             case NOTIFICATION_UPDATE_CATEGORY:
             gid = intent.getLongExtra("int1", 0L);
             pid = intent.getLongExtra("int2", 0L);
             name = intent.getStringExtra("txt1");
             dbCategory = DBCategory.getInstance();
             category = dbCategory.getByGid(gid);
             if (null != category) {
             category.setName(name);
             //category.setPid(pid);
             dbCategory.update(category);

             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_CATEGORY));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_DELETE_CATEGORY:
             gid = intent.getLongExtra("int1", 0L);
             dbCategory = DBCategory.getInstance();
             category = dbCategory.getByGid(gid);
             if (null != category) {
             dbCategory.deleteById(category.getId());
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_CATEGORY));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_ADD_TAG:
             gid = intent.getLongExtra("int1", 0L);
             name = intent.getStringExtra("txt1");
             DBTag dbTag = DBTag.getInstance();
             LTag tag = dbTag.getByGid(gid);
             if (null != tag) {
             tag.setName(name);
             dbTag.update(tag);
             } else {
             tag = dbTag.getByName(name);
             if (null != tag) {
             tag.setGid(gid);
             dbTag.update(tag);
             } else {
             tag = new LTag();
             tag.setGid(gid);
             tag.setName(name);
             dbTag.add(tag);
             }
             }
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_TAG));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             break;

             case NOTIFICATION_UPDATE_TAG:
             gid = intent.getLongExtra("int1", 0L);
             name = intent.getStringExtra("txt1");
             dbTag = DBTag.getInstance();
             tag = dbTag.getByGid(gid);
             if (null != tag) {
             tag.setName(name);
             dbTag.update(tag);

             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_TAG));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_DELETE_TAG:
             gid = intent.getLongExtra("int1", 0L);
             dbTag = DBTag.getInstance();
             tag = dbTag.getByGid(gid);
             if (null != tag) {
             dbTag.deleteById(tag.getId());
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_TAG));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;
             case NOTIFICATION_ADD_VENDOR:
             gid = intent.getLongExtra("int1", 0L);
             long type = intent.getLongExtra("int2", 0L);
             name = intent.getStringExtra("txt1");
             DBVendor dbVendor = DBVendor.getInstance();
             LVendor vendor = dbVendor.getByGid(gid);
             if (null != vendor) {
             vendor.setName(name);
             vendor.setType((int) type);
             dbVendor.update(vendor);
             } else {
             vendor = dbVendor.getByName(name);
             if (null != vendor) {
             vendor.setGid(gid);
             dbVendor.update(vendor);
             } else {
             vendor = new LVendor();
             vendor.setGid(gid);
             vendor.setName(name);
             vendor.setType((int) type);
             dbVendor.add(vendor);
             }
             }
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_VENDOR));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             break;

             case NOTIFICATION_UPDATE_VENDOR:
             gid = intent.getLongExtra("int1", 0L);
             type = intent.getLongExtra("int2", 0L);
             name = intent.getStringExtra("txt1");
             dbVendor = DBVendor.getInstance();
             vendor = dbVendor.getByGid(gid);
             if (null != vendor) {
             vendor.setName(name);
             vendor.setType((int) type);
             dbVendor.update(vendor);
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_VENDOR));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_DELETE_VENDOR:
             gid = intent.getLongExtra("int1", 0L);
             dbVendor = DBVendor.getInstance();
             vendor = dbVendor.getByGid(gid);
             if (null != vendor) {
             dbVendor.deleteById(vendor.getId());
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_VENDOR));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_GET_RECORD:
             case NOTIFICATION_UPDATE_RECORD:
             gid = intent.getLongExtra("int1", 0L);
             journal.getRecord(gid);
             break;

             case NOTIFICATION_DELETE_RECORD:
             gid = intent.getLongExtra("int1", 0L);
             DBTransaction dbTransaction = DBTransaction.getInstance();
             LTransaction transaction = dbTransaction.getByGid(gid);
             if (null != transaction) {
             dbTransaction.deleteById(transaction.getId());
             }
             break;

             case NOTIFICATION_GET_RECORDS:
             byte[] blob = intent.getByteArrayExtra("blob");
             LBuffer data = new LBuffer(blob);
             long[] ids = new long[blob.length / Long.BYTES];
             for (int ii = 0; ii < ids.length; ii++) {
             ids[ii] = data.getLongAutoInc();
             }
             journal.getRecords(ids);
             break;

             case NOTIFICATION_ADD_SCHEDULE:
             case NOTIFICATION_UPDATE_SCHEDULE:
             gid = intent.getLongExtra("int1", 0L);
             journal.getSchedule(gid);
             break;

             case NOTIFICATION_DELETE_SCHEDULE:
             gid = intent.getLongExtra("int1", 0L);
             DBScheduledTransaction dbScheduledTransaction = DBScheduledTransaction.getInstance();
             LScheduledTransaction scheduledTransaction = dbScheduledTransaction.getByGid(gid);
             if (null != scheduledTransaction) {
             dbScheduledTransaction.deleteById(scheduledTransaction.getId());
             }
             break;

             case NOTIFICATION_UPDATE_USER_PROFILE:
             LPreferences.setUserName(intent.getStringExtra("txt1"));
             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_USER_PROFILE));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             break;

             case NOTIFICATION_ADD_SHARE_USER:
             uid = intent.getLongExtra("int1", 0L);
             LPreferences.setShareUserId(uid, intent.getStringExtra("txt1"));
             LPreferences.setShareUserName(uid, intent.getStringExtra("txt2"));
             break;

             case NOTIFICATION_REQUEST_ACCOUNT_SHARE:
             long aid = intent.getLongExtra("int1", 0L);
             uid = intent.getLongExtra("int2", 0L);

             long shareAccept = LPreferences.getShareAccept(uid);
             if (shareAccept != 0 && (shareAccept + 24 * 3600 * 1000 > System.currentTimeMillis())) {
             LJournal journal = new LJournal();
             journal.confirmAccountShare(aid, uid, true);
             } else {
             name = intent.getStringExtra("txt1");
             LAccountShareRequest shareRequest = new LAccountShareRequest(uid, LPreferences
             .getShareUserId(uid), LPreferences.getShareUserName(uid), name, aid);
             LPreferences.addAccountShareRequest(shareRequest);

             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_SHARE_ACCOUNT));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_DECLINE_ACCOUNT_SHARE:
             aid = intent.getLongExtra("int1", 0L);
             uid = intent.getLongExtra("int2", 0L);
             dbAccount = DBAccount.getInstance();
             account = dbAccount.getByGid(aid);
             if (null != account) {
             //only remove if share state is INVITED, in other words, do not
             //unshare a previously confirmed share here
             if (LAccount.ACCOUNT_SHARE_INVITED == account.getShareUserState(uid)) {
             account.removeShareUser(uid);
             dbAccount.update(account);

             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_ACCOUNT));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             }
             break;

             case NOTIFICATION_UPDATE_ACCOUNT_USER:
             aid = intent.getLongExtra("int1", 0L);
             dbAccount = DBAccount.getInstance();
             account = dbAccount.getByGid(aid);
             if (null != account) {
             account.setSharedIdsString(intent.getStringExtra("txt1"));
             dbAccount.update(account);

             uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_UPDATE_ACCOUNT));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             }
             break;

             case NOTIFICATION_GET_ACCOUNT_RECORDS:
             aid = intent.getLongExtra("int1", 0L);
             journal.getAccountRecords(aid);
             break;

             case NOTIFICATION_GET_ACCOUNT_SCHEDULES:
             aid = intent.getLongExtra("int1", 0L);
             journal.getAccountSchedules(aid);
             break;

             case NOTIFICATION_GET_ACCOUNTS:
             journal.getAllAccounts();
             break;

             case NOTIFICATION_GET_CATEGORIES:
             journal.getAllCategories();
             break;

             case NOTIFICATION_GET_VENDORS:
             journal.getAllVendors();
             break;

             case NOTIFICATION_GET_TAGS:
             journal.getAllTags();
             break;

             default:
             LLog.w(TAG, "unexpected notification id: " + nid);
             }
             pollingCount = MAX_POLLING_COUNT_UPON_PUSH_NOTIFICATION;
             server.UiPollAck(id);
             } else {
             //no more
             LLog.d(TAG, "flushing journal upon polling ends ...");
             if (!journal.flush()) {
             if (LFragmentActivity.upRunning) {
             //server.UiUtcSync();
             if (pollingCount++ < MAX_POLLING_COUNT_UPON_PUSH_NOTIFICATION) {
             serviceHandler.postDelayed(pollRunnable, NETWORK_IDLE_POLLING_MS);
             }

             Intent uiIntent = new Intent(LBroadcastReceiver.action(LBroadcastReceiver
             .ACTION_UI_NET_IDLE));
             LocalBroadcastManager.getInstance(LApp.ctx).sendBroadcast(uiIntent);
             } else {
             LLog.d(TAG, "no activity visible, shutdown now");
             serviceHandler.postDelayed(serviceShutdownRunnable,
             SERVICE_SHUTDOWN_MS);
             }
             }
             }
             break;

             */
        }

        @objc func pollAck(notification: Notification) {
            if (!LJournal.instance.flush()) {
                UiRequest.instance.UiPoll()
            }
        }

}
