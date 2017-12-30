//
//  RecordsPageViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 12/25/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class RecordsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    enum ViewInterval: Int {
        case MONTHLY = 10
        case ANNUALLY = 20
        case ALL_TIME = 30
    }

    private var viewL: RecordsTableViewController?
    private var viewM: RecordsTableViewController?
    private var viewR: RecordsTableViewController?
    private var viewNext: RecordsTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

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
        viewNext = pendingViewControllers[0] as? RecordsTableViewController
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
                LLog.e("\(self)", "unexpected state: prev: \(previousViewControllers[0]), next: \(viewNext)")
            }
            viewM = viewNext
        }
    }

    private func getTitle() -> String {
        switch (LPreferences.getRecordsViewTimeInterval()) {
        case ViewInterval.ALL_TIME.rawValue:
            return NSLocalizedString("all", comment: "")
        case ViewInterval.ANNUALLY.rawValue:
            return NSLocalizedString("annually", comment: "")
        default:
            return NSLocalizedString("monthly", comment: "")
        }
    }
    private func setupNavigationBarItems() {
        let BTN_W: CGFloat = 30
        let BTN_H: CGFloat = 25
        //navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.title = getTitle()

        let sortBtn = UIButton(type: .custom)
        sortBtn.setImage(#imageLiteral(resourceName: "ic_menu_sort_by_size").withRenderingMode(.alwaysOriginal), for: .normal)
        sortBtn.setSize(w: BTN_W, h: BTN_H)
        sortBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5)

        let searchBtn = UIButton(type: .system)
        searchBtn.setImage(#imageLiteral(resourceName: "ic_action_search").withRenderingMode(.alwaysOriginal), for: .normal)
        searchBtn.setSize(w: BTN_W, h: BTN_H)
        searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)

        let rightBtn = UIButton(type: .system)
        rightBtn.setImage(#imageLiteral(resourceName: "ic_action_right").withRenderingMode(.alwaysOriginal), for: .normal)
        rightBtn.setSize(w: BTN_W, h: BTN_H)
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)

        let leftBtn = UIButton(type: .system)
        leftBtn.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        leftBtn.setSize(w: BTN_W, h: BTN_H)
        leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5)

        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: sortBtn), UIBarButtonItem(customView: searchBtn)]
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightBtn), UIBarButtonItem(customView: leftBtn)]

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = LTheme.Color.records_view_top_bar_background
        navigationController?.navigationBar.barStyle = .black
    }

    private func setupViewControllers() {
        viewL = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordsTableViewController") as? RecordsTableViewController
        viewM = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordsTableViewController") as? RecordsTableViewController
        viewR = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordsTableViewController") as? RecordsTableViewController


        let (year, month, day) = LA.ymd()

        navYear = year
        navMonth = month
        viewM!.loadData(year: 0, month: navMonth)
    }

    private var navYear = 0
    private var navMonth = 0
    private var startMonth = 1
    private var endMonth = 11

    private func getLeft() -> Bool {
        var ret = false
        if (navMonth > startMonth) {
            viewL!.loadData(year: 0, month: LA.monthChange(navMonth, by: -1))
            ret = true
        }
        return ret
    }

    private func getRight() -> Bool {
        var ret = false
        if (navMonth < endMonth) {
            viewR!.loadData(year: 0, month: LA.monthChange(navMonth, by: +1))
            ret = true
        }
        return ret
    }

    private func navLeft() {
        navMonth = LA.monthChange(navMonth, by: +1)
    }

    private func navRight() {
        navMonth = LA.monthChange(navMonth, by: -1)
    }
}
