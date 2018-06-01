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
    weak var pageController: RecordsPageViewController?

    private var search: LRecordSearch?
    private var dataLoaded = false
    private var year: Int = 0
    private var month: Int = 0
    private var loader: DBLoader?
    private var loaderNew: DBLoader?
    private var workItem: DispatchWorkItem?
    private var accountBalances = LAccountBalances()
    private var balanceEndYear = 0
    private var balanceEndMonth = 0
    private var viewTimeInterval = 0
    private var viewSortMode = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = LTheme.Color.default_bgd_color
        //LLog.d("\(self)", "view did load")
        tableView.dataSource = self
        tableView.delegate = self

        setupBalanceHeader()
        refresh()
    }

    func refresh(delay: Double = 0) {
        viewTimeInterval = LPreferences.getRecordsViewTimeInterval()
        viewSortMode = LPreferences.getRecordsViewSortMode()
        imgHeader?.setImage(getOrderIcon(), for: .normal)

        if (dataLoaded) {
            if let item = workItem {
                item.cancel()
            }
            search = LPreferences.getRecordsSearchControls()
            workItem = DispatchWorkItem {
                //LLog.d("\(self)", "loading data")
                self.loaderNew = DBLoader(year: self.year, month: self.month, sort: self.viewSortMode,
                                          interval: self.viewTimeInterval, asc: LPreferences.getRecordsViewAscend(),
                                          search: self.search!)

                DispatchQueue.main.async(execute: {
                    self.accountBalances.scan()
                    self.loader = self.loaderNew

                    if (self.isViewLoaded) {
                        if self.loader!.getSectionCount() > 0 {
                            self.headerView!.isHidden = false

                            if let ss = self.search {
                                if ss.all && ss.allValue && ss.allTime {
                                    self.labelBalance?.isHidden = false
                                } else {
                                    self.labelBalance?.isHidden = true
                                }
                            }

                            var income: Double = 0
                            var expense: Double = 0
                            var balance: Double = 0
                            for ii in 0..<self.loader!.getSectionCount() {
                                let s = self.loader!.getSection(ii)
                                income += s.income
                                expense += s.expense
                                balance += s.balance
                            }
                            income -= self.loader!.getInternalTransferAmount()
                            expense -= self.loader!.getInternalTransferAmount()

                            var txt: String
                            switch (self.viewTimeInterval) {
                            case RecordsViewInterval.MONTHLY.rawValue:
                                let fmt = DateFormatter()
                                fmt.dateFormat = "MM"
                                txt =  fmt.monthSymbols[self.month]
                                if self.month > 0 {
                                    self.balanceEndMonth = self.month - 1
                                    self.balanceEndYear = self.year
                                } else {
                                    self.balanceEndMonth = 11
                                    self.balanceEndYear = self.year - 1
                                }
                            case RecordsViewInterval.ANNUALLY.rawValue:
                                txt = String(self.year)
                                self.balanceEndYear = self.year - 1
                                self.balanceEndMonth = 11
                            default:
                                txt = NSLocalizedString("Balance", comment: "")
                            }

                            if self.viewTimeInterval != RecordsViewInterval.ALL_TIME.rawValue {
                                if (self.search!.all) {
                                    balance += self.accountBalances.getBalance(year: self.balanceEndYear, month: self.balanceEndMonth)
                                } else {
                                    if (self.search!.accounts.isEmpty) {
                                        balance += self.accountBalances.getBalance(year: self.balanceEndYear, month: self.balanceEndMonth)
                                    } else {
                                        balance += self.accountBalances.getBalance(accountIds: self.search!.accounts,
                                                                                   year: self.balanceEndYear, month: self.balanceEndMonth)
                                    }
                                }
                            }

                            self.imgHeader?.setImage(self.getOrderIcon(), for: .normal)
                            self.btnHeader?.setTitle(txt, for: .normal)
                            //self.btnHeader?.sizeToFit()

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

    private var imgHeader: UIButton?
    private var btnHeader: UIButton?
    private var labelBalance: UILabel?
    private var labelIncome: UILabel?
    private var labelExpense: UILabel?

    private func setupBalanceHeader() {
        let (_, _, b, i, e, imgBtn, btn) = createHeader(view: headerView)
        imgHeader = imgBtn
        btnHeader = btn
        labelExpense = e
        labelIncome = i
        labelBalance = b

        //tableView.tableHeaderView = view
        tableView.tableFooterView = UIView()
    }

    private func getOrderIcon() -> UIImage {
        if LPreferences.getRecordsViewAscend() {
            return #imageLiteral(resourceName: "ic_action_expand").withRenderingMode(.alwaysOriginal)
        } else {
            return #imageLiteral(resourceName: "ic_action_collapse").withRenderingMode(.alwaysOriginal)
        }
    }

    @objc func onOrderClick() {
        LPreferences.setRecordsViewAscend(!LPreferences.getRecordsViewAscend())
        pageController?.notifyToUpdateAllPages()
    }

    private func createHeader(view: UIView? = nil)
        -> (view: UIView, txtLabel: UILabel?, balanceLabel: UILabel, incomeLabel: UILabel, expenseLabel: UILabel, btn: UIButton?, imgBtn: UIButton?)
    {
        var hView: UIView
        if (view == nil) {
            hView = HorizontalLayout(height: 25)
            hView.backgroundColor = LTheme.Color.section_header_bgd_color
        } else {
            hView = view!
            hView.backgroundColor = LTheme.Color.balance_header_bgd_color
        }

        let fontsize: CGFloat = LTheme.Dimension.balance_header_font_size

        var btn: UIButton?
        var imgBtn: UIButton?
        var labelHeader: UILabel?
        if (view != nil) {
            imgBtn = UIButton(frame: CGRect(x: 0, y: 0, width: LTheme.Dimension.balance_header_left_margin,
                                            height: LTheme.Dimension.balance_header_left_margin))
            imgBtn!.addTarget(self, action: #selector(self.onOrderClick), for: .touchUpInside)
            imgBtn!.setImage(getOrderIcon(), for: .normal)
            imgBtn!.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)

            btn = UIButton(frame: CGRect(x: 1, y: 0, width: 100, height: 25))
            btn?.contentHorizontalAlignment = .left
            btn!.addTarget(self, action: #selector(self.onOrderClick), for: .touchUpInside)
            btn!.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontsize)
            btn!.setTitleColor(UIColor.black, for: .normal)
            btn!.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
        } else {
            labelHeader = UILabel(frame: CGRect(x: 1, y: 0, width: 100, height: 25))
            labelHeader!.layoutMargins = UIEdgeInsetsMake(0, LTheme.Dimension.balance_header_left_margin, 0, 0)
            //labelHeader.font = labelHeader.font.withSize(fontsize)
            labelHeader!.font = UIFont.boldSystemFont(ofSize: fontsize)
            labelHeader!.text = ""
            labelHeader!.sizeToFit()
        }

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

        if (view != nil) {
            hView.addSubview(imgBtn!)
            hView.addSubview(btn!)
        } else {
            hView.addSubview(labelHeader!)
        }
        //hView.addSubview(spacer)
        hView.addSubview(labelBalance)
        hView.addSubview(pl)
        hView.addSubview(labelIncome)
        hView.addSubview(labelExpense)
        hView.addSubview(pr)

        return (hView, labelHeader, labelBalance, labelIncome, labelExpense, imgBtn, btn)
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        if let loader = loader {
            return loader.getSectionCount()
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = LTheme.Color.default_bgd_color
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loader!.getSection(section).rows
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sect = loader!.getSection(section)
        return (sect.rows == 0 || sect.show == false ) ? 0 : 25
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let (v, h, b, i, e, _, _) = createHeader()
        let sect = loader!.getSection(section)
        h!.text = sect.txt
        h!.sizeToFit()

        var balance: Double = 0
        if (viewSortMode == RecordsViewSortMode.ACCOUNT.rawValue) {
            balance = sect.balance + accountBalances.getBalance(accountId: sect.id, year: balanceEndYear, month: balanceEndMonth)
        } else {
            balance = sect.balance
        }
        b.textColor = (balance >= 0) ? LTheme.Color.base_green : LTheme.Color.base_red
        b.text = String(format: "%.2f", abs(balance))
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddViewController")
            as? AddViewController {

            var selectedRecord: LTransaction?
            selectedRecord = loader!.getRecord(section: indexPath.section, row: indexPath.row)
            if selectedRecord!.type == .TRANSFER_COPY {
                if let record = DBTransaction.instance.getTransfer(rid: selectedRecord!.rid, copy: false) {
                    selectedRecord = record
                } else {
                    nvc.isReadOnly = true
                }
            }

            if let record = selectedRecord {
                if record.type == .TRANSFER || record.type == .TRANSFER_COPY {
                    if (record.accountId2 <= 0) {
                        nvc.isReadOnly = true
                    }
                }
                nvc.record = record
                self.navigationController?.pushViewController(nvc, animated: true)
            }
        }
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
        /* no longer needed? refreshing upon DB data change anyway
        if let sourceViewController = sender.source as? AddTableViewController {
            navigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background
            refresh()
        }
         */
    }
}
