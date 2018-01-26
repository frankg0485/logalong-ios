//
//  CategoriesTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/11/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, FPassCreationBackDelegate {

    var categories: [LCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem

        categories = DBCategory.instance.getAll()

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

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = LTheme.Color.row_released_color
        cell.layer.borderWidth = 1
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
    }

    /* TODO:
    func passCreationBack(creation: NameWithId) {
        if let _ = tableView.indexPathForSelectedRow {
            DBCategory.instance.update(LCategory(id: creation.id, name: creation.name))
        } else {
            var category = LCategory(name: creation.name)
            DBCategory.instance.add(&category)
        }

        reloadTableView()
    }
*/
    func creationCallback(created: Bool) {
        if created {
            reloadTableView()
        }
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
        return categories.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CategoryCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CategoriesTableViewCell else {
            fatalError("The dequeued cell is not an instance of CategoriesTableViewCell.")
        }

        let category = categories[indexPath.row]

        cell.nameLabel.text = category.name

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
            DBCategory.instance.remove(id: categories.remove(at: indexPath.row).id)

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
            guard let categoryDetailViewController = segue.destination as? CreateViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedCategoryCell = sender as? CategoriesTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tableView.indexPath(for: selectedCategoryCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedCategory = categories[indexPath.row]
            //categoryDetailViewController.creation = NameWithId(name: selectedCategory.name, id: selectedCategory.id)

        case "CreateCategory":

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

    func reloadTableView() {
        categories = DBCategory.instance.getAll()

        tableView.reloadData()
    }
}
