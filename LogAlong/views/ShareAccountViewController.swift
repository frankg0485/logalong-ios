//
//  ShareAccountViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 12/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class ShareAccountViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var allAccountsSwitch: UISwitch!
    @IBOutlet weak var addUserToAccountButton: UIButton!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var shareAccountLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var allAccountsLabel: UILabel!

    var account: LAccount = LAccount()
    var ownAccount: Bool = false
    var applyToAllAccounts: Bool = false
    var origSelectedIds: Set<Int64> = []
    var selectedIds: Set<Int64> = []

    weak var accountsVC: AccountsTableViewController? = nil

    var viewHeight: CGFloat = 0 {
        didSet {
            if viewHeight >= maxHeight {
                usersTableView.isScrollEnabled = true
            } else {
                self.preferredContentSize.height = viewHeight
            }
        }
    }
    let maxHeight = UIScreen.main.bounds.height

    var shareUsers: [LUser] = [] {
        didSet {
            checkBoxClicked.append(false)
        }
    }

    var checkBoxClicked: [Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        userIdTextField.delegate = self

        if account.getShareIdsStates().shareIds.isEmpty {
            ownAccount = true
        } else {
            ownAccount = account.getOwner() == LPreferences.getUserIdNum()
        }

        if !ownAccount {
            usersTableView.isUserInteractionEnabled = false
            okButton.setTitle("Unshare", for: .normal)

            viewHeight -= userIdTextField.frame.size.height

            userIdTextField.setSize(w: 0, h: 0)
            allAccountsLabel.isHidden = true
            allAccountsSwitch.isHidden = true
        }

        populateUsersArray()
        usersTableView.tableFooterView = UIView()
        setImageToUserButton()
        addUserToAccountButton.setSize(w: 25, h: 25)
        shareAccountLabel.text = shareAccountLabel.text! + " \(account.name)"

        if ownAccount { okButton.isEnabled = false } else { checkOkButtonState() }

        LBroadcast.register(LBroadcast.ACTION_GET_USER_BY_NAME, cb: #selector(self.getUserByName), listener: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkOkButtonState() {
        if ownAccount {
            if (origSelectedIds == selectedIds) || (shareUsers.isEmpty && (!checkBoxClicked.contains(true))) {
                okButton.isEnabled = false
            } else {
                okButton.isEnabled = true
            }
        } else {
            okButton.isEnabled = true
        }
    }

    @IBAction func checkButtonClicked(_ sender: UIButton) {
        let userCell = sender.superview?.superview as! UsersTableViewCell
        if checkBoxClicked[(usersTableView.indexPath(for: userCell)?.row)!] {
            selectedIds.remove(shareUsers[(usersTableView.indexPath(for: userCell)?.row)!].id)
            checkBoxClicked[(usersTableView.indexPath(for: userCell)?.row)!] = false
            sender.setImage(#imageLiteral(resourceName: "btn_check_off_normal_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            selectedIds.insert(shareUsers[(usersTableView.indexPath(for: userCell)?.row)!].id)
            checkBoxClicked[(usersTableView.indexPath(for: userCell)?.row)!] = true
            sender.setImage(#imageLiteral(resourceName: "btn_check_on_focused_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        }

        checkOkButtonState()
    }

    @objc func getUserByName(notification: Notification) -> Void {
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    if let userId = bdata["name"] as? String {
                        if let fullName = bdata["fullName"] as? String {
                            if let gid = bdata["id"] as? Int64 {
                                shareUsers.append(LUser(userId, fullName, gid))

                                userIdTextField.text = ""
                                viewHeight += CGFloat(LTheme.Dimension.table_view_cell_height)
                                usersTableView.reloadData()
                            }
                        }
                    }
                }
            }
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
            if !(userId.isEmpty) {
                shareUsers.append(LUser(userId, fullName, ii))
                viewHeight += CGFloat(LTheme.Dimension.table_view_cell_height)
            }
        }
    }

    @IBAction func addUserClicked(_ sender: UIButton) {
        if !(userIdTextField.text?.isEmpty)! {
            UiRequest.instance.UiGetUserByName(userIdTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    func setImageToUserButton() {
        addUserToAccountButton.setImage(#imageLiteral(resourceName: "ic_action_add_to_queue").withRenderingMode(.alwaysOriginal), for: .normal)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonClicked(_ sender: UIButton) {
        accountsVC?.onShareAccountDialogExit(applyToAllAccounts, account.id, selectedIds, origSelections: origSelectedIds)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func switchSwitched(_ sender: UISwitch) {
        if sender.isOn {
            applyToAllAccounts = true
        } else {
            applyToAllAccounts = false
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UsersTableViewCell

        cell.userLabel.text = "\(shareUsers[indexPath.row].fullName) (\(shareUsers[indexPath.row].name))"

        let shareStates = account.getShareIdsStates().shareStates
        let shareIds = account.getShareIdsStates().shareIds

        if !shareIds.isEmpty {
            if account.getShareUserState(shareUsers[indexPath.row].id) == LAccount.ACCOUNT_SHARE_INVITED {
                checkBoxClicked[indexPath.row] = true

                cell.checkButton.setImage(#imageLiteral(resourceName: "btn_check_on_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share_yellow").withRenderingMode(.alwaysOriginal), for: .normal)
                if ownAccount { selectedIds.insert(shareUsers[indexPath.row].id) }
            } else if account.getShareUserState(shareUsers[indexPath.row].id) == LAccount.ACCOUNT_SHARE_PERMISSION_READ_WRITE {
                checkBoxClicked[indexPath.row] = true

                cell.checkButton.setImage(#imageLiteral(resourceName: "btn_check_on_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share_green").withRenderingMode(.alwaysOriginal), for: .normal)
                if ownAccount { selectedIds.insert(shareUsers[indexPath.row].id) }
            } else if account.getShareUserState(shareUsers[indexPath.row].id) == LAccount.ACCOUNT_SHARE_NA {
                cell.checkButton.setImage(#imageLiteral(resourceName: "btn_check_off_normal_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share").withRenderingMode(.alwaysOriginal), for: .normal)
            }

            if account.getShareUserState(shareUsers[indexPath.row].id) == LAccount.ACCOUNT_SHARE_PERMISSION_OWNER {
                checkBoxClicked[indexPath.row] = true

                cell.ownerButton.setImage(#imageLiteral(resourceName: "preferences_system").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.setImage(#imageLiteral(resourceName: "btn_check_on_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share_green").withRenderingMode(.alwaysOriginal), for: .normal)
            }

        } else {
            cell.checkButton.setImage(#imageLiteral(resourceName: "btn_check_off_normal_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
            cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share").withRenderingMode(.alwaysOriginal), for: .normal)

        }

        cell.backgroundColor = LTheme.Color.row_released_color
        return cell
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
