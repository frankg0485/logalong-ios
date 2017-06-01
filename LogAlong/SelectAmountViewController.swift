//
//  SelectAmountViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/30/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit

class SelectAmountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var amountTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        amountTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text?.isEmpty == true) {
            return false
        } else {
            textField.resignFirstResponder()
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismiss(animated: true, completion: nil)
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
