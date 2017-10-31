//
//  RecordsTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 3/6/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit
import os.log

class RecordsTableViewController: UITableViewController {

    enum sorts: Int {
        case NONE = 0
        case ACCOUNT = 1
        case CATEGORY = 2
    }

    var records = [Record]()
    var sections: [Account] = [Account(id: 0, name: "All Records")]
    let sortOptions = ["Sort By:", "Sort By: Account", "Sort By: Category"]
    var sortCounter = 0 {
        didSet {
            rowsInPreviousSections = 0
            rowsInSection = 0
            sectionCounter = 0

        }
    }

    var timeCounterAsc = true {
        didSet {
            rowsInPreviousSections = 0
            rowsInSection = 0
            sectionCounter = 0

        }
    }

    var sectionCounter = 0
    var rowsInSection = 0
    var rowsInPreviousSections
        = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem

        /*while (true) {
         RecordDB.instance.removeRecord(id: 0, sortBy: sortCounter, timeAsc: timeCounterAsc)
         }*/

        records = RecordDB.instance.getRecords(sortBy: sortCounter, timeAsc: timeCounterAsc)

        tableView.tableFooterView = UIView()
        /*        if let savedRecords = loadRecords() {
         records += savedRecords
         }*/
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func timeButtonClicked(_ sender: UIBarButtonItem) {
        if (sender.title == "Time: Asc") {
            sender.title = "Time: Desc"

            timeCounterAsc = false
            records = RecordDB.instance.getRecords(sortBy: sortCounter, timeAsc: timeCounterAsc)


        } else {
            sender.title = "Time: Asc"

            timeCounterAsc = true
            records = RecordDB.instance.getRecords(sortBy: sortCounter, timeAsc: timeCounterAsc)
        }


        tableView.reloadData()
    }

    @IBAction func sortButtonClicked(_ sender: UIBarButtonItem) {
        if (sortCounter == sorts.CATEGORY.rawValue) {
            sortCounter = sorts.NONE.rawValue
            sender.title = sortOptions[sortCounter]

            records = RecordDB.instance.getRecords(sortBy: sortCounter, timeAsc: timeCounterAsc)

            sections.removeAll()
            sections.append(Account(id: 0, name: "All Records"))
        } else {
            sender.title = sortOptions[sortCounter + 1]
            sortCounter += 1

            if (sortCounter == sorts.ACCOUNT.rawValue) {
                records = RecordDB.instance.getRecords(sortBy: sortCounter, timeAsc: timeCounterAsc)

                sections.removeAll()
                for account in RecordDB.instance.getAccounts() {
                    sections.append(account)
                }

            } else {
                records = RecordDB.instance.getRecords(sortBy: sortCounter, timeAsc: timeCounterAsc)

                sections.removeAll()
                for category in RecordDB.instance.getCategories() {
                    sections.append(Account(id: category.id, name: category.name))
                }
            }
        }



        tableView.reloadData()
    }

    @IBAction func unwindToRecordList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddTableViewController {
            if let record = sourceViewController.record {

                if let _ = tableView.indexPathForSelectedRow {
                    // Update an existing record.
                    //records[selectedIndexPath.row] = record
                    /*print(sourceViewController.categoryId)
                     print(sourceViewController.accountId)*/
                    RecordDB.instance.updateRecord(id: record.rowId, newCategoryId: record.categoryId, newAccountId: record.accountId, newAmount: record.amount, newTime: record.time, newType: 0)


                    //tableView.reloadRows(at: [selectedIndexPath], with: .none)
                } else {
                    // Add a new record.
                    //let newIndexPath = IndexPath(row: records.count, section: 0)

                    //records.append(record)
                    //tableView.insertRows(at: [newIndexPath], with: .automatic)

                    RecordDB.instance.addRecord(catId: record.categoryId, accId: record.accountId, amount: record.amount, timeInMilliseconds: record.time)
                    _ = navigationController?.popViewController(animated: true)
                }

                reloadTableView()

            }
        }
    }

    // MARK: - Table view data source


    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        rowsInPreviousSections = 0
        rowsInSection = 0
        sectionCounter = 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //CHANGE THIS: USE ENUMERATIONS
        if (sortCounter == sorts.ACCOUNT.rawValue) {
            return RecordDB.instance.searchRecordsByAccount(accountId: sections[section].id).count
        } else if (sortCounter == sorts.CATEGORY.rawValue) {
            return RecordDB.instance.searchRecordsByCategory(categoryId: sections[section].id).count
        } else {
            return records.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "RecordsTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecordsTableViewCell else {
            fatalError("The dequeued cell is not an instance of RecordsTableViewCell.")

        }

        if (indexPath.row == 0) {
            sectionCounter += 1

            if (sectionCounter > 1) {
                rowsInPreviousSections += 1

            }
            rowsInPreviousSections += rowsInSection
            rowsInSection = 0
        } else {
            rowsInSection += 1
        }

        //print("asdfjalsdfkjasdlfkjasldkfjasldkfjasdf")
        let record = records[indexPath.row + rowsInPreviousSections]

        cell.accountLabel.text = RecordDB.instance.getAccount(id: record.accountId)
        cell.categoryLabel.text = RecordDB.instance.getCategory(id: record.categoryId)
        /*        cell.payeelabel.text = record.payee
         cell.tagLabel.text = record.tag*/
        cell.amountLabel.text = String(record.amount)

        let date = Date(timeIntervalSince1970: TimeInterval(record.time))

        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateStyle = .short

        let dateString = dayTimePeriodFormatter.string(from: date)

        cell.dateLabel.text = dateString


        return cell
    }



    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }



    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            RecordDB.instance.removeRecord(id: records.remove(at: indexPath.row).rowId)

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
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {

        case "ShowDetail":
            guard let recordDetailViewController = segue.destination as? AddTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedRecordCell = sender as? RecordsTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tableView.indexPath(for: selectedRecordCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedRecord = records[indexPath.row]
            recordDetailViewController.record = selectedRecord

        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }


    /*    private func loadSampleRecords() {
     guard let record1 = Record(category: "Kids: Piano", amount: 54, account: "Credit: Discover", payee: "Costco", tag: "Market America", notes: nil) else {
     fatalError("Unable to instantiate meal1")

     }

     guard let record2 = Record(category: "Eat Out", amount: 100, account: "Credit: Master", payee: "Chipotle", tag: "2016 Summer", notes: nil) else {
     fatalError("Unable to instantiate meal2")
     }

     guard let record3 = Record(category: "Grocery", amount: 68, account: "Cash", payee: "Walmart", tag: "2017 Summer", notes: nil) else {
     fatalError("Unable to instantiate meal3")
     }

     records += [record1, record2, record3]
     }
     */

    /*    private func saveRecords() {
     let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(records, toFile: Record.ArchiveURL.path)
     if isSuccessfulSave {
     os_log("Records successfully saved.", log: OSLog.default, type: .debug)
     } else {
     os_log("Failed to save records...", log: OSLog.default, type: .error)
     }
     }

     private func loadRecords() -> [Record]?  {
     return NSKeyedUnarchiver.unarchiveObject(withFile: Record.ArchiveURL.path) as? [Record]
     }

     */

    func reloadTableView() {
        records = RecordDB.instance.getRecords(sortBy: sortCounter, timeAsc: timeCounterAsc)

        rowsInPreviousSections = 0
        rowsInSection = 0
        sectionCounter = 0

        tableView.reloadData()
    }
}
