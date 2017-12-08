//
//  LoginInfoTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/5/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LoginInfoTableViewController: UITableViewController, FLoginViewControllerDelegate, UITextFieldDelegate, FReloadLoginScreenDelegate, FLoginTypeDelegate {

    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet var nameCell: UITableViewCell!
    @IBOutlet weak var showPasswordCell: UITableViewCell!
    @IBOutlet weak var passwordCell: UITableViewCell!

    var delegate: FPassNameIdPasswordDelegate?

    var loginType: Int = 0

    private var validUser = false

    override func viewDidLoad() {
        super.viewDidLoad()

        //nameCell.isHidden = false

        if !LPreferences.getUserId().isEmpty {
            validUser = true

            /*passwordCell.isHidden = true
            showPasswordCell.isHidden = true*/

            tableView.separatorStyle = .none

            userIdTextField.text = LPreferences.getUserId()
            nameTextField.text = LPreferences.getUserName()
        }

        passwordTextField.delegate = self
        userIdTextField.delegate = self
        nameTextField.delegate = self

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

    func getFinalLoginType() -> Int {
        if nameCell.isHidden == true {
            return typeOfLogin.LOGIN.rawValue
        } else {
            return typeOfLogin.CREATE.rawValue
        }
    }

    func reloadLoginScreen() {
        self.viewDidLoad()
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
        checkTextFields()
    }

    func showHideNameCell(hide: Bool) {
        if (hide == true) {
            nameCell.isHidden = true
        } else {
            nameCell.isHidden = false
        }
    }
    // MARK: - Table view data source

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
        if (validUser) {
            return super.tableView(tableView, numberOfRowsInSection: section) - 2
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

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


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }*/


}
