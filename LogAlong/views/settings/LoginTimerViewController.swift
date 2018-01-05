//
//  LoginTimerViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/17/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

enum typeOfLogin: Int {
    case CREATE = 0
    case LOGIN = 1
}

class LoginTimerViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var timer: Timer?
    var counter: Double = 15.0

    //TODO: caller must make sure name/userId/password are valid: for example no leading/trailing
    //      spaces are allowed for password/userId/name, no spaces are allowed for userId, all with
    //      length restrictions etc
    var name: String? = ""
    var userId: String = ""
    var password: String = ""
    var loginType: Int = 0

    private var serverIsDown = true
    var reloadLoginScreen = false

    var delegate: FNotifyReloadLoginScreenDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.isHidden = true

        activityIndicator.startAnimating()

        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(LoginTimerViewController.updateCountDown), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.

        LBroadcast.register(LBroadcast.ACTION_CREATE_USER, cb: #selector(self.createUser), listener: self)
        LBroadcast.register(LBroadcast.ACTION_SIGN_IN, cb: #selector(self.signin), listener: self)
        LBroadcast.register(LBroadcast.ACTION_LOG_IN, cb: #selector(self.login), listener: self)

        if typeOfLogin.LOGIN.rawValue == loginType {
            UiRequest.instance.UiSignIn(userId, password)
        } else if LPreferences.getUserId().isEmpty {
            UiRequest.instance.UiCreateUser(userId, password, fullname: name!)
        } else {
            LLog.e("\(self)", "unexpected state, requested to recreate user");
        }
    }

    @objc func createUser(notification: Notification) -> Void {
        var success = false

        serverIsDown = false

        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    LPreferences.setUserId(userId)
                    LPreferences.setUserPassword(password)
                    LPreferences.setUserName(name!)

                    UiRequest.instance.UiLogIn(userId, password)
                    //TODO: push local database

                    success = true;
                }
            }
        }

        if success {
            LLog.d("\(self)", "user created")
            connectingLabel.text = NSLocalizedString("Login Successful", comment: "")
            reloadLoginScreen = true
        } else {
            LLog.d("\(self)", "failed to create user")
            connectingLabel.text = NSLocalizedString("Unable to connect to server. Please try again later.", comment: "")

        }
        stopCountDown()
    }

    @objc func signin(notification: Notification) -> Void {
        var success = false

        serverIsDown = false

        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    LPreferences.setUserId(userId)
                    LPreferences.setUserPassword(password)
                    if let name = bdata["userName"] as? String {
                        LPreferences.setUserName(name)
                    }

                    UiRequest.instance.UiLogIn(userId, password)
                    success = true;
                }
            }
        }

        if success {
            LLog.d("\(self)", "user signed in")
            connectingLabel.text = NSLocalizedString("Login Successful", comment: "")
            reloadLoginScreen = true
        } else {
            LLog.d("\(self)", "user failed to sign in")
            connectingLabel.text = NSLocalizedString("Unable to connect to server. Please try again later.", comment: "")
        }

        stopCountDown()
    }

    @objc func login(notification: Notification) -> Void {
        var success = false

        serverIsDown = false

        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    success = true
                }
            }
        }

        if success {
            LLog.d("\(self)", "user logged in")
            connectingLabel.text = NSLocalizedString("Login Successful", comment: "")

            pushLocalDb()
        } else {
            LLog.d("\(self)", "user failed to login")
            connectingLabel.text = NSLocalizedString("Unable to connect to server. Please try again later.", comment: "")
        }
    }

    @IBAction func okButtonClicked(_ sender: UIButton) {
        if reloadLoginScreen {
            delegate?.notifyReloadLoginScreen()
        }

        dismiss(animated: true, completion: nil)
    }

    @objc func updateCountDown() {
        if (counter > 0) {
            counter = counter - 0.05
        } else {
            stopCountDown()
        }
    }

    func stopCountDown() {

        if serverIsDown {
            connectingLabel.text =
                NSLocalizedString("Unable to connect to server. Please try again later.", comment: "")
        } else {

        }

        okButton.isHidden = false

        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        timer?.invalidate()
        timer = nil
    }

    func pushLocalDb() {
        /*
        LJournal journal = new LJournal();

        // send over all account/category/tag/vendor
        DBAccount dbAccount = DBAccount.getInstance();
        HashSet<Long> accountIds = dbAccount.getAllActiveIds();
        for (long id : accountIds) {
            LAccount account = dbAccount.getById(id);
            if (null != account) {
                publishProgress(account.getName());
                journal.addAccount(account.getId());
            }
        }

        DBCategory dbCategory = DBCategory.getInstance();
        HashSet<Long> catIds = dbCategory.getAllActiveIds();
        for (long id : catIds) {
            LCategory category = dbCategory.getInstance().getById(id);
            if (null != category) {
                publishProgress(category.getName());
                journal.addCategory(category.getId());
            }
        }

        DBVendor dbVendor = DBVendor.getInstance();
        HashSet<Long> vendorIds = dbVendor.getAllActiveIds();
        for (long id : vendorIds) {
            LVendor vendor = dbVendor.getById(id);
            if (null != vendor) {
                publishProgress(vendor.getName());
                journal.addVendor(vendor.getId());
            }
        }

        DBTag dbTag = DBTag.getInstance();
        HashSet<Long> tagIds = dbTag.getAllActiveIds();
        for (long id : tagIds) {
            LTag tag = dbTag.getById(id);
            if (null != tag) {
                publishProgress(tag.getName());
                journal.addTag(tag.getId());
            }
        }
         */

        // get all accounts
        _ = LJournal.instance.getAllAccounts()
        _ = LJournal.instance.getAllCategories();
        _ = LJournal.instance.getAllTags();
        _ = LJournal.instance.getAllVendors();

        // send all records
        /*
        DBTransaction dbTransaction = DBTransaction.getInstance();
        Cursor cursor = dbTransaction.getAllCursor();
        if (cursor != null) {
            LTransaction transaction = new LTransaction();
            cursor.moveToFirst();
            do {
                dbTransaction.getValues(cursor, transaction);
                if (transaction.getType() != LTransaction.TRANSACTION_TYPE_TRANSFER_COPY)
                journal.addRecord(transaction.getId());
                LLog.d(TAG, "adding record: " + transaction.getId());
                publishProgress(DBAccount.getInstance().getNameById(transaction.getAccount()) + " : " +
                transaction.getValue());
            } while (cursor.moveToNext());
            cursor.close();
        }
         */

        _ = LJournal.instance.getAllRecords();
        //_ = LJournal.instance.getAllSchedules();
    }
}
