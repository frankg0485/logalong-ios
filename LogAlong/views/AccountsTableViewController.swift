//
//  AccountsTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/11/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class AccountsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, FPassCreationBackDelegate {

    var accounts: [LAccount] = []
    var name: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem

        accounts = DBAccount.instance.getAll()

        //        tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func shareButtonClicked(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? AccountsTableViewCell {
            name = cell.nameLabel.text!
        }

        presentShareView()
    }

    func presentShareView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ShareAccount") as! ShareAccountViewController

        controller.accountName = name
        controller.modalPresentationStyle = UIModalPresentationStyle.popover
        controller.popoverPresentationController?.delegate = self
        controller.preferredContentSize = CGSize(width: 375, height: 216)

        let popoverPresentationController = controller.popoverPresentationController

        // result is an optional (but should not be nil if modalPresentationStyle is popover)
        if let _popoverPresentationController = popoverPresentationController {
            // set the view from which to pop up
            _popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
            _popoverPresentationController.sourceView = self.view;
            _popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            // present (id iPhone it is a modal automatic full screen)

            self.present(controller, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = LTheme.Color.row_released_color
        cell.layer.borderWidth = 1
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return accounts.count
    }



    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AccountCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AccountsTableViewCell else {
            fatalError("The dequeued cell is not an instance of AccountsTableViewCell.")
        }

        let account = accounts[indexPath.row]

        cell.nameLabel.text = account.name
        cell.shareButton.setImage(#imageLiteral(resourceName: "ic_action_share").withRenderingMode(.alwaysOriginal), for: .normal)

        return cell
    }


    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            DBAccount.instance.remove(id: accounts.remove(at: indexPath.row).id)

            tableView.deleteRows(at: [indexPath], with: .fade)

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }


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

        switch (segue.identifier ?? "") {

        case "ShowDetail":
            guard let accountDetailViewController = segue.destination as? CreateViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedAccountCell = sender as? AccountsTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tableView.indexPath(for: selectedAccountCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedAccount = accounts[indexPath.row]
            accountDetailViewController.creation = NameWithId(name: selectedAccount.name, id: selectedAccount.id)

        case "CreateAccount":

            let popoverViewController = segue.destination

            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover

            popoverViewController.popoverPresentationController!.delegate = self

        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")


        }

        if let secondViewController = segue.destination as? CreateViewController {
            secondViewController.delegate = self
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }


    func passCreationBack(creation: NameWithId) {
        if let _ = tableView.indexPathForSelectedRow {
            DBAccount.instance.update(LAccount(id: creation.id, name: creation.name))
        } else {
            var account = LAccount(name: creation.name)
            DBAccount.instance.add(&account)
            LJournal.instance.addAccount(account.id)
        }

        reloadTableView()
    }

    func reloadTableView() {
        accounts = DBAccount.instance.getAll()

        tableView.reloadData()
    }

}
