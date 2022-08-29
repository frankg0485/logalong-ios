//
//  LoginScreenViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/6/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

enum ProfileAction {
    case CREATE_USER
    case LOGIN_USER
    case UPDATE_USER
}

class ProfileViewController: UIViewController, UITextFieldDelegate, FShowPasswordCellsDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var headerView: VerticalLayout!
    @IBOutlet weak var bottomView: HorizontalLayout!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var progress: UIActivityIndicatorView!

    var checkboxLogin : LCheckbox!
    var checkboxShowPass: LCheckbox!
    var showPassView: HorizontalLayout!
    var passView: HorizontalLayout!
    var nameView: HorizontalLayout!
    var passValue: UITextField!
    var idValue: UITextField!
    var nameValue: UITextField!
    var optionButton: UIButton!

    var name: String = ""
    var userId: String = ""
    var password: String = ""
    var oldName: String = ""
    var oldUserId: String = ""
    var oldPassword: String = ""
    var profileAction: ProfileAction = .UPDATE_USER
    var pushDb = false
    var pushingDb = false

    var timer: Timer?
    var count: Double = 0
    var overlayViewController: UIViewController?

    let doneButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    let ROW_H: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LTheme.Color.default_bgd_color

        LServer.instance.connect()
        setupNavigationBarItems()
        setupDisplay()
        progress.isHidden = true
        msgLabel.text = ""

        name = LPreferences.getUserName()
        userId = LPreferences.getUserId()
        password = LPreferences.getUserPassword()

        oldName = name
        oldUserId = userId
        oldPassword = password
        doneButton.isEnabled = false

        if (LPreferences.getUserId().isEmpty || LPreferences.getUserIdNum() <= 0) {
            optionButton.isHidden = true
            showPassView.isHidden = false
            passView.isHidden = false
            profileAction = .CREATE_USER
        } else {
            showPassView.isHidden = true
            passView.isHidden = true
            bottomView.isHidden = true
            optionButton.isHidden = false
            idValue.text = userId
            idValue.isEnabled = false
            nameValue.text = name
            profileAction = .UPDATE_USER
        }

        if LPreferences.getUserId().isEmpty {
            LBroadcast.register(LBroadcast.ACTION_CREATE_USER, cb: #selector(self.createUser), listener: self)
            LBroadcast.register(LBroadcast.ACTION_SIGN_IN, cb: #selector(self.signin), listener: self)
            LBroadcast.register(LBroadcast.ACTION_LOG_IN, cb: #selector(self.login), listener: self)
            LBroadcast.register(LBroadcast.ACTION_GET_USER_BY_NAME, cb: #selector(self.getUserByName), listener: self)
        } else {
            LBroadcast.register(LBroadcast.ACTION_UPDATE_USER_PROFILE, cb: #selector(self.updateProfile), listener: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupNavigationBarItems() {
        let BTN_W: CGFloat = LTheme.Dimension.bar_button_width
        let BTN_H: CGFloat = LTheme.Dimension.bar_button_height

        cancelButton.addTarget(self, action: #selector(self.cancelButtonClicked), for: .touchUpInside)
        cancelButton.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        cancelButton.setSize(w: BTN_W + 20, h: BTN_H)

        doneButton.addTarget(self, action: #selector(self.doneButtonClicked), for: .touchUpInside)
        doneButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)
        doneButton.setImage(#imageLiteral(resourceName: "ic_action_accept_disabled").withRenderingMode(.alwaysOriginal), for: .disabled)
        doneButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        doneButton.setSize(w: BTN_W + 40, h: BTN_H)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)

        let titleBtn = UIButton(type: .custom)
        titleBtn.setSize(w: 80, h: 30)
        titleBtn.setTitle(NSLocalizedString("Profile", comment: ""), for: .normal)
        navigationItem.titleView = titleBtn
        //navigationController?.navigationBar.isTranslucent = false
        //navigationController?.navigationBar.barStyle = .black
    }

    private func setTapGesture(_ view: UIView) {
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickView(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupDisplay() {
        let LABEL_W: CGFloat = 85
        let ROW_H2: CGFloat = 35
        let FONT_H: CGFloat = 20

        let hl1 = HorizontalLayout(height: ROW_H)
        //hl1.backgroundColor = LTheme.Color.row_released_color
        hl1.layoutMargins = UIEdgeInsets(top: LTheme.Dimension.list_item_space, left: 0, bottom: 0, right: 0)
        let idLabel = UILabel(frame: CGRect(x: 0, y: 0, width: LABEL_W, height: ROW_H))
        idLabel.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        idLabel.text = NSLocalizedString("User ID", comment: "")
        idLabel.textColor = LTheme.Color.gray_text_color

        idValue = UITextField(frame: CGRect(x: 1, y: 0, width: 0, height: ROW_H))
        idValue.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        idValue.placeholder = NSLocalizedString("userid", comment: "")
        idValue.font = UIFont.boldSystemFont(ofSize: FONT_H)
        idValue.textColor = LTheme.Color.base_text_color
        idValue.autocorrectionType = .no
        idValue.autocapitalizationType = .none
        idValue.spellCheckingType = .no
        idValue.delegate = self
        idValue.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        optionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: ROW_H))
        optionButton.addTarget(self, action: #selector(onClickOption), for: .touchUpInside)
        optionButton.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        optionButton.setImage(#imageLiteral(resourceName: "ic_action_overflow_dark").withRenderingMode(.alwaysOriginal), for: .normal)
        optionButton.imageEdgeInsets = UIEdgeInsets(top: 9, left: 6, bottom: 9, right: 12);

        hl1.addSubview(idLabel)
        hl1.addSubview(idValue)
        hl1.addSubview(optionButton)

        let separatorLayout = HorizontalLayout(height: 1)
        separatorLayout.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let separator1 = UIView(frame: CGRect(x: 1, y: 0, width: 0, height: 1))
        separator1.backgroundColor = LTheme.Color.light_row_released_color
        separator1.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        separatorLayout.addSubview(separator1)

        let hl2 = HorizontalLayout(height: ROW_H)
        //hl2.backgroundColor = LTheme.Color.row_released_color
        hl2.layoutMargins = UIEdgeInsets(top: LTheme.Dimension.list_item_space, left: 0, bottom: 0, right: 0)

        let passLabel = UILabel(frame: CGRect(x: 0, y: 0, width: LABEL_W, height: ROW_H))
        passLabel.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        passLabel.text = NSLocalizedString("Password", comment: "")
        passLabel.textColor = LTheme.Color.gray_text_color
        passValue = UITextField(frame: CGRect(x: 1, y: 0, width: 0, height: ROW_H))
        passValue.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        passValue.placeholder = NSLocalizedString("password", comment: "")
        passValue.font = UIFont.boldSystemFont(ofSize: FONT_H)
        passValue.textColor = LTheme.Color.base_text_color
        passValue.isSecureTextEntry = true
        passValue.delegate = self
        passValue.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passView = hl2

        hl2.addSubview(passLabel)
        hl2.addSubview(passValue)

        let hl3 = HorizontalLayout(height: ROW_H - 5)
        hl3.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: ROW_H - ROW_H2 - 10, right: 0)
        hl3.backgroundColor = LTheme.Color.default_bgd_color

        checkboxShowPass = LCheckbox(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkboxShowPass.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        checkboxShowPass.isUserInteractionEnabled = false
        checkboxShowPass.isSelected = false
        let label0 = UILabel(frame: CGRect(x: 1, y: 0, width: 0, height: ROW_H2))
        label0.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        label0.text = NSLocalizedString("show password", comment: "")
        label0.textColor = LTheme.Color.light_gray_text_color
        showPassView = hl3

        hl3.addSubview(checkboxShowPass)
        hl3.addSubview(label0)

        let hl4 = HorizontalLayout(height: ROW_H)
        //hl4.backgroundColor = LTheme.Color.row_released_color
        hl4.layoutMargins = UIEdgeInsets(top: LTheme.Dimension.list_item_space, left: 0, bottom: 0, right: 0)

        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: LABEL_W, height: ROW_H))
        nameLabel.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        nameLabel.text = NSLocalizedString("Name", comment: "")
        nameLabel.textColor = LTheme.Color.gray_text_color

        nameValue = UITextField(frame: CGRect(x: 1, y: 0, width: 0, height: ROW_H))
        nameValue.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        nameValue.placeholder = NSLocalizedString("Your Name", comment: "")
        nameValue.font = UIFont.boldSystemFont(ofSize: FONT_H)
        nameValue.textColor = LTheme.Color.base_text_color
        nameValue.autocapitalizationType = .none
        nameValue.autocorrectionType = .no
        nameValue.spellCheckingType = .no
        nameValue.delegate = self
        nameValue.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameView = hl4

        hl4.addSubview(nameLabel)
        hl4.addSubview(nameValue)

        headerView.addSubview(hl1)
        headerView.addSubview(separatorLayout)
        headerView.addSubview(hl2)
        headerView.addSubview(hl3)
        headerView.addSubview(hl4)

        checkboxLogin = LCheckbox(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        checkboxLogin.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        checkboxLogin.isUserInteractionEnabled = false
        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 0, height: ROW_H))
        label.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        label.text = NSLocalizedString("Login with existing user ID", comment: "")
        label.textColor = LTheme.Color.light_gray_text_color
        bottomView.addSubview(checkboxLogin)
        bottomView.addSubview(label)
        bottomView.backgroundColor = LTheme.Color.light_row_released_color

        setTapGesture(showPassView)
        setTapGesture(bottomView)
        setTapGesture(self.view)
    }

    @objc func onClickView(_ sender: UITapGestureRecognizer) {
        hideTextFieldCursor()
        if bottomView == sender.view {
            checkboxLogin.isSelected = !checkboxLogin.isSelected
            nameView.isHidden = checkboxLogin.isSelected
            profileAction = checkboxLogin.isSelected ? .LOGIN_USER : .CREATE_USER
            setDoneButtonState()
        } else if showPassView == sender.view {
            checkboxShowPass.isSelected = !checkboxShowPass.isSelected
            passValue.isSecureTextEntry = !checkboxShowPass.isSelected
        }
    }

    // called upon successful login from 'options'
    func showPasswordCells() {
        optionButton.isHidden = true
        passView.isHidden = false
        showPassView.isHidden = false
        passValue.text = password
        headerView.refresh()
    }

    @objc func onClickOption() {
        hideTextFieldCursor()

         let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrentPasswordViewController") as!CurrentPasswordViewController

         vc.modalPresentationStyle = UIModalPresentationStyle.popover
         vc.popoverPresentationController?.sourceView = self.view
         vc.popoverPresentationController?.sourceRect =
             CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 22, width: 0, height: 0)
         vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
         vc.popoverPresentationController!.delegate = self

         vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

    @objc func cancelButtonClicked(_ sender: UIBarButtonItem) {
        LBroadcast.unregister(LBroadcast.ACTION_CREATE_USER, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_SIGN_IN, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_LOG_IN, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_GET_USER_BY_NAME, listener: self)
        LBroadcast.unregister(LBroadcast.ACTION_UPDATE_USER_PROFILE, listener: self)

        //dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }

    @objc func doneButtonClicked(_ sender: UIBarButtonItem) {
        hideTextFieldCursor()

        switch profileAction {
        case .CREATE_USER: fallthrough
        case .LOGIN_USER:
            _ = UiRequest.instance.UiGetUserByName(userId)
        default:
            _ = UiRequest.instance.UiUpdateUserProfile(userId, LPreferences.getUserPassword(), newPass: password, fullName: name)
        }
        startTimer(LServer.REQUEST_TIMEOUT_SECONDS)
    }

    @objc func timerHandler() {
        stopTimer()
        msgLabel.text = NSLocalizedString("Unable to connect to server. Please try again later.", comment: "")
    }

    private func resetTimer(_ interval: Double) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: false)
    }

    private func startTimer(_ interval: Double) {
        resetTimer(interval)

        tabBarController?.tabBar.isUserInteractionEnabled = false

        progress.isHidden = false
        progress.startAnimating()

        overlayViewController = UIViewController()
        overlayViewController!.modalPresentationStyle = .overCurrentContext
        overlayViewController!.view.backgroundColor = .clear
        overlayViewController!.view.isOpaque = false
        self.present(overlayViewController!, animated: false, completion: nil)
    }

    private func stopTimer() {
        progress.stopAnimating()
        progress.isHidden = true
        timer?.invalidate()
        overlayViewController?.dismiss(animated: false, completion: nil)

        tabBarController?.tabBar.isUserInteractionEnabled = true
    }

    private func hideTextFieldCursor() {
        msgLabel.text = ""
        idValue.resignFirstResponder()
        passValue.resignFirstResponder()
        nameValue.resignFirstResponder()
    }
    private func setDoneButtonState() {
        if userId.isEmpty || password.isEmpty {
            doneButton.isEnabled = false
        } else{
            if (userId != oldUserId || password != oldPassword || name != oldName ) &&
                (userId.count > 1 && password.count > 3 &&
                    (name.count > 3 || checkboxLogin.isSelected)) {
                doneButton.isEnabled = true
            } else {
                doneButton.isEnabled = false
            }
        }
    }

    private func readTextField(_ textField: UITextField) {
        switch textField {
        case idValue:
            if let txt = idValue.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                idValue.text = txt
                userId = txt
            }
        case passValue:
            if let txt = passValue.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                passValue.text = txt
                password = txt
            }
        case nameValue:
            if let txt = nameValue.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                name = txt
            }
        default:
            return
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var limitLength = 0
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        switch textField {
        case idValue:
            limitLength = 12
        case passValue:
            limitLength = 20
        case nameValue:
            limitLength = 20
        default:
            return true
        }
        return newLength <= limitLength
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        readTextField(textField)
        setDoneButtonState()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        readTextField(textField)
        setDoneButtonState()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    @objc func updateProfile(notification: Notification) -> Void {
        stopTimer()
        doneButton.isEnabled = false

        LPreferences.setUserName(name)
        LPreferences.setUserPassword(password)
        nameValue.text = name
        DispatchQueue.main.async{self.navigationController?.popViewController(animated: true)}
    }

    @objc func getUserByName(notification: Notification) -> Void {
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    if profileAction == .CREATE_USER {
                        stopTimer()
                        msgLabel.text = NSLocalizedString("User ID already taken by someone else, please select a different one.", comment: "")
                    } else {
                        resetTimer(LServer.REQUEST_TIMEOUT_SECONDS)
                        _ = UiRequest.instance.UiSignIn(userId, password)
                    }
                } else {
                    if profileAction == .CREATE_USER {
                        resetTimer(LServer.REQUEST_TIMEOUT_SECONDS)
                        _ = UiRequest.instance.UiCreateUser(userId, password, fullname: name)
                    } else {
                        stopTimer()
                        msgLabel.text = NSLocalizedString("Invalid user ID", comment: "")
                    }
                }
            }
        }
    }

    @objc func createUser(notification: Notification) -> Void {
        var success = false
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    LPreferences.setUserId(userId)
                    LPreferences.setUserPassword(password)
                    LPreferences.setUserName(name)
                    success = true

                    resetTimer(LServer.REQUEST_TIMEOUT_SECONDS)
                    _ = UiRequest.instance.UiLogIn(userId, password)
                    pushDb = true
                }
            }
        }

        if !success {
            stopTimer()
            msgLabel.text = NSLocalizedString("Unable to connect to server. Please try again later.", comment: "")
        }
    }

    @objc func signin(notification: Notification) -> Void {
        var success = false

        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    LPreferences.setUserId(userId)
                    LPreferences.setUserPassword(password)
                    if let name = bdata["fullName"] as? String {
                        LPreferences.setUserName(name)
                        nameValue.text = name
                    }
                    success = true

                    resetTimer(LServer.REQUEST_TIMEOUT_SECONDS)
                    _ = UiRequest.instance.UiLogIn(userId, password)

                    doneButton.isEnabled = false
                    pushDb = true
                }
            }
        }

        if !success {
            stopTimer()
            msgLabel.text = NSLocalizedString("Password mismatch", comment: "")
        }
    }

    @objc func login(notification: Notification) -> Void {
        if pushingDb {return} // this must be the case where app resumed from background

        var success = false

        stopTimer()
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    success = true
                }
            }
        }

        if success {
            LLog.d("\(self)", "user logged in")
            nameView.isHidden = false
            showPassView.isHidden = true
            passView.isHidden = true
            bottomView.isHidden = true
            optionButton.isHidden = false
            doneButton.isEnabled = false
            headerView.refresh()

            if pushDb {
                progress.isHidden = false
                progress.startAnimating()
                pushLocalDb()
                progress.isHidden = true
                progress.stopAnimating()
            }
        } else {
            msgLabel.text = NSLocalizedString("Unable to connect to server. Please try again later.", comment: "")
        }
    }

    private func pushLocalDb() {
        pushingDb = true

        for account in DBAccount.instance.getAll() {
            //publishProgress(account.getName());
            _ = LJournal.instance.addAccount(account.id)
        }

        for category in DBCategory.instance.getAll() {
            //publishProgress(category.getName());
            _ = LJournal.instance.addCategory(category.id)
        }

        for vendor in DBVendor.instance.getAll() {
            //publishProgress(vendor.getName());
            _ = LJournal.instance.addVendor(vendor.id)
        }

        for tag in DBTag.instance.getAll() {
            //publishProgress(tag.getName());
            _ = LJournal.instance.addTag(tag.id)
        }

        // get all accounts
        _ = LJournal.instance.getAllAccounts()
        _ = LJournal.instance.getAllCategories();
        _ = LJournal.instance.getAllTags();
        _ = LJournal.instance.getAllVendors();

        for transaction in DBTransaction.instance.getAll() {
            if transaction.type != TransactionType.TRANSFER_COPY {
                _ = LJournal.instance.addRecord(transaction.id)
            }

            //LLog.d("\(self)", "adding record: \(transaction.id)")
            //publishProgress(DBAccount.getInstance().getNameById(transaction.getAccount()) + " : " + transaction.getValue());
        }

        for schedule in DBScheduledTransaction.instance.getAll() {
            _ = LJournal.instance.addSchedule(schedule.id)
        }

        _ = LJournal.instance.getAllRecords();
        _ = LJournal.instance.getAllSchedules();
    }
}
