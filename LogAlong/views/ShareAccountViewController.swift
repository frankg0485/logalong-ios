//
//  ShareAccountViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 12/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class ShareAccountViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var msgLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var addUserButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var allAccountView: UIView!
    @IBOutlet weak var allAccountViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addUserToAccountButton: UIButton!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var userIdTextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var shareAccountLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var progressWidth: NSLayoutConstraint!

    private var checkboxAllAccounts: LCheckbox!
    private let BASE_HEIGHT: CGFloat = 200
    private let MSG_HEIGHT: CGFloat = 35
    private let TABLE_CELL_HEIGHT: CGFloat = 50
    private let PROGRESS_WIDTH: CGFloat = 30
    private let ADD_USER_WIDTH: CGFloat = 30

    private var timer: Timer?
    private var count: Double = 0
    private var overlayViewController: UIViewController?

    var account: LAccount!
    weak var accountsVC: AccountsTableViewController!
    var origSelectedIds: Set<Int64> = []

    private var ownAccount: Bool = false
    private var selectedIds: Set<Int64>!

    private var userName: String?

    private var shareUsers: [LUser] = []
    private var checkBoxClicked: [Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        LBroadcast.register(LBroadcast.ACTION_GET_USER_BY_NAME, cb: #selector(self.getUserByName), listener: self)

        self.preferredContentSize.width = LTheme.Dimension.popover_width

        usersTableView.delegate = self
        usersTableView.dataSource = self
        usersTableView.tableFooterView = UIView()
        usersTableView.backgroundColor = LTheme.Color.light_row_released_color
        usersTableView.layer.cornerRadius = 5
        usersTableView.clipsToBounds = true

        userIdTextField.delegate = self

        selectedIds = origSelectedIds
        if account.getShareIdsStates().shareIds.isEmpty {
            ownAccount = true
        } else {
            ownAccount = account.getOwner() == LPreferences.getUserIdNum()
        }

        if !ownAccount {
            usersTableView.isUserInteractionEnabled = false
            okButton.setTitle("Unshare", for: .normal)

            userIdTextField.isHidden = true
            userIdTextFieldHeight.constant = 0
            addUserToAccountButton.isHidden = true
            allAccountView.isHidden = true
            allAccountViewHeight.constant = 0
        }

        populateUsersArray()
        checkOkButtonState()
        setupDisplay()
        setViewHeight()
    }

    override func viewWillAppear(_ animated: Bool) {
        //view.superview?.layer.borderColor = UIColor.white.cgColor
        //view.superview?.layer.borderWidth = 1
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setTapGesture(_ view: UIView) {
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickView(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    private func setViewHeight() {
        var height: CGFloat = BASE_HEIGHT
        if !ownAccount {
            height -= 80
        }

        let count = shareUsers.count > 6 ? 6 : shareUsers.count
        let tableH: CGFloat = CGFloat(count) * TABLE_CELL_HEIGHT
        tableHeight.constant = tableH

        height += tableH
        preferredContentSize.height = height
    }

    private func setupDisplay() {
        shareAccountLabel.text = shareAccountLabel.text! + " \(account.name)"

        addUserToAccountButton.setImage(#imageLiteral(resourceName: "ic_action_add_to_queue2").withRenderingMode(.alwaysOriginal), for: .normal)
        addUserButtonWidth.constant = ADD_USER_WIDTH

        progress.isHidden = true
        progressWidth.constant = 0

        let ROW_H: CGFloat = 50
        let ROW_H2: CGFloat = 35

        let hl3 = HorizontalLayout(height: ROW_H2)
        hl3.layoutMargins = UIEdgeInsetsMake(0, 0, ROW_H - ROW_H2, 0)
        checkboxAllAccounts = LCheckbox(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        checkboxAllAccounts.layoutMargins = UIEdgeInsetsMake(0, 6, 0, 0)
        checkboxAllAccounts.isUserInteractionEnabled = false
        checkboxAllAccounts.isSelected = false
        let label0 = UILabel(frame: CGRect(x: 1, y: 0, width: 0, height: ROW_H2))
        label0.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        label0.text = NSLocalizedString("apply to all accounts", comment: "")
        label0.textColor = LTheme.Color.light_gray_text_color

        hl3.addSubview(checkboxAllAccounts)
        hl3.addSubview(label0)

        allAccountView.addSubview(hl3)
        setTapGesture(allAccountView)
    }

    @objc func timerHandler() {
        stopTimer()
        msgLabel.text = NSLocalizedString("Unable to connect to server.", comment: "")
    }

    private func startProgress() {
        msgLabel.text = ""
        timer = Timer.scheduledTimer(timeInterval: LServer.REQUEST_TIMEOUT_SECONDS, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: false)
        overlayViewController = UIViewController()
        overlayViewController!.modalPresentationStyle = .overCurrentContext
        overlayViewController!.view.backgroundColor = .clear
        overlayViewController!.view.isOpaque = false
        self.present(overlayViewController!, animated: false, completion: nil)

        progress.isHidden = false
        progressWidth.constant = PROGRESS_WIDTH
        progress.startAnimating()
        addUserToAccountButton.isHidden = true
        addUserButtonWidth.constant = 0
    }

    private func stopTimer() {
        timer?.invalidate()
        overlayViewController?.dismiss(animated: false, completion: nil)

        addUserButtonWidth.constant = ADD_USER_WIDTH
        addUserToAccountButton.isHidden = false

        progress.isHidden = true
        progress.stopAnimating()
        progressWidth.constant = 0
    }

    @objc func onClickView(_ sender: UITapGestureRecognizer) {
        userIdTextField.resignFirstResponder()

        if allAccountView == sender.view {
            checkboxAllAccounts.isSelected = !checkboxAllAccounts.isSelected
        }
    }

    private func checkOkButtonState() {
        if ownAccount {
            okButton.isEnabled = (origSelectedIds != selectedIds)
        } else {
            okButton.isEnabled = true
        }
    }

    private func doCheckButton(_ row: Int) {
        checkBoxClicked[row] = !checkBoxClicked[row]

        if checkBoxClicked[row] {
            selectedIds.insert(shareUsers[row].id)
        } else {
            selectedIds.remove(shareUsers[row].id)
        }
        checkOkButtonState()
    }

    @IBAction func checkButtonClicked(_ sender: UIButton) {
        let userCell = sender.superview?.superview as! UsersTableViewCell
        if let row = usersTableView.indexPath(for: userCell)?.row {
            doCheckButton(row)
            userCell.checkButton.isSelected = checkBoxClicked[row]
        }
    }

    private func isUserListed(_ id: Int64) -> Bool {
        if id == LPreferences.getUserIdNum() { return true }
        for user in shareUsers {
            if user.id == id { return true }
        }
        return false
    }

    @objc func getUserByName(notification: Notification) -> Void {
        var success = false
        stopTimer()

        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    if let userId = bdata["name"] as? String {
                        if userId.caseInsensitiveCompare(userName!) == .orderedSame {
                            var fullName = ""
                            if let fn = bdata["fullName"] as? String {
                                fullName = fn
                            }
                            if let gid = bdata["id"] as? Int64 {
                                if !isUserListed(gid) {
                                    shareUsers.append(LUser(userId, fullName, gid))
                                    checkBoxClicked.append(true)
                                    selectedIds.insert(gid)

                                    userIdTextField.text = ""
                                    setViewHeight()
                                    usersTableView.reloadData()
                                    checkOkButtonState()
                                }
                            }
                            success = true
                        } else { return }
                    }
                }
            }
        }
        if !success {
            msgLabel.text = NSLocalizedString("Invalid user ID", comment: "")
        }
    }

    func populateUsersArray() {
        let dbAccount = DBAccount.instance
        let userSet = dbAccount.getAllShareUser()

        for ii in userSet {
            if ii == LPreferences.getUserIdNum() {
                continue
            }

            let userId = LPreferences.getShareUserId(ii)
            let fullName = LPreferences.getShareUserName(ii)
            if userId != nil {
                shareUsers.append(LUser(userId!, fullName ?? "", ii))
                checkBoxClicked.append(account.getShareUserState(ii) != LAccount.ACCOUNT_SHARE_NA)
            }
        }
    }

    @IBAction func addUserClicked(_ sender: UIButton) {
        if let uid = userIdTextField.text {
            userName = uid.trimmingCharacters(in: .whitespacesAndNewlines)
            if !userName!.isEmpty {
                startProgress()
                _ = UiRequest.instance.UiGetUserByName(userName!)
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonClicked(_ sender: UIButton) {
        if !ownAccount {
            //this is the case where 'unshare' is clicked
            selectedIds.removeAll()
            checkboxAllAccounts.isSelected = false //JIC
        }
        accountsVC?.onShareAccountDialogExit(checkboxAllAccounts.isSelected, account.id,
                                             selectedIds, origSelections: origSelectedIds)
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareUsers.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        doCheckButton(indexPath.row)
        if let cell = tableView.cellForRow(at: indexPath) as? UsersTableViewCell {
            cell.checkButton.isSelected = checkBoxClicked[indexPath.row]
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UsersTableViewCell

        let row = indexPath.row
        cell.userLabel.text = "\(shareUsers[row].fullName) (\(shareUsers[row].name))"

        let shareIds = account.getShareIdsStates().shareIds
        if !shareIds.isEmpty {
            switch account.getShareUserState(shareUsers[row].id) {
            case LAccount.ACCOUNT_SHARE_INVITED:
                cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share_yellow").withRenderingMode(.alwaysOriginal), for: .normal)
            case LAccount.ACCOUNT_SHARE_PERMISSION_READ_WRITE:
                cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share_green").withRenderingMode(.alwaysOriginal), for: .normal)
            case LAccount.ACCOUNT_SHARE_PERMISSION_OWNER:
                cell.ownerButton.setImage(#imageLiteral(resourceName: "preferences_system").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share_green").withRenderingMode(.alwaysOriginal), for: .normal)
            case LAccount.ACCOUNT_SHARE_NA: fallthrough
            default:
                cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share").withRenderingMode(.alwaysOriginal), for: .normal)
            }
        } else {
            cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share").withRenderingMode(.alwaysOriginal), for: .normal)
        }

        cell.checkButton.isSelected = checkBoxClicked[row]
        cell.backgroundColor = LTheme.Color.light_row_released_color
        return cell
    }
}
