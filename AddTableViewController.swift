//
//  AddTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 4/22/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit
import os.log

var accounts: [String] = ["Cash", "Checking", "Credit: Discover", "Credit: Master", "Credit: Visa"]
var categories: [String] = ["Grocery", "Kids", "Eat Out", "Fuel", "Kids: Piano"]
var payees: [String] = ["Costco", "Walmart", "Chipotle", "Panera", "Biaggis"]
var tags: [String] = ["Market America", "2014 Summer", "2015 Summer", "2016 Summer", "2017 Summer"]
class AddTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, FViewControllerDelegate {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var payeeLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
        @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var notesTextField: UITextField!
    
    var record: Record?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextField.delegate = self
        updateSaveButtonState()
        // Uncomment the/ following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func passIntBack(_ caller: UIViewController, myInt: Int) {
        if let _ = caller as? SelectAmountViewController {
            amountLabel.text = String(myInt)
        } else if let _ = caller as? SelectAccountTableViewController {
            accountLabel.text = accounts[myInt]
            
        } else if let _ = caller as? SelectCategoryTableViewController {
            categoryLabel.text = categories[myInt]
            
        } else if let _ = caller as? SelectPayeeTableViewController {
            payeeLabel.text = payees[myInt]
            
        } else {
            tagLabel.text = tags[myInt]
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

    
    // MARK: - Table view data source
    
    /*    override func numberOfSections(in tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 0
     }
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // #warning Incomplete implementation, return the number of rows
     return 0
     }
     */
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
        return cell
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ChooseAccount")
            || (segue.identifier == "ChooseCategory")
            || (segue.identifier == "ChoosePayee")
            || (segue.identifier == "ChooseTag")
            || (segue.identifier == "ChooseAmount") {
            
            let popoverViewController = segue.destination
            
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            
            popoverViewController.popoverPresentationController!.delegate = self
            
        }
        
        if let secondViewController = segue.destination as? SelectAccountTableViewController {
            
            secondViewController.delegate = self
        } else if let secondViewController = segue.destination as? SelectCategoryTableViewController {
            secondViewController.delegate = self
            
        }  else if let secondViewController = segue.destination as? SelectPayeeTableViewController {
            secondViewController.delegate = self
            
        }  else if let secondViewController = segue.destination as? SelectTagTableViewController {
            secondViewController.delegate = self
        }  else if let secondViewController = segue.destination as? SelectAmountViewController {
            secondViewController.delegate = self
        }  else {
            guard let button = sender as? UIBarButtonItem, button === saveButton else {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                return
            }
            
            let amount = Int(amountLabel.text!)!
            let account = accountLabel.text
            let category = categoryLabel.text
            let payee = payeeLabel.text
            let tag = tagLabel.text
            let notes = notesTextField.text
            
            record = Record(category: category, amount: amount, account: account!, payee: payee, tag: tag, notes: notes)
        }
    }
    
    
    
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        
        if (amountLabel.text?.isEmpty == true) || (accountLabel.text?.isEmpty == true) {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
}
