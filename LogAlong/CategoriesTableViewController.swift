//
//  CategoriesTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/11/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    var categories: [String?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem

        categories = RecordDB.instance.getCategories()

        tableView.tableFooterView = UIView()

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

        cell.nameLabel.text = category

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
            categories.remove(at: indexPath.row)
            RecordDB.instance.removeCategory(id: Int64(indexPath.row))

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
            guard let categoryDetailViewController = segue.destination as? CreateCategoryViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedCategoryCell = sender as? CategoriesTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tableView.indexPath(for: selectedCategoryCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedCategory = categories[indexPath.row]
            categoryDetailViewController.category = selectedCategory

        case "CreateCategory":

            let popoverViewController = segue.destination

            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover

            popoverViewController.popoverPresentationController!.delegate = self

        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
            
        }

    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    @IBAction func unwindToCategoryList(sender: UIStoryboardSegue) {

    
        if let sourceViewController = sender.source as? CreateCategoryViewController, let category = sourceViewController.category {

            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                categories[selectedIndexPath.row] = category
                RecordDB.instance.updateCategory(id: Int64(selectedIndexPath.row + 1), newName: category)
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: categories.count, section: 0)
                categories.append(category)
                tableView.insertRows(at: [newIndexPath], with: .automatic)

                RecordDB.instance.addCategory(name: category)
            }

        }
        
    }
    
    
}
