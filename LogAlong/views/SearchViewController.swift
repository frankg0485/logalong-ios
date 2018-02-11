//
//  SearchViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 2/10/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var headerView: HorizontalLayout!
    @IBOutlet weak var showAllView: HorizontalLayout!
    @IBOutlet weak var allTimeView: HorizontalLayout!
    @IBOutlet weak var byValueView: HorizontalLayout!
    @IBOutlet weak var showAllGroupView: VerticalLayout!
    @IBOutlet weak var allTimeGroupView: VerticalLayout!
    @IBOutlet weak var showAllGroupHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var allTimeGroupHeightConstraint: NSLayoutConstraint!

    var allViewSwitch: UISwitch!
    var timeSwitch: UISwitch!
    var valueSwitch: UISwitch!

    var accountsBtn: UIButton!
    var categoriesBtn: UIButton!
    var vendorsBtn: UIButton!
    var tagsBtn: UIButton!

    var fromTimeBtn: UIButton!
    var toTimeBtn: UIButton!
    var filterByBtn: UIButton!

    let contentSizeBaseHeight: CGFloat = 200
    let showAllGroupHeight: CGFloat = 202
    let allTimeGroupHeight: CGFloat = 102

    override func viewDidLoad() {
        super.viewDidLoad()

        createHeader()
        createShowAll()
        createAllTime()
        createByValue()

        preferredContentSize.height = contentSizeBaseHeight + showAllGroupHeight + allTimeGroupHeight
    }

    @objc func onShowAllClick() {
        if allViewSwitch.isOn {
            showAllGroupView.isHidden = true
            showAllGroupHeightConstraint.constant = 0
        } else {
            showAllGroupView.isHidden = false
            showAllGroupHeightConstraint.constant = showAllGroupHeight
        }
        setContentHeight()
    }

    @objc func onAllTimeClick() {
        if timeSwitch.isOn {
            allTimeGroupView.isHidden = true
            allTimeGroupHeightConstraint.constant = 0
        } else {
            allTimeGroupView.isHidden = false
            allTimeGroupHeightConstraint.constant = allTimeGroupHeight
        }
        setContentHeight()
    }

    private func setContentHeight() {
        var height = contentSizeBaseHeight
        if !allViewSwitch.isOn {
            height += showAllGroupHeight
        }
        if !timeSwitch.isOn {
            height += allTimeGroupHeight
        }
        preferredContentSize.height = height
    }

    private func createHeader() {
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        headerView.addSubview(spacer)

        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 60, height: 30))
        label.text = NSLocalizedString("Select Records", comment: "")
        headerView.addSubview(label)

        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 25 + 10, height: 25))
        btn.setImage(#imageLiteral(resourceName: "ic_action_cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        headerView.addSubview(btn)

        headerView.backgroundColor = LTheme.Color.dialog_border_color
    }

    private func createShowAllEntry(_ str: String) -> (HorizontalLayout, UIButton) {
        let layout = HorizontalLayout(height: 45)
        layout.layoutMargins.top = 0
        layout.layoutMargins.bottom = 5

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        label.textColor = LTheme.Color.gray_text_color
        label.text = str
        layout.addSubview(label)

        let valueBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        valueBtn.setTitle(NSLocalizedString("all", comment: ""), for: .normal)
        valueBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        valueBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        valueBtn.contentHorizontalAlignment = .right
        layout.addSubview(valueBtn)

        return (layout, valueBtn)
    }

    private func createShowAll() {
        let hlayout = HorizontalLayout(height: 50)
        hlayout.layoutMargins.top = 0
        hlayout.layoutMargins.bottom = 0
        hlayout.layoutMargins.left = 0
        hlayout.layoutMargins.right = 0

        allViewSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        allViewSwitch.addTarget(self, action: #selector(onShowAllClick), for: .touchUpInside)
        hlayout.addSubview(allViewSwitch)

        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 100, height: 30))
        label.text = NSLocalizedString("Show All", comment: "")
        hlayout.addSubview(label)
        showAllView.addSubview(hlayout)

        var (layout, btn) = createShowAllEntry(NSLocalizedString("Accounts", comment: ""))
        accountsBtn = btn
        showAllGroupView.addSubview(layout)

        (layout, btn) = createShowAllEntry(NSLocalizedString("Categories", comment: ""))
        categoriesBtn = btn
        showAllGroupView.addSubview(layout)

        (layout, btn) = createShowAllEntry(NSLocalizedString("Payee/Payers", comment: ""))
        vendorsBtn = btn
        showAllGroupView.addSubview(layout)

        (layout, btn) = createShowAllEntry(NSLocalizedString("Tags", comment: ""))
        tagsBtn = btn
        showAllGroupView.addSubview(layout)
        showAllGroupHeightConstraint.constant = showAllGroupHeight
    }

    private func createAllTime() {
        let hlayout = HorizontalLayout(height: 50)
        hlayout.layoutMargins.top = 0
        hlayout.layoutMargins.bottom = 0
        hlayout.layoutMargins.left = 0
        hlayout.layoutMargins.right = 0

        timeSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        timeSwitch.addTarget(self, action: #selector(onAllTimeClick), for: .touchUpInside)
        hlayout.addSubview(timeSwitch)

        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 100, height: 30))
        label.text = NSLocalizedString("All Time", comment: "")
        hlayout.addSubview(label)
        allTimeView.addSubview(hlayout)

        let layout = HorizontalLayout(height: 45)
        layout.layoutMargins.top = 0
        layout.layoutMargins.bottom = 5

        fromTimeBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        fromTimeBtn.setTitle(NSLocalizedString("Jan 10, 2018", comment: ""), for: .normal)
        fromTimeBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        fromTimeBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        fromTimeBtn.contentHorizontalAlignment = .left
        layout.addSubview(fromTimeBtn)

        let toLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        toLabel.textColor = LTheme.Color.gray_text_color
        toLabel.text = NSLocalizedString("to", comment: "")
        layout.addSubview(toLabel)

        toTimeBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        toTimeBtn.setTitle(NSLocalizedString("Feb 10, 2018", comment: ""), for: .normal)
        toTimeBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        toTimeBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        toTimeBtn.contentHorizontalAlignment = .right
        layout.addSubview(toTimeBtn)
        allTimeGroupView.addSubview(layout)

        let (layout2, btn) = createShowAllEntry(NSLocalizedString("Filter by", comment: ""))
        filterByBtn = btn
        allTimeGroupView.addSubview(layout2)

        allTimeGroupHeightConstraint.constant = allTimeGroupHeight
    }

    private func createByValue() {
        let hlayout = HorizontalLayout(height: 50)
        hlayout.layoutMargins.top = 0
        hlayout.layoutMargins.bottom = 0
        hlayout.layoutMargins.left = 0
        hlayout.layoutMargins.right = 0

        let allViewSitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        hlayout.addSubview(allViewSitch)

        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 80, height: 30))
        label.text = NSLocalizedString("By Value", comment: "")
        hlayout.addSubview(label)

        let valueBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 30))
        valueBtn.setTitle("1234.78", for: .normal)
        valueBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        valueBtn.contentHorizontalAlignment = .right
        //valueBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 32)
        hlayout.addSubview(valueBtn)
        byValueView.addSubview(hlayout)
    }
}
