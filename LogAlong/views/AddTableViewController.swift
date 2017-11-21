//
//  AddTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 4/22/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit
import os.log

struct TypePassed {
    var double: Double = 0
    var int: Int = 0
    var int64: Int64 = 0
}

enum addType: Int {
    case EXPENSE = 1
    case INCOME = 2
    case TRANSFER = 3
}

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
    @IBOutlet weak var changeDateButton: UIBarButtonItem!

    var record: Record?

    var typePassedBack: String = ""

    var accountId: Int64 = 0
    var categoryId: Int64 = 0

    var type: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        if (type == addType.EXPENSE.rawValue) {
            navigationController?.navigationBar.tintColor = UIColor.red
            amountLabel.textColor = UIColor.red
        } else if (type == addType.INCOME.rawValue) {
            navigationController?.navigationBar.tintColor = UIColor.green
            amountLabel.textColor = UIColor.green
        } else if (type == addType.TRANSFER.rawValue) {
            navigationController?.navigationBar.tintColor = UIColor.blue
            amountLabel.isHidden = true
            categoryLabel.text = "Choose Account"
        }

        notesTextField.delegate = self

        if presentingViewController is NewAdditionTableViewController {
            let date = Date()

            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateStyle = .short

            let dateString = dayTimePeriodFormatter.string(from: date)

            changeDateButton.title = dateString
        }

        if let record = record {
            amountLabel.text = String(record.amount)
            accountLabel.text = RecordDB.instance.getAccount(id: record.accountId)
            categoryLabel.text = RecordDB.instance.getCategory(id: record.categoryId)

            let date = Date(timeIntervalSince1970: TimeInterval(record.time))

            let dayTimePeriodFormatter = DateFormatter()
            dayTimePeriodFormatter.dateStyle = .short

            let dateString = dayTimePeriodFormatter.string(from: date)

            changeDateButton.title = dateString

            accountId = record.accountId
            categoryId = record.categoryId
            /*            payeeLabel.text = record.payee ?? "Payee Not Specified"
             tagLabel.text = record.tag ?? "Tag Not Specified"
             notesTextField.text = record.notes*/
        }

        updateSaveButtonState()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func passNumberBack(_ caller: UIViewController, type: TypePassed) {
        if let _ = caller as? SelectAmountViewController {
            amountLabel.text = String(format: "%.2lf", type.double)

        } else if let _ = caller as? SelectTableViewController {
            if (typePassedBack == "ChooseAccount") {
                accountLabel.text = RecordDB.instance.getAccount(id: type.int64)
                accountId = type.int64
            } else {
                categoryLabel.text = RecordDB.instance.getCategory(id: type.int64)
                categoryId = type.int64
            }

        } else if let _ = caller as? SelectPayeeTableViewController {
            payeeLabel.text = payees[type.int]

        } else if let _ = caller as? SelectTagTableViewController {
            tagLabel.text = tags[type.int]
        } else if let _ = caller as? DatePickerViewController {

            let date = Date(timeIntervalSince1970: type.double)
            let formatter = DateFormatter()

            formatter.dateStyle = .short

            changeDateButton.title = formatter.string(from: date)
        }

        updateSaveButtonState()
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {

        if presentingViewController is NewAdditionTableViewController {
            dismiss(animated: true, completion: nil)
            print("In addrecord mode")
        }
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
            print (" in editing mode")
        }
        else {
            fatalError("The RecordViewController is not inside a navigation controller.")
        }
    }

    func checkTypePassedBack() {
        if (typePassedBack == "ChooseAccount") {

        }
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
            || (segue.identifier == "ChooseAmount")
            || (segue.identifier == "ChangeDate") {

            let popoverViewController = segue.destination

            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover

            popoverViewController.popoverPresentationController!.delegate = self
        }

        if let nextViewController = segue.destination as? UINavigationController {
            if let secondViewController = nextViewController.topViewController as? SelectTableViewController {
                secondViewController.selectionType = segue.identifier!
                typePassedBack = segue.identifier!

                secondViewController.delegate = self
            }
        } else if let secondViewController = segue.destination as? SelectPayeeTableViewController {
            secondViewController.delegate = self
        }  else if let secondViewController = segue.destination as? SelectTagTableViewController {
            secondViewController.delegate = self
        }  else if let secondViewController = segue.destination as? SelectAmountViewController {
            secondViewController.delegate = self
        }  else if let secondViewController = segue.destination as? DatePickerViewController {
            secondViewController.delegate = self
        } else {
            guard let button = sender as? UIBarButtonItem, button === saveButton else {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                return
            }

            let amount = Double(amountLabel.text!)!

            let formatter = DateFormatter()

            formatter.dateStyle = .short

            let time = formatter.date(from: changeDateButton.title!)?.timeIntervalSince1970.rounded()
            /*let payee = payeeLabel.text
             let tag = tagLabel.text
             let notes = notesTextField.text*/

            record = Record(categoryId: categoryId, amount: amount, accountId: accountId, time: Int64(time!), rowId: record?.rowId ?? 1/*, payee: payee, tag: tag, notes: notes*/)
        }
    }





    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }


    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.

        if (amountLabel.text == "Label") || (amountLabel.text == "0.0") || (accountLabel.text == "Choose Account") {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
}
