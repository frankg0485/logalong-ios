//
//  SelectAccountTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/13/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit


class SelectTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, FPassCreationBackDelegate {

    @IBOutlet weak var okButton: UIButton!
    var myIndexPath: Int = 0
    var type: TypePassed = TypePassed(double: 0, int: 0, int64: 0)

    weak var delegate: FViewControllerDelegate?

    var selections: [NameWithId] = []
    var selectionType: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIdentifierAndPopulateArray()

        okButton.isEnabled = false
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {

        type.int64 = selections[myIndexPath].id

        delegate?.passNumberBack(self, type: type)
        dismiss(animated: true, completion: nil)
        /*       let myVC = storyboard?.instantiateViewController(withIdentifier: "testID") as! AddTableViewController
         myVC.intPassed = myIndexPath

         print("jsnfsjnfjfnkdjf: \(myVC.intPassed)")

         navigationController?.pushViewController(myVC, animated: true)
         dismiss(animated: true, completion: nil)
         popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)*/
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func passCreationBack(creation: NameWithId) {
        var account = LAccount(name: creation.name)
        DBAccount.instance.add(&account)
        _ = navigationController?.popViewController(animated: true)

        reloadTableView()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return selections.count
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        okButton.isEnabled = true
        myIndexPath = indexPath.row
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ChooseCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SelectTableViewCell else {
            fatalError("The dequeued cell is not an instance of SelectTableViewCell.")
        }

        let selection = selections[indexPath.row]

        cell.nameLabel.text = selection.name

        return cell
    }

    func checkIdentifierAndPopulateArray() {
        if (selectionType == "ChooseAccount") {
            for account in DBAccount.instance.getAll() {
                selections.append(NameWithId(name: account.name, id: account.id))
            }
        } else if (selectionType == "ChooseCategory") {
            for category in DBCategory.instance.getAll() {
                selections.append(NameWithId(name: category.name, id: category.id))
            }
        }
    }

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
        if (segue.identifier == "CreateAccount") || (segue.identifier == "CreateCategory") {
            let popoverViewController = segue.destination

            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover

            popoverViewController.popoverPresentationController!.delegate = self
        }

        if let secondViewController = segue.destination as? CreateViewController {
            secondViewController.delegate = self

            if (segue.identifier == "CreateAccount") {
                secondViewController.typeBeingAdded = "Account"
            } else {
                secondViewController.typeBeingAdded = "Category"
            }
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func reloadTableView() {
        checkIdentifierAndPopulateArray()

        tableView.reloadData()
    }
}
