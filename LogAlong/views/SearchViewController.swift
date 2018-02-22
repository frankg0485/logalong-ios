//
//  SearchViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 2/10/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

enum SearchSelectType {
    case ACCOUNT
    case CATEGORY
    case VENDOR
    case TAG
    case FROM
    case TO
    case VALUE
}

class SearchViewController: UIViewController, UIPopoverPresentationControllerDelegate, FViewControllerDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var separator1: UIView!
    @IBOutlet weak var separator2: UIView!
    @IBOutlet weak var headerView: HorizontalLayout!
    @IBOutlet weak var showAllView: HorizontalLayout!
    @IBOutlet weak var allTimeView: HorizontalLayout!
    @IBOutlet weak var byValueView: HorizontalLayout!
    @IBOutlet weak var showAllGroupView: VerticalLayout!
    @IBOutlet weak var allTimeGroupView: VerticalLayout!
    @IBOutlet weak var showAllGroupHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var allTimeGroupHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollContentHeightConstraint: NSLayoutConstraint!

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
    var valueBtn: UIButton!

    var searchSelectType: SearchSelectType!
    var search: LRecordSearch!

    let headerHeight: CGFloat = 45 //constraint set in storyboard
    let entryHeight: CGFloat = 45
    let entryBottomMargin: CGFloat = 5
    let sectionHeaderHeight: CGFloat = 50
    let contentSizeBaseHeight: CGFloat = 210 // headerHeight + 3 * sectionHeaderHeight + overhead
    let showAllGroupHeight: CGFloat = 202 //4 * (entryHeight + entryBottomMargin) + 2
    let allTimeGroupHeight: CGFloat = 102 //2 * (entryHeight + entryBottomMargin) + 2

    override func viewDidLoad() {
        super.viewDidLoad()

        createHeader()
        createShowAll()
        createAllTime()
        createByValue()

        search = LPreferences.getRecordsSearchControls()
        allViewSwitch.isOn = search.all
        timeSwitch.isOn = search.allTime
        valueSwitch.isOn = search.byValue

        onShowAllClick()
        onAllTimeClick()
        displayValues()
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
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

        search.all = allViewSwitch.isOn
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

        search.allTime = timeSwitch.isOn
    }

    private func presentPopOver(_ vc: UIViewController) {
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect =
            CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 22, width: 0, height: 0)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        vc.popoverPresentationController!.delegate = self

        self.present(vc, animated: true, completion: nil)
    }

    private func presentSelection(_ type: SelectType, values: [Int64]) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectViewController")
            as! SelectViewController

        vc.selectType = type
        vc.initValues = values
        vc.color = LTheme.Color.base_orange
        vc.multiSelection = true
        vc.delegate = self

        presentPopOver(vc)
    }

    @objc func onClickAccounts() {
        searchSelectType = .ACCOUNT
        presentSelection(.ACCOUNT, values: search.accounts)
    }

    @objc func onClickCategories() {
        searchSelectType = .CATEGORY
        presentSelection(.CATEGORY, values: search.categories)
    }

    @objc func onClickVendors() {
        searchSelectType = .VENDOR
        presentSelection(.VENDOR, values: search.vendors)
    }

    @objc func onClickTags() {
        searchSelectType = .TAG
        presentSelection(.TAG, values: search.tags)
    }

    private func presentTime(_ initValue: Int64) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerViewController")
            as! DatePickerViewController

        vc.initValue = initValue
        vc.color = LTheme.Color.base_orange
        vc.delegate = self

        presentPopOver(vc)
    }

    @objc func onClickFromTime() {
        searchSelectType = .FROM
        presentTime(search.from)
    }

    @objc func onClickToTime() {
        searchSelectType = .TO
        presentTime(search.to)
    }

    @objc func onClickFilterBy() {
        search.byEditTime = !search.byEditTime
        displayFilterBy()
    }

    @objc func onClickValue() {
        if search.byValue {
            searchSelectType = .VALUE

            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectAmountViewController")
                as! SelectAmountViewController
            vc.initValue = search.value
            vc.color = LTheme.Color.base_orange
            vc.delegate = self

            presentPopOver(vc)
        }
    }

    @objc func onClickValueSwitch() {
        search.byValue = valueSwitch.isOn
    }

    @objc func onCancelClick() {
        dismiss(animated: true, completion: nil)

        LPreferences.setRecordsSearchControls(controls: search)
        LBroadcast.post(LBroadcast.ACTION_UI_DB_SEARCH_CHANGED)
    }

    private func displayMe(ids: [Int64], btn: UIButton, name: (Int64) -> String?) {
        if (ids.isEmpty) {
            btn.setTitle(NSLocalizedString("all", comment: ""), for: .normal)
        } else {
            var str: String = ""
            var found = false
            for id in ids {
                if let nm = name(id) {
                    if found {
                        str.append(", ")
                    }
                    str.append(nm)
                    found = true
                }
            }
            btn.setTitle(str, for: .normal)
        }
    }

    private func displayAccounts() {
        displayMe(ids: search.accounts, btn: accountsBtn) {DBAccount.instance.get(id: $0)?.name}
    }

    private func displayCategories() {
        displayMe(ids: search.categories, btn: categoriesBtn) {DBCategory.instance.get(id: $0)?.name}
    }

    private func displayVendors() {
        displayMe(ids: search.vendors, btn: vendorsBtn) {DBVendor.instance.get(id: $0)?.name}
    }

    private func displayTags() {
        displayMe(ids: search.tags, btn: tagsBtn) {DBTag.instance.get(id: $0)?.name}
    }

    private func displayTime(ms: Int64, btn: UIButton) {
        let date = Date(milliseconds: ms)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateStyle = .medium
        let dateString = dayTimePeriodFormatter.string(from: date)
        btn.setTitle(dateString, for: .normal)
        btn.sizeToFit()
    }

    private func displayFromTime() {
        displayTime(ms: search.from, btn: fromTimeBtn)
    }

    private func displayToTime() {
        displayTime(ms: search.to, btn: toTimeBtn)
    }

    private func displayFilterBy() {
        if search.byEditTime {
            filterByBtn.setTitle(NSLocalizedString("Edit Time", comment: ""), for: .normal)
        } else {
            filterByBtn.setTitle(NSLocalizedString("Record Time", comment: ""), for: .normal)
        }
        filterByBtn.sizeToFit()
    }

    private func displayValue() {
        valueBtn.setTitle(String(search.value), for: .normal)
        valueBtn.sizeToFit()
    }

    private func displayValues() {
        displayAccounts()
        displayCategories()
        displayVendors()
        displayTags()
        displayFromTime()
        displayToTime()
        displayFilterBy()
        displayValue()
    }

    func passNumberBack(_ caller: UIViewController, type: TypePassed) {
        switch searchSelectType {
        case .ACCOUNT:
            if (type.allSelected || type.array64!.isEmpty) {
                search.accounts = [];
            } else {
                search.accounts = type.array64!
            }
            displayAccounts()
        case .CATEGORY:
            if (type.allSelected || type.array64!.isEmpty) {
                search.categories = [];
            } else {
                search.categories = type.array64!
            }
            displayCategories()
        case .VENDOR:
            if (type.allSelected || type.array64!.isEmpty) {
                search.vendors = []
            } else {
                search.vendors = type.array64!
            }
            displayVendors()
        case .TAG:
            if (type.allSelected || type.array64!.isEmpty) {
                search.tags = []
            } else {
                search.tags = type.array64!
            }
            displayTags()
        case .FROM:
            search.from = type.int64
            displayFromTime()
        case .TO:
            search.to = type.int64
            displayToTime()
        case .VALUE:
            search.value = type.double
            displayValue()
        default: break
        }
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
        scrollContentHeightConstraint.constant = height - headerHeight
    }

    private func createHeader() {
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        headerView.addSubview(spacer)

        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 60, height: 30))
        label.text = NSLocalizedString("Select Records", comment: "")
        headerView.addSubview(label)

        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 25 + 10, height: 25))
        btn.addTarget(self, action: #selector(onCancelClick), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "ic_action_cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
        headerView.addSubview(btn)

        headerView.backgroundColor = LTheme.Color.dialog_border_color
    }

    private func createShowAllEntry(_ str: String) -> (HorizontalLayout, UIButton) {
        let layout = HorizontalLayout(height: entryHeight)
        layout.layoutMargins.top = 0
        layout.layoutMargins.bottom = entryBottomMargin

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
        let hlayout = HorizontalLayout(height: sectionHeaderHeight)
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
        accountsBtn.addTarget(self, action: #selector(onClickAccounts), for: .touchUpInside)
        showAllGroupView.addSubview(layout)

        (layout, btn) = createShowAllEntry(NSLocalizedString("Categories", comment: ""))
        categoriesBtn = btn
        categoriesBtn.addTarget(self, action: #selector(onClickCategories), for: .touchUpInside)
        showAllGroupView.addSubview(layout)

        (layout, btn) = createShowAllEntry(NSLocalizedString("Payee/Payers", comment: ""))
        vendorsBtn = btn
        vendorsBtn.addTarget(self, action: #selector(onClickVendors), for: .touchUpInside)
        showAllGroupView.addSubview(layout)

        (layout, btn) = createShowAllEntry(NSLocalizedString("Tags", comment: ""))
        tagsBtn = btn
        tagsBtn.addTarget(self, action: #selector(onClickTags), for: .touchUpInside)
        showAllGroupView.addSubview(layout)
        showAllGroupHeightConstraint.constant = showAllGroupHeight
    }

    private func createAllTime() {
        let hlayout = HorizontalLayout(height: sectionHeaderHeight)
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

        let layout = HorizontalLayout(height: entryHeight)
        layout.layoutMargins.top = 0
        layout.layoutMargins.bottom = entryBottomMargin

        fromTimeBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        fromTimeBtn.addTarget(self, action: #selector(onClickFromTime), for: .touchUpInside)
        //fromTimeBtn.setTitle(NSLocalizedString("Jan 10, 2018", comment: ""), for: .normal)
        fromTimeBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        fromTimeBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        fromTimeBtn.contentHorizontalAlignment = .left
        layout.addSubview(fromTimeBtn)

        let toLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        toLabel.textColor = LTheme.Color.gray_text_color
        toLabel.text = NSLocalizedString("to", comment: "")
        layout.addSubview(toLabel)

        toTimeBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        toTimeBtn.addTarget(self, action: #selector(onClickToTime), for: .touchUpInside)
        //toTimeBtn.setTitle(NSLocalizedString("Feb 10, 2018", comment: ""), for: .normal)
        toTimeBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        toTimeBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        toTimeBtn.contentHorizontalAlignment = .right
        layout.addSubview(toTimeBtn)
        allTimeGroupView.addSubview(layout)

        let (layout2, btn) = createShowAllEntry(NSLocalizedString("Filter by", comment: ""))
        filterByBtn = btn
        filterByBtn.addTarget(self, action: #selector(onClickFilterBy), for: .touchUpInside)
        allTimeGroupView.addSubview(layout2)

        allTimeGroupHeightConstraint.constant = allTimeGroupHeight
    }

    private func createByValue() {
        let hlayout = HorizontalLayout(height: sectionHeaderHeight)
        hlayout.layoutMargins.top = 0
        hlayout.layoutMargins.bottom = 0
        hlayout.layoutMargins.left = 0
        hlayout.layoutMargins.right = 0

        valueSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        valueSwitch.addTarget(self, action: #selector(onClickValueSwitch), for: .touchUpInside)
        hlayout.addSubview(valueSwitch)

        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 80, height: 30))
        label.text = NSLocalizedString("By Value", comment: "")
        hlayout.addSubview(label)

        valueBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 30))
        valueBtn.addTarget(self, action: #selector(onClickValue), for: .touchUpInside)
        //valueBtn.setTitle("1234.78", for: .normal)
        valueBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        valueBtn.contentHorizontalAlignment = .right
        //valueBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 32)
        hlayout.addSubview(valueBtn)
        byValueView.addSubview(hlayout)
    }
}
