//
//  RecordsPageViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 12/25/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class RecordsPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    enum ViewInterval: Int {
        case MONTHLY = 10
        case ANNUALLY = 20
        case ALL_TIME = 30
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self

        setupNavigationBarItems()

        setViewControllers([myViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vi = myViewControllers.index(of: viewController) else {
            return nil
        }

        let prev = vi - 1
        guard  prev >= 0 else {
            return myViewControllers.last
        }

        guard myViewControllers.count > prev else {
            return nil
        }

        return myViewControllers[prev]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vi = myViewControllers.index(of: viewController) else {
            return nil
        }

        let next = vi + 1

        guard next != myViewControllers.count else {
            return myViewControllers.first
        }

        guard myViewControllers.count > next else {
            return nil
        }

        return myViewControllers[next]
    }

    private lazy var myViewControllers: [UIViewController] = {
        return [newTableViewController(),
                newTableViewController(),
                newTableViewController()]
    }()

    private func newTableViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecordsTableViewController")
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
}
