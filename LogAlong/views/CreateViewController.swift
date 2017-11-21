//
//  CreateViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 8/15/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

struct NameWithId {
    var name: String = ""
    var id: Int64 = 0
}

class CreateViewController: UIViewController, UITextFieldDelegate {

    var creation: NameWithId? = NameWithId(name: "", id: 0)
    var delegate: FPassCreationBackDelegate?

    var typeBeingAdded: String = ""

    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var okButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self

        if ((presentingViewController as? UINavigationController)?.topViewController is AccountsTableViewController) || (typeBeingAdded == "Account") {
            newLabel.text = "New Account"
            nameTextField.placeholder = "Account Name"

        } else if ((presentingViewController as? UINavigationController)?.topViewController is CategoriesTableViewController) || (typeBeingAdded == "Category") {
            newLabel.text = "New Category"
            nameTextField.placeholder = "Category Name"
        }

        if let creation = creation {
            nameTextField.text = creation.name
        }


        checkOkButtonState()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func okButtonClicked(_ sender: UIButton) {
        creation?.name = nameTextField.text!

        delegate?.passCreationBack(creation: creation!)

        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkOkButtonState()
    }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }*/

    func checkOkButtonState() {
        if (nameTextField.text?.isEmpty == true) {
            okButton.isEnabled = false
        } else {
            okButton.isEnabled = true
        }
    }

}
