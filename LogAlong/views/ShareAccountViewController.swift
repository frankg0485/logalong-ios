//
//  ShareAccountViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 12/28/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class ShareAccountViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var addUserToAccountButton: UIButton!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var shareAccountLabel: UILabel!

    var account: LAccount = LAccount()
    var ownAccount: Bool = false
    var applyToAllAccounts: Bool = false
    var origSelectedIds: Set<Int64> = []
    var selectedIds: Set<Int64> = []

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

    var shareUsers: [LUser] = []
    var checkBoxClicked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        userIdTextField.delegate = self

        ownAccount = account.getOwner() == LPreferences.getUserIdNum()
        populateUsersArray()
        usersTableView.tableFooterView = UIView()
        setImageToUserButton()
        addUserToAccountButton.setSize(w: 25, h: 25)
        shareAccountLabel.text = shareAccountLabel.text! + " \(account.name)"

        LBroadcast.register(LBroadcast.ACTION_GET_USER_BY_NAME, cb: #selector(self.getUserByName), listener: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let accountsVC = presentingViewController as? AccountsTableViewController {
            //accountsVC.onShareAccountDialogExit(true, applyToAllAccounts, account.id)
        }
    }

    @IBAction func checkButtonClicked(_ sender: UIButton) {
        if checkBoxClicked {
            if let cell = sender.superview?.superview as? UsersTableViewCell {
                selectedIds.remove(shareUsers[(usersTableView.indexPath(for: cell)?.row)!].id)
            }
            checkBoxClicked = false
            sender.setImage(#imageLiteral(resourceName: "btn_check_off_normal_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            if let cell = sender.superview?.superview as? UsersTableViewCell {
                selectedIds.insert(shareUsers[(usersTableView.indexPath(for: cell)?.row)!].id)
            }
            checkBoxClicked = true
            sender.setImage(#imageLiteral(resourceName: "btn_check_on_focused_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)

        }
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
        if let accountsVC = (presentingViewController as? UINavigationController)?.topViewController as? AccountsTableViewController {
            accountsVC.onShareAccountDialogExit(applyToAllAccounts, account.id, selectedIds, origSelections: origSelectedIds)
        }
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

        cell.userLabel.text = "\(shareUsers[indexPath.row].fullName)(\(shareUsers[indexPath.row].name))"
        cell.checkButton.setImage(#imageLiteral(resourceName: "btn_check_off_normal_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share").withRenderingMode(.alwaysOriginal), for: .normal)
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
