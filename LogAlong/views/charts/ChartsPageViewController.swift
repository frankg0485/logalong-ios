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
        if let d = UIApplication.shared.delegate as? AppDelegate {
            d.shouldRotate = true
        }

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
        if let d = UIApplication.shared.delegate as? AppDelegate {
            d.shouldRotate = false
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        isVisible = true
        if isRefreshPending {
            refreshAll()
        }
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        isVisible = false
        super.viewDidDisappear(animated)
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
            searchControls.allTime && !searchControls.byValue {
            searchBtn.setImage(#imageLiteral(resourceName: "ic_action_search").withRenderingMode(.alwaysOriginal), for: .normal)
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
            var chartData = MyChartData(expenseCategories:[:], expenses: [], incomes: [])
            chartData.incomes = loader.records.annualIncomes
            chartData.expenses = loader.records.annualExpenses
            for sect in loader.records.sections {
                chartData.expenseCategories[sect.txt] = sect.expense
            }
            self.chartDataSet[year] = chartData

            DispatchQueue.main.async(execute: {
                self.progress.stopAnimating()
                self.refreshChart(chartData)
            })
        }
        DispatchQueue.global(qos: .userInteractive).async(execute: workItem!)
    }

    private func refreshChart(_ data: MyChartData) {
        pieVC.refresh(year: curYear, data: chartDataSet[curYear]?.expenseCategories)
        barVC.refresh(year: curYear, incomes: chartDataSet[curYear]?.incomes, expenses: chartDataSet[curYear]?.expenses)
    }

    @objc func onChartClick() {
        let nextVC = showingPieChart ? barVC : pieVC
        let direction: UIPageViewControllerNavigationDirection = showingPieChart ? .forward : .reverse
        setViewControllers([nextVC], direction: direction, animated: true, completion: { (complete) -> Void in
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

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    @objc func onCancelClick() {
        dismiss(animated: true, completion: nil)
    }

    @objc func onLeftClick() {
        if (curYear > startYear) {
            curYear -= 1
            if let data = chartDataSet[curYear] {
                refreshChart(data)
            } else {
                progress.startAnimating()
                reloadData(curYear)
            }
        }
    }

    @objc func onRightClick() {
        if (curYear < endYear) {
            curYear += 1
            if let data = chartDataSet[curYear] {
                refreshChart(data)
            } else {
                progress.startAnimating()
                reloadData(curYear)
            }
        }
    }

    private func setupButtons() {
        let BTN_W: CGFloat = LTheme.Dimension.bar_button_width
        let BTN_H: CGFloat = LTheme.Dimension.bar_button_height
        let BTN_S: CGFloat = 15 //LTheme.Dimension.bar_button_space
        let BAR_H: CGFloat = 30

        bottomBar = HorizontalLayout(height: BAR_H)

        chartBtn = UIButton(type: .system)
        chartBtn.addTarget(self, action: #selector(self.onChartClick), for: .touchUpInside)
        chartBtn.setImage(#imageLiteral(resourceName: "chart_light").withRenderingMode(.alwaysOriginal), for: .normal)
        chartBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        chartBtn.imageEdgeInsets = UIEdgeInsetsMake(0, BTN_S, 0, 0)

        searchBtn = UIButton(type: .system)
        searchBtn.addTarget(self, action: #selector(self.onSearchClick), for: .touchUpInside)
        searchBtn.setImage(#imageLiteral(resourceName: "ic_action_search").withRenderingMode(.alwaysOriginal), for: .normal)
        searchBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, BTN_S, 0, 0)

        let leftBtn = UIButton(type: .system)
        leftBtn.addTarget(self, action: #selector(self.onLeftClick), for: .touchUpInside)
        leftBtn.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, BTN_S)

        let rightBtn = UIButton(type: .system)
        rightBtn.addTarget(self, action: #selector(self.onRightClick), for: .touchUpInside)
        rightBtn.setImage(#imageLiteral(resourceName: "ic_action_right").withRenderingMode(.alwaysOriginal), for: .normal)
        rightBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, BTN_S)

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
        cancelBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, BTN_S)
        view.addSubview(cancelBtn)

        // apply layout constraints after veiw has been added to hierarchy
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: bottomBar, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBar, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBar, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBar, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: BAR_H).isActive = true

        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.topMargin, multiplier: 1.0, constant: 5).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: BTN_W + BTN_S).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: BTN_H).isActive = true

        // progress indicator
        progress = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(progress)
        //progress.center = view.convert(view.center, from:view.superview)
        progress.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: progress, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: progress, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: -20).isActive = true
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
