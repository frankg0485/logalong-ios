//
//  ChartsPageViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 2/7/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class ChartsPageViewController: UIPageViewController/*, UIPageViewControllerDataSource, UIPageViewControllerDelegate*/,
UIPopoverPresentationControllerDelegate {

    private struct MyChartData {
        var expenseCategories: Dictionary<String, Double>
        var expenses: [Double]
        var incomes: [Double]
    }

    var pieVC: PieChartViewController!
    var barVC: BarChartViewController!
    var progress: UIActivityIndicatorView!
    var chartBtn: UIButton!
    var bottomBar: HorizontalLayout!
    var searchBtn: UIButton!
    var showingPieChart = true
    var isVisible = false
    var isRefreshPending = false

    private var searchControls: LRecordSearch = LPreferences.getRecordsSearchControls()
    private var workItem: DispatchWorkItem?
    private var chartDataSet = Dictionary<Int, MyChartData>()
    private var startYear: Int = 2018
    private var endYear: Int = 2018
    private var curYear: Int = 2018

    override func viewDidLoad() {
        super.viewDidLoad()
        LA.lockOrientation(.landscape)

        setupViewControllers()
        setViewControllers([pieVC!], direction: .forward, animated: true, completion: nil)
        showingPieChart = true

        setupButtons()

        LBroadcast.register(LBroadcast.ACTION_UI_DB_DATA_CHANGED,
                            cb: #selector(self.dbDataChanged),
                            listener: self)
        LBroadcast.register(LBroadcast.ACTION_UI_DB_SEARCH_CHANGED,
                            cb: #selector(self.dbSearchChanged),
                            listener: self)
        setSearchButtonImage()

        isRefreshPending = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LA.lockOrientation(.portrait, andRotateTo: .portrait)

        UIApplication.shared.isStatusBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        isVisible = true
        if isRefreshPending {
            refreshAll()
        }
        super.viewDidAppear(animated)
        LA.lockOrientation(.landscape)
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }

    override func viewDidDisappear(_ animated: Bool) {
        isVisible = false
        super.viewDidDisappear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isStatusBarHidden = true
    }

    @objc func dbDataChanged(notification: Notification) -> Void {
        refreshAll()
    }

    @objc func dbSearchChanged(notification: Notification) -> Void {
        refreshAll()
        setSearchButtonImage()
    }

    private func setSearchButtonImage() {
        if (searchControls.all || (searchControls.accounts.isEmpty && searchControls.categories.isEmpty &&
            searchControls.vendors.isEmpty && searchControls.tags.isEmpty)) &&
            searchControls.allTime && searchControls.allValue {
            searchBtn.setImage(#imageLiteral(resourceName: "ic_action_search_dark").withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            searchBtn.setImage(#imageLiteral(resourceName: "ic_action_search_enabled").withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }

    private func refreshAll() {
        if isVisible {
            isRefreshPending = false
            progress.startAnimating()
            //LLog.d("\(self)", "loading data")

            chartDataSet.removeAll()
            searchControls = LPreferences.getRecordsSearchControls()

            let loader = DBLoader(search: searchControls)
            let (startMs, endMs) = loader.getStartEndTime()
            let (y1, _, _) = LA.ymd(milliseconds: startMs)
            let (y2, _, _) = LA.ymd(milliseconds: endMs)
            startYear = y1
            endYear = y2
            if (curYear < startYear || curYear > endYear) {
                curYear = endYear
            }
            reloadData(curYear)
        } else {
            isRefreshPending = true
        }
    }

    private func reloadData(_ year: Int) {
        if let work = workItem {
            work.cancel()
        }
        workItem = DispatchWorkItem {
            let loader = DBLoader(year: year, month: 0, sort: RecordsViewSortMode.CATEGORY.rawValue,
                                   interval: RecordsViewInterval.ANNUALLY.rawValue, asc: true, search: self.searchControls)
            if loader.getSectionCount() > 0 {
                var chartData = MyChartData(expenseCategories:[:], expenses: [], incomes: [])
                chartData.incomes = loader.records.annualIncomes
                chartData.expenses = loader.records.annualExpenses
                for sect in loader.records.sections {
                    chartData.expenseCategories[sect.txt] = sect.expense
                }
                self.chartDataSet[year] = chartData
            }
            DispatchQueue.main.async(execute: {
                self.progress.stopAnimating()
                self.refreshChart()
            })
        }
        DispatchQueue.global(qos: .userInteractive).async(execute: workItem!)
    }

    private func refreshChart() {
        pieVC.refresh(year: curYear, data: chartDataSet[curYear]?.expenseCategories)
        barVC.refresh(year: curYear, incomes: chartDataSet[curYear]?.incomes, expenses: chartDataSet[curYear]?.expenses)
    }

    @objc func onChartClick() {
        let nextVC = showingPieChart ? barVC : pieVC
        let direction: UIPageViewController.NavigationDirection = showingPieChart ? .forward : .reverse
        setViewControllers([nextVC!], direction: direction, animated: true, completion: { (complete) -> Void in
            if (complete) {
                self.showingPieChart = !self.showingPieChart
                if self.showingPieChart {
                    self.chartBtn.setImage(#imageLiteral(resourceName: "chart_light").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    self.chartBtn.setImage(#imageLiteral(resourceName: "pie_chart_light").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                self.bottomBar.refresh()
            }
        })
    }

    @objc func onSearchClick() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController")

        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect =
            CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 22, width: 0, height: 0)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        vc.popoverPresentationController!.delegate = self

        self.present(vc, animated: true, completion: nil)
    }

    // this is required for iOS8.3 and later
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    @objc func onCancelClick() {
        dismiss(animated: true, completion: nil)
    }

    @objc func onLeftClick() {
        if (curYear > startYear) {
            curYear -= 1
            if let _ = chartDataSet[curYear] {
                refreshChart()
            } else {
                progress.startAnimating()
                reloadData(curYear)
            }
        }
    }

    @objc func onRightClick() {
        if (curYear < endYear) {
            curYear += 1
            if let _ = chartDataSet[curYear] {
                refreshChart()
            } else {
                progress.startAnimating()
                reloadData(curYear)
            }
        }
    }

    private func setupButtons() {
        let BTN_W: CGFloat = LTheme.Dimension.bar_button_width
        let BTN_H: CGFloat = LTheme.Dimension.bar_button_height
        let BTN_S_W: CGFloat = 20 //LTheme.Dimension.bar_button_space
        let BTN_S_H: CGFloat = 10 //LTheme.Dimension.bar_button_space
        let BAR_H: CGFloat = BTN_H + 2 * BTN_S_H

        bottomBar = HorizontalLayout(height: BAR_H)

        chartBtn = UIButton(type: .system)
        chartBtn.addTarget(self, action: #selector(self.onChartClick), for: .touchUpInside)
        chartBtn.setImage(#imageLiteral(resourceName: "chart_light").withRenderingMode(.alwaysOriginal), for: .normal)
        chartBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S_W + 10, height: BAR_H)
        chartBtn.imageEdgeInsets = UIEdgeInsets(top: BTN_S_H, left: 10, bottom: BTN_S_H, right: BTN_S_W)

        searchBtn = UIButton(type: .system)
        searchBtn.addTarget(self, action: #selector(self.onSearchClick), for: .touchUpInside)
        searchBtn.setImage(#imageLiteral(resourceName: "ic_action_search_dark").withRenderingMode(.alwaysOriginal), for: .normal)
        searchBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + 2 * BTN_S_W, height: BAR_H)
        searchBtn.imageEdgeInsets = UIEdgeInsets(top: BTN_S_H, left: BTN_S_W, bottom: BTN_S_H, right: BTN_S_W)

        let leftBtn = UIButton(type: .system)
        leftBtn.addTarget(self, action: #selector(self.onLeftClick), for: .touchUpInside)
        leftBtn.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + 2 * BTN_S_W, height: BAR_H)
        leftBtn.imageEdgeInsets = UIEdgeInsets(top: BTN_S_H, left: BTN_S_W, bottom: BTN_S_H, right: BTN_S_W)

        let rightBtn = UIButton(type: .system)
        rightBtn.addTarget(self, action: #selector(self.onRightClick), for: .touchUpInside)
        rightBtn.setImage(#imageLiteral(resourceName: "ic_action_right").withRenderingMode(.alwaysOriginal), for: .normal)
        rightBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + 2 * BTN_S_W, height: BAR_H)
        rightBtn.imageEdgeInsets = UIEdgeInsets(top: BTN_S_H, left: BTN_S_W, bottom: BTN_S_H, right: BTN_S_W)

        let spacer = UIView(frame: CGRect(x: 1, y: 0, width: 0, height: BTN_H))

        bottomBar.addSubview(chartBtn)
        bottomBar.addSubview(searchBtn)
        bottomBar.addSubview(spacer)
        bottomBar.addSubview(leftBtn)
        bottomBar.addSubview(rightBtn)
        view.addSubview(bottomBar)

        let cancelBtn = UIButton(type: .system)
        cancelBtn.addTarget(self, action: #selector(self.onCancelClick), for: .touchUpInside)
        cancelBtn.setImage(#imageLiteral(resourceName: "ic_action_cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        cancelBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + 2 * BTN_S_W, height: BAR_H)
        cancelBtn.imageEdgeInsets = UIEdgeInsets(top: BTN_S_H, left: BTN_S_W, bottom: BTN_S_H, right: BTN_S_W)
        view.addSubview(cancelBtn)

        // apply layout constraints after veiw has been added to hierarchy
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: bottomBar!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 5).isActive = true
        NSLayoutConstraint(item: bottomBar!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBar!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBar!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: BAR_H).isActive = true

        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view, attribute: NSLayoutConstraint.Attribute.topMargin, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: BTN_W + 2 * BTN_S_W).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: BAR_H).isActive = true

        // progress indicator
        progress = UIActivityIndicatorView(style: .gray)
        view.addSubview(progress)
        //progress.center = view.convert(view.center, from:view.superview)
        progress.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: progress!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: progress!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: -20).isActive = true
        //NSLayoutConstraint(item: progress, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal,
        //                   toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80).isActive = true
        //NSLayoutConstraint(item: progress, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
        //                   toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80).isActive = true
        //progress.transform = CGAffineTransform(scaleX: 2, y: 2)
    }

    private func setupViewControllers() {
        pieVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PieChartViewController") as? PieChartViewController
        //barVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PieChartViewController") as? PieChartViewController
        barVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BarChartViewController") as? BarChartViewController
    }

    //@objc func canRotate() -> Void {}
}
