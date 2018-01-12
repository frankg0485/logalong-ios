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

    var accountName: String = ""
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

        populateUsersArray()
        usersTableView.tableFooterView = UIView()
        setImageToUserButton()
        addUserToAccountButton.setSize(w: 25, h: 25)
        shareAccountLabel.text = shareAccountLabel.text! + " \(accountName)"

        LBroadcast.register(LBroadcast.ACTION_GET_USER_BY_NAME, cb: #selector(self.getUserByName), listener: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func checkButtonClicked(_ sender: UIButton) {
        if checkBoxClicked {
            checkBoxClicked = false
            sender.setImage(#imageLiteral(resourceName: "btn_check_off_normal_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
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
                                LPreferences.setShareUserId(gid, userId)
                                LPreferences.setShareUserName(gid, fullName)

                                userIdTextField.text = ""
                                viewHeight += 44
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
        dismiss(animated: true, completion: nil)
    }

    @IBAction func switchSwitched(_ sender: UISwitch) {

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserCell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UsersTableViewCell

        cell.userLabel.text = shareUsers[indexPath.row].name
        cell.checkButton.setImage(#imageLiteral(resourceName: "btn_check_off_normal_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        cell.shareStatusButton.setImage(#imageLiteral(resourceName: "ic_action_share").withRenderingMode(.alwaysOriginal), for: .normal)
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
