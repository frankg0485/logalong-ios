//
//  RecordsTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 3/6/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit
import os.log

class RecordsTableViewController: UITableViewController {

    enum sorts: Int {
        case NONE = 0
        case ACCOUNT = 1
        case CATEGORY = 2
    }

    var records = [LTransaction]()
    var sections: [LAccount] = [LAccount(id: 0, name: "All Records")]
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

    private var month: Int = 0
    private var year: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBalanceHeader()

        records = DBTransaction.instance.getAll(sortBy: sortCounter, timeAsc: timeCounterAsc)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadData(year: Int, month: Int, sort: Int, interval: Int, search: LRecordSearch) {
        self.year = year
        self.month = month

        if (self.isViewLoaded) {
            let fmt = DateFormatter()
            fmt.dateFormat = "MM"
            labelHeader!.text =  fmt.monthSymbols[month]
            labelHeader!.sizeToFit()
        }
    }

    private var labelHeader: UILabel?
    private var labelBalance: UILabel?
    private var labelIncome: UILabel?
    private var labelExpense: UILabel?

    private func setupBalanceHeader() {
        let (view, h, b, i, e) = createHeader()
        labelHeader = h
        labelExpense = e
        labelIncome = i
        labelBalance = b

        tableView.tableHeaderView = view
        tableView.tableFooterView = UIView()
    }

    private func createHeader(txt: String = "", balance: Double = 0, income: Double = 0, expense: Double = 0)
        -> (view: UIView, txtLabel: UILabel, balanceLabel: UILabel, incomeLabel: UILabel, expenseLabel: UILabel)
    {
        let headerView = HorizontalLayout(height: 25)
        headerView.backgroundColor = LTheme.Color.balance_header_bgd_color
        //headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 25)

        let fontsize: CGFloat = 14
        let labelHeader = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        labelHeader.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0)
        labelHeader.font = labelHeader.font.withSize(fontsize)
        labelHeader.font = UIFont.boldSystemFont(ofSize: fontsize)
        let fmt = DateFormatter()
        fmt.dateFormat = "MM"
        labelHeader.text =  fmt.monthSymbols[month]
        labelHeader.sizeToFit()

        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 25))

        let labelBalance = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        labelBalance.font = labelBalance.font.withSize(fontsize)
        labelBalance.text = "123.45"
        //labelBalance.translatesAutoresizingMaskIntoConstraints = false
        labelBalance.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 2)
        labelBalance.sizeToFit()

        let pl = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 25))
        pl.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 2)
        pl.font = pl.font.withSize(fontsize)
        pl.text = "("
        pl.sizeToFit()

        let labelIncome = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        labelIncome.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 5)
        labelIncome.font = labelIncome.font.withSize(fontsize)
        labelIncome.text = "123.45"
        labelIncome.textColor = LTheme.Color.base_green
        labelIncome.sizeToFit()

        let labelExpense = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        labelExpense.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 2)
        labelExpense.font = labelExpense.font.withSize(fontsize)
        labelExpense.text = "123.45"
        labelExpense.textColor = LTheme.Color.base_red
        labelExpense.sizeToFit()

        let pr = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 25))
        pr.font = pr.font.withSize(fontsize)
        pr.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 10)
        pr.text = ")"
        pr.sizeToFit()

        headerView.addSubview(labelHeader)
        headerView.addSubview(spacer)
        headerView.addSubview(labelBalance)
        headerView.addSubview(pl)
        headerView.addSubview(labelIncome)
        headerView.addSubview(labelExpense)
        headerView.addSubview(pr)

        return (headerView, labelHeader, labelBalance, labelIncome, labelExpense)
    }

    @IBAction func timeButtonClicked(_ sender: UIBarButtonItem) {
        if (sender.title == "Time: Asc") {
            sender.title = "Time: Desc"

            timeCounterAsc = false
            records = DBTransaction.instance.getAll(sortBy: sortCounter, timeAsc: timeCounterAsc)


        } else {
            sender.title = "Time: Asc"

            timeCounterAsc = true
            records = DBTransaction.instance.getAll(sortBy: sortCounter, timeAsc: timeCounterAsc)
        }


        tableView.reloadData()
    }

    @IBAction func sortButtonClicked(_ sender: UIBarButtonItem) {
        if (sortCounter == sorts.CATEGORY.rawValue) {
            sortCounter = sorts.NONE.rawValue
            sender.title = sortOptions[sortCounter]

            records = DBTransaction.instance.getAll(sortBy: sortCounter, timeAsc: timeCounterAsc)

            sections.removeAll()
            sections.append(LAccount(id: 0, name: "All Records"))
        } else {
            sender.title = sortOptions[sortCounter + 1]
            sortCounter += 1

            if (sortCounter == sorts.ACCOUNT.rawValue) {
                records = DBTransaction.instance.getAll(sortBy: sortCounter, timeAsc: timeCounterAsc)

                sections.removeAll()
                for account in DBAccount.instance.getAll() {
                    sections.append(account)
                }

            } else {
                records = DBTransaction.instance.getAll(sortBy: sortCounter, timeAsc: timeCounterAsc)

                sections.removeAll()
                for category in DBCategory.instance.getAll() {
                    sections.append(LAccount(id: category.id, name: category.name))
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
                    DBTransaction.instance.update(record)

                    //tableView.reloadRows(at: [selectedIndexPath], with: .none)
                } else {
                    // Add a new record.
                    //let newIndexPath = IndexPath(row: records.count, section: 0)

                    //records.append(record)
                    //tableView.insertRows(at: [newIndexPath], with: .automatic)
                    var mRecord = record
                    DBTransaction.instance.add(&mRecord)
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
            return DBTransaction.instance.getAllByAccount(accountId: sections[section].id).count
        } else if (sortCounter == sorts.CATEGORY.rawValue) {
            return DBTransaction.instance.getAllByCategory(categoryId: sections[section].id).count
        } else {
            return records.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let (v, h, b, i, e) = createHeader()
        return v
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

        let record = records[indexPath.row + rowsInPreviousSections]

        cell.categoryLabel.text = DBCategory.instance.get(id: record.categoryId)?.name
        /*        cell.payeelabel.text = record.payee
         cell.tagLabel.text = record.tag*/

        switch (record.type) {
        case .INCOME:
            cell.amountLabel.textColor = LTheme.Color.base_green
        case .EXPENSE:
            cell.amountLabel.textColor = LTheme.Color.base_red
        default:
            cell.amountLabel.textColor = LTheme.Color.base_blue
        }
        cell.amountLabel.text = String(record.amount)

        let date = Date(milliseconds: record.timestamp)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateStyle = .medium
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
            DBTransaction.instance.remove(id: records.remove(at: indexPath.row).id)

            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

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

    func reloadTableView() {
        records = DBTransaction.instance.getAll(sortBy: sortCounter, timeAsc: timeCounterAsc)

        rowsInPreviousSections = 0
        rowsInSection = 0
        sectionCounter = 0

        tableView.reloadData()
    }
}
