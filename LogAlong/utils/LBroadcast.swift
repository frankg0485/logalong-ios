//
//  LBroadcast.swift
//  LogAlong
//
//  Created by Michael Gao on 11/18/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import Foundation
class LBroadcast {
    static let TAG = "LBroadcast";
    //public static final String EXTRA_RET_CODE = "ret";
    static let ACTION_BASE = "com.swoag.logalong.action.";
    //public static final int ACTION_USER_CREATED = 4;
    //public static final int ACTION_CONNECTED_TO_SERVER = 10;
    //public static final int ACTION_REQUESTED_TO_SHARE_ACCOUNT_WITH = 40;

    static let ACTION_NETWORK_CONNECTED = 50;
    static let ACTION_NETWORK_DISCONNECTED = 51;
    static let ACTION_GET_USER_BY_NAME = 52;
    static let ACTION_CREATE_USER = 54;
    static let ACTION_SIGN_IN = 56;
    static let ACTION_LOG_IN = 58;
    /*public static final int ACTION_UPDATE_USER_PROFILE = 60;
     public static final int ACTION_POST_JOURNAL = 62;
     public static final int ACTION_POLL = 63;
     public static final int ACTION_POLL_ACK = 64;
*/
     static let ACTION_NEW_JOURNAL_AVAILABLE = 300;
/*
     public static final int ACTION_UI_UPDATE_USER_PROFILE = 500;
     public static final int ACTION_UI_UPDATE_ACCOUNT = 501;
     public static final int ACTION_UI_UPDATE_CATEGORY = 502;
     public static final int ACTION_UI_UPDATE_TAG = 503;
     public static final int ACTION_UI_UPDATE_VENDOR = 504;
     public static final int ACTION_UI_SHARE_ACCOUNT = 505;
     public static final int ACTION_UI_NET_IDLE = 510;
     public static final int ACTION_UI_NET_BUSY = 512;
     public static final int ACTION_UI_RESET_PASSWORD = 515;

     public static final int ACTION_REQUESTED_TO_SET_ACCOUNT_GID = 100;
     public static final int ACTION_REQUESTED_TO_UPDATE_ACCOUNT_SHARE = 101;
     public static final int ACTION_REQUESTED_TO_UPDATE_ACCOUNT_INFO = 102;
     public static final int ACTION_REQUESTED_TO_UPDATE_SHARE_USER_PROFILE = 103;
     public static final int ACTION_REQUESTED_TO_SHARE_TRANSITION_RECORD = 113;
     public static final int ACTION_REQUESTED_TO_SHARE_TRANSITION_RECORDS = 114;
     public static final int ACTION_REQUESTED_TO_SHARE_TRANSITION_CATEGORY = 115;
     public static final int ACTION_REQUESTED_TO_SHARE_TRANSITION_PAYER = 116;
     public static final int ACTION_REQUESTED_TO_SHARE_TRANSITION_TAG = 117;
     public static final int ACTION_REQUESTED_TO_SHARE_PAYER_CATEGORY = 118;
     public static final int ACTION_REQUESTED_TO_SHARE_SCHEDULE = 119;

     public static final int ACTION_SERVER_BROADCAST_MSG_RECEIVED = 1000;
     public static final int ACTION_UNKNOWN_MSG = 9999;

     private static LBroadcastReceiver instance;
     */
    static func action(_ id: Int) -> Notification.Name {
        return Notification.Name(rawValue: ACTION_BASE + "\(id)");
    }

    static func post(_ id: Int, sender: Any? = nil, data: [AnyHashable : Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: action(id), object: sender, userInfo: data);
        }
    }

    static func register(_ id: Int, cb: Selector, listener: Any) {
        NotificationCenter.default.addObserver(listener, selector: cb, name: action(id), object: nil)
    }

    static func unregister(_ id: Int, listener: Any) {
        NotificationCenter.default.removeObserver(listener, name: action(id), object: nil)
    }
    /*
     public static LBroadcastReceiver getInstance() {
     if (instance == null) {
     instance = new LBroadcastReceiver();
     }
     return instance;
     }

     public interface BroadcastReceiverListener {
     public void onBroadcastReceiverReceive(int action, int ret, Intent intent);
     }

     private LBroadcastReceiver() {
     }

     private class MyBroadcastReceiver extends BroadcastReceiver {
     private BroadcastReceiverListener listener;

     private MyBroadcastReceiver(BroadcastReceiverListener listener) {
     this.listener = listener;
     }

     @Override
     public void onReceive(Context context, Intent intent) {
     try {
     String str = intent.getAction();
     String ss[] = str.split("\\.");
     int action = Integer.parseInt(ss[ss.length - 1]);
     int ret = intent.getIntExtra(EXTRA_RET_CODE, (int) 0);
     listener.onBroadcastReceiverReceive(action, ret, intent);
     } catch (Exception e) {
     LLog.e(TAG, "unexpected error, broadcast receiver failed: " + e.getMessage());
     }
     }
     }

     public BroadcastReceiver register(int action, BroadcastReceiverListener listener) {
     BroadcastReceiver broadcastReceiver = new MyBroadcastReceiver(listener);

     IntentFilter intentFilter = new IntentFilter();
     intentFilter.addAction(ACTION_BASE + action);
     LocalBroadcastManager.getInstance(LApp.ctx).registerReceiver(broadcastReceiver, intentFilter);
     return broadcastReceiver;
     }

     public BroadcastReceiver register(int[] actions, BroadcastReceiverListener listener) {
     BroadcastReceiver broadcastReceiver = new MyBroadcastReceiver(listener);

     IntentFilter intentFilter = new IntentFilter();
     for (int act : actions) {
     intentFilter.addAction(ACTION_BASE + act);
     }
     LocalBroadcastManager.getInstance(LApp.ctx).registerReceiver(broadcastReceiver, intentFilter);
     return broadcastReceiver;
     }

     public void unregister(BroadcastReceiver receiver) {
     LocalBroadcastManager.getInstance(LApp.ctx).unregisterReceiver(receiver);
     }*/
}
