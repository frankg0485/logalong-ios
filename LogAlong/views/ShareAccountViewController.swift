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
    var viewHeight: CGFloat = 216 {
        didSet {
            self.preferredContentSize.height = viewHeight
        }
    }
    let maxHeight = UIScreen.main.bounds.height

    override func viewDidLoad() {
        super.viewDidLoad()
        usersTableView.delegate = self
        usersTableView.dataSource = self
        userIdTextField.delegate = self

        setImageToUserButton()
        shareAccountLabel.text = shareAccountLabel.text! + " \(accountName)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addUserClicked(_ sender: UIButton) {
        viewHeight += 44
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
        UiRequest.instance.UiGetUserByName(accountName)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func switchSwitched(_ sender: UISwitch) {

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UsersTableViewCell else {
            fatalError("The dequeued cell is not an instance of SelectTableViewCell.")
        }

        cell.userLabel.text = "Test"

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
