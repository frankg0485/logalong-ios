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


    @IBOutlet weak var accountCell: UITableViewCell!
    @IBOutlet weak var categoryCell: UITableViewCell!
    @IBOutlet weak var payeeCell: UITableViewCell!
    @IBOutlet weak var tagCell: UITableViewCell!

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var payeeLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var changeDateButton: UIBarButtonItem!

    var record: LTransaction?

    var typePassedBack: String = ""

    var accountId: Int64 = 0
    var categoryId: Int64 = 0

    var type: Int = 0

    var cellsHaveBeenSelected: [Bool] = [false, false]

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
            payeeCell.isHidden = true
            tagCell.isHidden = true
            notesTextField.isHidden = true
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
            accountLabel.text = DBAccount.instance.get(id: record.accountId)?.name
            categoryLabel.text = DBCategory.instance.get(id: record.categoryId)?.name

            let date = Date(timeIntervalSince1970: TimeInterval(record.timestamp))

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

            if (self.type == addType.TRANSFER.rawValue) {
                if (cellsHaveBeenSelected[0] == true) {
                    accountLabel.text = DBAccount.instance.get(id: type.int64)?.name
                } else {
                    categoryLabel.text = DBCategory.instance.get(id: type.int64)?.name
                }
            } else {

                if (typePassedBack == "ChooseAccount") {
                    accountLabel.text = DBAccount.instance.get(id: type.int64)?.name
                    accountId = type.int64
                } else {
                    categoryLabel.text = DBCategory.instance.get(id: type.int64)?.name
                    categoryId = type.int64
                }
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


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (type == addType.TRANSFER.rawValue) {
            if (indexPath.row == 0) {
                cellsHaveBeenSelected[indexPath.row] = true
                cellsHaveBeenSelected[1] = false
            } else {
                cellsHaveBeenSelected[indexPath.row] = true
                cellsHaveBeenSelected[0] = false
            }

        }
    }
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
                if (type == addType.TRANSFER.rawValue) {
                    secondViewController.selectionType = "ChooseAccount"
                    typePassedBack = "ChooseAccount"
                } else {
                    secondViewController.selectionType = segue.identifier!
                    typePassedBack = segue.identifier!
                }

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
                LLog.d("\(self)", "The save button was not pressed, cancelling")
                return
            }

            if (type == addType.TRANSFER.rawValue) {

            } else {
                let amount = Double(amountLabel.text!)!

                let formatter = DateFormatter()

                formatter.dateStyle = .short

                let time = formatter.date(from: changeDateButton.title!)?.timeIntervalSince1970.rounded()
                let timeMs = time! * 1000
                /*let payee = payeeLabel.text
                 let tag = tagLabel.text
                 let notes = notesTextField.text*/

                //TODO: handle type, tag, vendor etc
                record = LTransaction(accountId: accountId, accountId2: 0,
                                      amount: amount, type: TransactionType.EXPENSE,
                                      categoryId: categoryId, tagId: 0, vendorId: 0, timestamp: Int64(timeMs))
            }

            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    private func updateSaveButtonState() {
        if (type == addType.TRANSFER.rawValue) {
            if (accountLabel.text == "Choose Account") || (categoryLabel.text == "Choose Account") || (accountLabel.text == categoryLabel.text) {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
            }
        } else {
            if (amountLabel.text == "Label") || (amountLabel.text == "0.0") || (accountLabel.text == "Choose Account") {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
            }
        }
    }
}
