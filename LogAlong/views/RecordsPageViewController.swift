//
//  RecordsPageViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 12/25/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

enum RecordsViewInterval: Int {
    case MONTHLY = 10
    case ANNUALLY = 20
    case ALL_TIME = 30
}

enum RecordsViewSortMode: Int {
    case TIME = 10
    case CATEGORY = 20
    case ACCOUNT = 30
    case TAG = 40
    case VENDOR = 50
}

class RecordsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIPopoverPresentationControllerDelegate {

    private var viewL: RecordsViewController?
    private var viewM: RecordsViewController?
    private var viewR: RecordsViewController?
    private var viewNext: RecordsViewController?

    //TODO: search support
    var searchControls: LRecordSearch = LRecordSearch(from: 0, to: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        LBroadcast.register(LBroadcast.ACTION_UI_DB_DATA_CHANGED,
                            cb: #selector(self.dbDataChanged),
                            listener: self)

        setupNavigationControls()
        setupNavigationBarItems()
        setupViewControllers()

        setViewControllers([viewM!], direction: .forward, animated: true, completion: nil)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //LLog.d("\(self)", "get previous controller")
        return getLeft() ? viewL : nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //LLog.d("\(self)", "get next controller")
        return getRight() ? viewR : nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        //LLog.d("\(self)", "going to: \(pendingViewControllers) @ \(Date())")
        viewNext = pendingViewControllers[0] as? RecordsViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        //LLog.d("\(self)", "finish: \(finished) prev: \(previousViewControllers) completed: \(completed) @ \(Date())")
        if completed {
            if viewNext == viewL {
                viewL = viewR
                viewR = viewM
                navRight()
            } else if viewNext == viewR {
                viewR = viewL
                viewL = viewM
                navLeft()
            } else {
                LLog.e("\(self)", "unexpected state: prev: \(previousViewControllers[0]), next: \(String(describing: viewNext))")
            }
            viewM = viewNext
        }
    }

    @objc func dbDataChanged(notification: Notification) -> Void {
        LLog.d("\(self)", "db changed")
        setupNavigationControls()
    }

    private func nextViewInterval() -> RecordsViewInterval {
        switch (LPreferences.getRecordsViewTimeInterval()) {
        case RecordsViewInterval.ALL_TIME.rawValue:
            return RecordsViewInterval.MONTHLY
        case RecordsViewInterval.MONTHLY.rawValue:
            return RecordsViewInterval.ANNUALLY
        default:
            return RecordsViewInterval.ALL_TIME
        }
    }

    private func nextSortMode() -> RecordsViewSortMode {
        switch (LPreferences.getRecordsViewSortMode()) {
        case RecordsViewSortMode.ACCOUNT.rawValue:
            return RecordsViewSortMode.CATEGORY
        case RecordsViewSortMode.CATEGORY.rawValue:
            return RecordsViewSortMode.TAG
        case RecordsViewSortMode.TAG.rawValue:
            return RecordsViewSortMode.VENDOR
        case RecordsViewSortMode.VENDOR.rawValue:
            return RecordsViewSortMode.TIME
        default:
            return RecordsViewSortMode.ACCOUNT
        }
    }

    private func getTitle() -> String {
        switch (LPreferences.getRecordsViewTimeInterval()) {
        case RecordsViewInterval.ALL_TIME.rawValue:
            return NSLocalizedString("all", comment: "")
        case RecordsViewInterval.ANNUALLY.rawValue:
            return NSLocalizedString("annually", comment: "")
        default:
            return NSLocalizedString("monthly", comment: "")
        }
    }

    private func getSortIcon() -> UIImage {
        switch (LPreferences.getRecordsViewSortMode()) {
        case RecordsViewSortMode.ACCOUNT.rawValue:
            return #imageLiteral(resourceName: "ic_menu_sort_by_account").withRenderingMode(.alwaysOriginal)
        case RecordsViewSortMode.CATEGORY.rawValue:
            return #imageLiteral(resourceName: "ic_menu_sort_by_category").withRenderingMode(.alwaysOriginal)
        case RecordsViewSortMode.TAG.rawValue:
            return #imageLiteral(resourceName: "ic_menu_sort_by_tag").withRenderingMode(.alwaysOriginal)
        case RecordsViewSortMode.VENDOR.rawValue:
            return #imageLiteral(resourceName: "ic_menu_sort_by_payer").withRenderingMode(.alwaysOriginal)
        default:
            return #imageLiteral(resourceName: "ic_menu_sort_by_size").withRenderingMode(.alwaysOriginal)
        }
    }

    @objc func onTitleClick() {
        LPreferences.setRecordsViewTimeInterval(nextViewInterval().rawValue)
        titleBtn!.setTitle(getTitle(), for: .normal)

        setupNavigationControls()

        if let view = viewM {
            view.loadData(year: navYear, month: navMonth)
        }

        // reseting data source effectively flush the internal UIPageViewer page cache
        self.dataSource = nil
        self.dataSource = self
    }

    @objc func onSortClick() {
        LPreferences.setRecordsViewSortMode(nextSortMode().rawValue)
        sortBtn!.setImage(getSortIcon(), for: .normal)

        if let view = viewM {
            view.refresh()
        }
        if let view = viewL {
            view.refresh(delay: 0.5)
        }
        if let view = viewR {
            view.refresh(delay: 0.5)
        }
    }

    @objc func onChartClick() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChartsPageViewController")
            as? ChartsPageViewController {
            self.present(vc, animated: true, completion: nil)
        }
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

    private var titleBtn: UIButton?
    private var sortBtn: UIButton?
    private func setupNavigationBarItems() {
        let BTN_W: CGFloat = LTheme.Dimension.bar_button_width
        let BTN_H: CGFloat = LTheme.Dimension.bar_button_height
        let BTN_S: CGFloat = LTheme.Dimension.bar_button_space

        titleBtn = UIButton(type: .custom)
        titleBtn!.addTarget(self, action: #selector(self.onTitleClick), for: .touchUpInside)
        titleBtn!.setSize(w: 80, h: 30)
        titleBtn!.setTitle(getTitle(), for: .normal)
        navigationItem.titleView = titleBtn

        sortBtn = UIButton(type: .system)
        sortBtn?.addTarget(self, action: #selector(self.onSortClick), for: .touchUpInside)
        sortBtn!.setImage(getSortIcon(), for: .normal)
        sortBtn!.setSize(w: BTN_W + BTN_S, h: BTN_H)
        sortBtn!.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, BTN_S)

        let chartBtn = UIButton(type: .system)
        chartBtn.addTarget(self, action: #selector(self.onChartClick), for: .touchUpInside)
        chartBtn.setImage(#imageLiteral(resourceName: "pie_chart_dark").withRenderingMode(.alwaysOriginal), for: .normal)
        chartBtn.setSize(w: BTN_W - 2 + BTN_S, h: BTN_H - 2)
        chartBtn.imageEdgeInsets = UIEdgeInsetsMake(0, BTN_S, 0, 0)

        let searchBtn = UIButton(type: .system)
        searchBtn.addTarget(self, action: #selector(self.onSearchClick), for: .touchUpInside)
        searchBtn.setImage(#imageLiteral(resourceName: "ic_action_search").withRenderingMode(.alwaysOriginal), for: .normal)
        searchBtn.setSize(w: BTN_W, h: BTN_H)
        //searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, BTN_S, 0, 0)

        /*
         let rightBtn = UIButton(type: .system)
         rightBtn.setImage(#imageLiteral(resourceName: "ic_action_right").withRenderingMode(.alwaysOriginal), for: .normal)
         rightBtn.setSize(w: BTN_W, h: BTN_H)
         rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, BTN_S, 0, 0)

         let leftBtn = UIButton(type: .system)
         leftBtn.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
         leftBtn.setSize(w: BTN_W, h: BTN_H)
         leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, BTN_S)
         */

        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: sortBtn!), UIBarButtonItem(customView: chartBtn)]
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBtn)

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background
        navigationController?.navigationBar.barStyle = .black
    }

    private func setupViewControllers() {
        viewL = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordsViewController") as? RecordsViewController
        viewM = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordsViewController") as? RecordsViewController
        viewR = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordsViewController") as? RecordsViewController

        viewM!.loadData(year: navYear, month: navMonth)
    }

    private var navYear = -1
    private var navMonth = -1
    private var startYear = -1
    private var startMonth = -1
    private var endYear = -1
    private var endMonth = -1

    private func validNavYM(_ year: Int, _ month: Int) -> (year: Int, month: Int) {
        var y = year
        var m = month

        if (y < startYear) {
            y = startYear
            m = startMonth
        } else if (y > endYear) {
            y = endYear
            m = endMonth
        } else if (y == startYear) {
            if (m < startMonth) {
                m = startMonth
            }
        } else if ( y == endYear) {
            if ( m > endMonth) {
                m = endMonth
            }
        }
        return (y, m)
    }

    private func setupNavigationControls() {
        let loader = DBLoader(search: searchControls)
        let (startMs, endMs) = loader.getStartEndTime()
        let (y1, m1, _) = LA.ymd(milliseconds: startMs)
        let (y2, m2, _) = LA.ymd(milliseconds: endMs)

        startYear = y1
        startMonth = m1
        endYear = y2
        endMonth = m2

        if (navYear == -1 || navMonth == -1) {
            navYear =  endYear
            navMonth = endMonth
        }

        (navYear, navMonth) = validNavYM(navYear, navMonth)
    }

    private func nextYearMonth(_ by: Int) -> (year: Int, month: Int) {
        switch(LPreferences.getRecordsViewTimeInterval()) {
        case RecordsViewInterval.ALL_TIME.rawValue:
            return validNavYM(navYear, navMonth)
        case RecordsViewInterval.ANNUALLY.rawValue:
            var y = navYear + by
            if (y > endYear) {
                y = endYear
            }
            if (y < startYear) {
                y = startYear
            }
            return validNavYM(y, navMonth)
        default:
            var m = navMonth + by
            var y = navYear

            if (m < 0) {
                m = 11
                y -= 1
            } else if (m > 11) {
                m = 0
                y += 1
            }
            return validNavYM(y, m)
        }
    }

    private func getLeft() -> Bool {
        var ret = false
        let (y, m) = nextYearMonth(-1)
        if (y != navYear || m != navMonth) {
            viewL!.loadData(year: y, month: m)
            ret = true
        }
        return ret
    }

    private func getRight() -> Bool {
        var ret = false
        let (y, m) = nextYearMonth(+1)
        if (y != navYear || m != navMonth) {
            viewR!.loadData(year: y, month: m)
            ret = true
        }
        return ret
    }

    private func navLeft() {
        (navYear, navMonth) = nextYearMonth(+1)
        //LLog.d("\(self)","Y/M: \(navYear) : \(navMonth)")
    }

    private func navRight() {
        (navYear, navMonth) = nextYearMonth(-1)
        //LLog.d("\(self)","Y/M: \(navYear) : \(navMonth)")
    }
}
