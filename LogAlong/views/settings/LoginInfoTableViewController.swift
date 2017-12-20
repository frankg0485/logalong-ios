//
//  LoginInfoTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/5/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit
import Foundation

class LoginInfoTableViewController: UITableViewController, FLoginViewControllerDelegate, UITextFieldDelegate, FReloadLoginScreenDelegate, FLoginTypeDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet var nameCell: UITableViewCell!
    @IBOutlet weak var showPasswordCell: UITableViewCell!
    @IBOutlet weak var passwordCell: UITableViewCell!

    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!

    var delegate: FPassNameIdPasswordDelegate?
    var loginType: Int = 0

    private var validUser = false

    override func viewDidLoad() {
        super.viewDidLoad()

        nameCell.isHidden = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white

        if !LPreferences.getUserId().isEmpty {
            validUser = true

            changePasswordButton.isHidden = false
            searchButton.isHidden = true
            checkButton.isHidden = true

            LBroadcast.register(LBroadcast.ACTION_UPDATE_USER_PROFILE, cb: #selector(self.updateUserName), listener: self)

            /*passwordCell.isHidden = true
             showPasswordCell.isHidden = true*/

            tableView.separatorStyle = .none

            userIdTextField.text = LPreferences.getUserId()
            userIdTextField.isEnabled = false
            nameTextField.text = LPreferences.getUserName()
        } else {
            changePasswordButton.isHidden = true
            searchButton.isHidden = false
            checkButton.isHidden = false

            passwordTextField.backgroundColor = UIColor(hexString: "#ced0d2")

        }

        passwordTextField.delegate = self
        userIdTextField.delegate = self
        nameTextField.delegate = self

        userIdTextField.backgroundColor = UIColor(hexString: "#ced0d2")
        nameTextField.backgroundColor = UIColor(hexString: "#ced0d2")

        passwordTextField.isSecureTextEntry = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func updateUserName(notification: Notification) {
        nameTextField.text = LPreferences.getUserName()
    }

    func getFinalLoginType() -> Int {
        if nameCell.isHidden == true {
            return typeOfLogin.LOGIN.rawValue
        } else {
            return typeOfLogin.CREATE.rawValue
        }
    }

    func reloadLoginScreen() {
        self.viewDidLoad()
        tableView.reloadData()
    }

    func checkTextFields() {
        if (nameCell.isHidden == true) {
            loginType = typeOfLogin.LOGIN.rawValue

            if (passwordTextField.text?.isEmpty == false) && (userIdTextField.text?.isEmpty == false) {
                delegate?.passLoginInfoBack(name: nil, id: userIdTextField.text!, password: passwordTextField.text!, typeOfLogin: loginType)
            }
        } else {
            loginType = typeOfLogin.CREATE.rawValue

            if (nameTextField.text?.isEmpty == false) && (passwordTextField.text?.isEmpty == false) && (userIdTextField.text?.isEmpty == false) {
                delegate?.passLoginInfoBack(name: nameTextField.text, id: userIdTextField.text!, password: passwordTextField.text!, typeOfLogin: loginType)
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (validUser) {
            LPreferences.setUserName(nameTextField.text!)
            UiRequest.instance.UiUpdateUserProfile(userIdTextField.text!, LPreferences.getUserPassword(), newPass: LPreferences.getUserPassword(), fullName: nameTextField.text!)
        } else {
            checkTextFields()
        }

    }

    func showHideNameCell(hide: Bool) {
        if hide {
            nameCell.isHidden = true
        } else {
            nameCell.isHidden = false
        }

        checkTextFields()
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(hexString: "#ced0d2")
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2) {
            if (tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.none) {
                passwordTextField.isSecureTextEntry = false
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                passwordTextField.isSecureTextEntry = true
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            }

        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (validUser) && ((indexPath.row > 0) && (indexPath.row < 3)) {
            return 0.0
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
 */
/*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (validUser) && (indexPath.row > 0) {
            return tableView.cellForRow(at: IndexPath(row: indexPath.row + 1, section: 0))!
        }
        return super.tableView(tableView, cellForRowAt: indexPath)

    }

*/
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ChangePassword") {
            let popoverViewController = segue.destination

            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover

            popoverViewController.popoverPresentationController!.delegate = self
        }
    }

}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
