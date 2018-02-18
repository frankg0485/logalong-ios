//
//  RecordsViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 1/7/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit
import os.log

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var headerView: HorizontalLayout!
    @IBOutlet weak var tableView: UITableView!

    private var dataLoaded = false
    private var year: Int = 0
    private var month: Int = 0
    private var loader: DBLoader?
    private var loaderNew: DBLoader?
    private var workItem: DispatchWorkItem?
    private var accountBalances = LAccountBalances()

    override func viewDidLoad() {
        super.viewDidLoad()
        //LLog.d("\(self)", "view did load")
        tableView.dataSource = self
        tableView.delegate = self

        setupBalanceHeader()
        refresh()
    }

    func refresh(delay: Double = 0) {
        if (dataLoaded) {
            if let item = workItem {
                item.cancel()
            }

            workItem = DispatchWorkItem {
                //LLog.d("\(self)", "loading data")
                self.loaderNew = DBLoader(year: self.year, month: self.month, sort: LPreferences.getRecordsViewSortMode(),
                                          interval: LPreferences.getRecordsViewTimeInterval(), asc: LPreferences.getRecordsViewAscend(),
                                          search: LPreferences.getRecordsSearchControls())
                self.accountBalances.scan()

                DispatchQueue.main.async(execute: {
                    self.loader = self.loaderNew

                    if (self.isViewLoaded) {
                        if self.loader!.getSectionCount() > 0 {
                            self.headerView!.isHidden = false

                            var income: Double = 0
                            var expense: Double = 0
                            var balance: Double = 0
                            for ii in 0..<self.loader!.getSectionCount() {
                                let s = self.loader!.getSection(ii)
                                income += s.income
                                expense += s.expense
                                balance += s.balance
                            }

                            var txt: String
                            switch (LPreferences.getRecordsViewTimeInterval()) {
                            case RecordsViewInterval.MONTHLY.rawValue:
                                let fmt = DateFormatter()
                                fmt.dateFormat = "MM"
                                txt =  fmt.monthSymbols[self.month]
                                balance = self.accountBalances.getBalance(year: self.year, month: self.month)
                            case RecordsViewInterval.ANNUALLY.rawValue:
                                txt = String(self.year)
                                balance = self.accountBalances.getBalance(year: self.year, month: 11)
                            default:
                                txt = NSLocalizedString("Balance", comment: "")
                            }

                            //TODO: check search mode and update balance header accordingly

                            self.labelHeader!.text = txt
                            self.labelHeader!.sizeToFit()

                            self.labelBalance!.textColor = balance >= 0 ? LTheme.Color.base_green : LTheme.Color.base_red
                            self.labelBalance!.text = String(format: "%.2f", abs(balance))
                            self.labelBalance!.sizeToFit()

                            self.labelIncome!.text = String(format: "%.2f", income)
                            self.labelIncome!.sizeToFit()
                            self.labelExpense!.text = String(format: "%.2f", expense)
                            self.labelExpense!.sizeToFit()

                            self.headerView!.refresh()
                        } else {
                            self.headerView!.isHidden = true
                        }
                        self.tableView.reloadData()
                    }
                })
            }
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + delay + 0.01, execute: workItem!)
        }
    }

    func loadData(year: Int, month: Int) {
        self.year = year
        self.month = month
        dataLoaded = true
        refresh()
    }

    private var labelHeader: UILabel?
    private var labelBalance: UILabel?
    private var labelIncome: UILabel?
    private var labelExpense: UILabel?

    private func setupBalanceHeader() {
        let (_, h, b, i, e) = createHeader(view: headerView)
        labelHeader = h
        labelExpense = e
        labelIncome = i
        labelBalance = b

        //tableView.tableHeaderView = view
        tableView.tableFooterView = UIView()
    }

    private func createHeader(view: UIView? = nil, txt: String = "", balance: Double = 0, income: Double = 0, expense: Double = 0)
        -> (view: UIView, txtLabel: UILabel, balanceLabel: UILabel, incomeLabel: UILabel, expenseLabel: UILabel)
    {
        var hView: UIView
        if (view == nil) {
            hView = HorizontalLayout(height: 25)
        } else {
            hView = view!
        }
        hView.backgroundColor = LTheme.Color.balance_header_bgd_color

        let fontsize: CGFloat = LTheme.Dimension.balance_header_font_size
        let labelHeader = UILabel(frame: CGRect(x: 1, y: 0, width: 100, height: 25))
        labelHeader.layoutMargins = UIEdgeInsetsMake(0, LTheme.Dimension.balance_header_left_margin, 0, 0)
        labelHeader.font = labelHeader.font.withSize(fontsize)
        labelHeader.font = UIFont.boldSystemFont(ofSize: fontsize)
        labelHeader.text = txt
        labelHeader.sizeToFit()

        //let spacer = UIView(frame: CGRect(x: 1, y: 0, width: 0, height: 25))

        let labelBalance = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        labelBalance.font = labelBalance.font.withSize(fontsize)
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
        labelIncome.textColor = LTheme.Color.base_green
        labelIncome.sizeToFit()

        let labelExpense = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        labelExpense.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 2)
        labelExpense.font = labelExpense.font.withSize(fontsize)
        labelExpense.textColor = LTheme.Color.base_red
        labelExpense.sizeToFit()

        let pr = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 25))
        pr.font = pr.font.withSize(fontsize)
        pr.layoutMargins = UIEdgeInsetsMake(0, 0, 0, LTheme.Dimension.balance_header_right_margin)
        pr.text = ")"
        pr.sizeToFit()

        hView.addSubview(labelHeader)
        //hView.addSubview(spacer)
        hView.addSubview(labelBalance)
        hView.addSubview(pl)
        hView.addSubview(labelIncome)
        hView.addSubview(labelExpense)
        hView.addSubview(pr)

        return (hView, labelHeader, labelBalance, labelIncome, labelExpense)
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        if let loader = loader {
            return loader.getSectionCount()
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loader!.getSection(section).rows
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sect = loader!.getSection(section)
        return (sect.rows == 0 || sect.show == false ) ? 0 : 25
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let (v, h, b, i, e) = createHeader()
        let sect = loader!.getSection(section)
        h.text = sect.txt
        h.sizeToFit()

        b.textColor = (sect.balance >= 0) ? LTheme.Color.base_green : LTheme.Color.base_red
        b.text = String(format: "%.2f", abs(sect.balance))
        b.sizeToFit()

        i.text = String(format: "%.2f", sect.income)
        i.sizeToFit()
        e.text = String(format: "%.2f", sect.expense)
        e.sizeToFit()

        return v
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsTableViewCell", for: indexPath) as! RecordsTableViewCell

        let record = loader!.getRecord(section: indexPath.section, row: indexPath.row)
        cell.showRecord(record)

        return cell
    }

    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            _ = DBTransaction.instance.remove(id: loader!.getRecord(section: indexPath.section, row: indexPath.row).id)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    // MARK: - Navigation
    @IBAction func unwindToRecordList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddTableViewController {
            navigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background
            refresh()
        }
    }

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

            let selectedRecord = loader!.getRecord(section: indexPath.section, row: indexPath.row)
            recordDetailViewController.record = selectedRecord

        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
}
