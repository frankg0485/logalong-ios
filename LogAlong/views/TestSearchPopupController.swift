//
//  TestSearchPopupController.swift
//  LogAlong
//
//  Created by Frank Gao on 2/5/23.
//  Copyright © 2023 Swoag Technology. All rights reserved.
//

import UIKit

class TestSearchPopupController: UIViewController, UIGestureRecognizerDelegate, FViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    private var search: LRecordSearch!
    private var searchSelectType: SearchSelectType!
    
    private var headerView: HorizontalLayout!
    private var scrollView: UIScrollView!
    
    private var showAllView: HorizontalLayout!
    private var separator1: UIView!
    private var showAllGroupView: VerticalLayout!

    private var allTimeViewTopAnchor: NSLayoutConstraint!
    private var allTimeView: HorizontalLayout!
    private var separator2: UIView!
    private var allTimeGroupView: VerticalLayout!
    
    private var allValueView: HorizontalLayout!
    private var separator3: UIView!
    private var allValueGroupView: VerticalLayout!
    
    private var showAllSwitch: UISwitch!
    private var timeSwitch: UISwitch!
    private var valueSwitch: UISwitch!
    
    private var accountsCheckbox: LCheckbox!
    private var categoriesCheckbox: LCheckbox!
    private var vendorsCheckbox: LCheckbox!
    private var tagsCheckbox: LCheckbox!
    private var typesCheckbox: LCheckbox!
    
    private var accountsBtn: UIButton!
    private var categoriesBtn: UIButton!
    private var vendorsBtn: UIButton!
    private var tagsBtn: UIButton!
    private var typesBtn: UIButton!
    
    private var fromTimeBtn: UIButton!
    private var toTimeBtn: UIButton!
    private var filterByBtn: UIButton!
    private var fromValueBtn: UIButton!
    private var toValueBtn: UIButton!
    
    private let headerHeight: CGFloat = 45
    private let sectionHeaderHeight: CGFloat = 50
    private let entryHeight: CGFloat = 45
    private let entryBottomMargin: CGFloat = 5
    private let contentSizeBaseHeight: CGFloat = 210 // headerHeight + 3 * sectionHeaderHeight + overhead
    private let showAllGroupHeight: CGFloat = 252 //5 * (entryHeight + entryBottomMargin) + 2
    private let allTimeGroupHeight: CGFloat = 102 //2 * (entryHeight + entryBottomMargin) + 2
    private let allValueGroupHeight: CGFloat = 52 //1 * (entryHeight + entryBottomMargin) + 2
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = LTheme.Color.default_bgd_color
        
        search = LPreferences.getRecordsSearchControls()
        
        createHeader()
        createScrollView()
        createSwitches()
        createSeparators()
        createShowAllView()
        createAllTimeView()
        //createAllValueView()
        
        onShowAllClick()
        onAllTimeClick()
        displayValues()
        
        setContentHeight()
    }
    
    //MARK: Display
    
    private func createSwitches() {
        showAllSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 60, height: entryHeight * 0.6))
        showAllSwitch.addTarget(self, action: #selector(onShowAllClick), for: .valueChanged)
        timeSwitch = UISwitch()
        valueSwitch = UISwitch()
        
        showAllSwitch.isOn = search.all
        timeSwitch.isOn = search.allTime
        valueSwitch.isOn = search.allValue
        //separator3.isHidden = valueSwitch.isOn
    }
    
    private func createHeader() {
        headerView = HorizontalLayout(height: headerHeight)
        
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: entryHeight * 0.6))
        headerView.addSubview(spacer)
        
        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 60, height: entryHeight * 0.6))
        label.text = NSLocalizedString("Select Records", comment: "")
        headerView.addSubview(label)
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 25 + 10, height: entryHeight * 0.5))
        btn.addTarget(self, action: #selector(onCancelClick), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "ic_action_cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        headerView.addSubview(btn)
        
        headerView.backgroundColor = LTheme.Color.dialog_border_color
        
        self.view.addSubview(headerView)
    }
    
    private func createScrollView() {
        scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
    }
    
    private func createSeparators() {
        func configureSeparator(_ separator: UIView) {
            self.view.addSubview(separator)

            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = LTheme.Color.base_bgd_separator_color
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            separator.leadingAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.leadingAnchor).isActive = true
            separator.trailingAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.trailingAnchor).isActive = true
        }
        
        separator1 = UIView()
        separator2 = UIView()
        separator3 = UIView()
        configureSeparator(separator1)
        configureSeparator(separator2)
        configureSeparator(separator3)
    }
    
    private func createShowAllEntry(_ str: String, _ allTime: Bool) -> (HorizontalLayout, UIButton, LCheckbox, UILabel) {
        let layout = HorizontalLayout(height: entryHeight)
        layout.layoutMargins.top = 0
        layout.layoutMargins.bottom = entryBottomMargin

        let checkbox = LCheckbox(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        if !allTime {
            checkbox.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
            checkbox.isSelected = false
            layout.addSubview(checkbox)
        }

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        label.textColor = LTheme.Color.gray_text_color
        label.text = str
        label.isUserInteractionEnabled = true
        layout.addSubview(label)

        let valueBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        valueBtn.setTitle(NSLocalizedString("all", comment: ""), for: .normal)
        valueBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        valueBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        valueBtn.contentHorizontalAlignment = .right
        layout.addSubview(valueBtn)

        return (layout, valueBtn, checkbox, label)
    }
    
    private func createShowAllView() {
        showAllView = HorizontalLayout(height: sectionHeaderHeight)

        let showAllTap = UITapGestureRecognizer(target: self, action: #selector(showAllTapped))
        showAllTap.delegate = self
        showAllView.addGestureRecognizer(showAllTap)

        showAllView.addSubview(showAllSwitch)

        let showAllLabel = UILabel(frame: CGRect(x: 1, y: 0, width: 100, height: sectionHeaderHeight * 0.6))
        showAllLabel.text = NSLocalizedString("Show All", comment: "")
        showAllView.addSubview(showAllLabel)

        scrollView.addSubview(showAllView)
        showAllView.translatesAutoresizingMaskIntoConstraints = false
        showAllView.heightAnchor.constraint(equalToConstant: sectionHeaderHeight).isActive = true
        showAllView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor).isActive = true
        showAllView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor).isActive = true
        showAllView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor).isActive = true

        separator1.topAnchor.constraint(equalTo: showAllView.bottomAnchor).isActive = true
        
        showAllGroupView = VerticalLayout(width: scrollView.frame.width)
        
        var tapped = UITapGestureRecognizer(target: self, action: #selector(onClickAccountsCheckbox))
        var (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Accounts", comment: ""), false)
        accountsBtn = btn
        accountsBtn.addTarget(self, action: #selector(onClickAccounts), for: .touchUpInside)
        accountsCheckbox = checkbox
        accountsCheckbox.addTarget(self, action: #selector(onClickAccountsCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)
        layout.translatesAutoresizingMaskIntoConstraints = false
        layout.topAnchor.constraint(equalTo: showAllGroupView.topAnchor).isActive = true
        layout.heightAnchor.constraint(equalToConstant: entryHeight).isActive = true
        
        tapped = UITapGestureRecognizer(target: self, action: #selector(onClickCategoriesCheckbox))
        (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Categories", comment: ""), false)
        categoriesBtn = btn
        categoriesBtn.addTarget(self, action: #selector(onClickCategories), for: .touchUpInside)
        categoriesCheckbox = checkbox
        categoriesCheckbox.addTarget(self, action: #selector(onClickCategoriesCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)
        layout.translatesAutoresizingMaskIntoConstraints = false
        
        tapped = UITapGestureRecognizer(target: self, action: #selector(onClickVendorsCheckbox))
        (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Payee/Payers", comment: ""), false)
        vendorsBtn = btn
        vendorsBtn.addTarget(self, action: #selector(onClickVendors), for: .touchUpInside)
        vendorsCheckbox = checkbox
        vendorsCheckbox.addTarget(self, action: #selector(onClickVendorsCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)
        layout.translatesAutoresizingMaskIntoConstraints = false
        
        tapped = UITapGestureRecognizer(target: self, action: #selector(onClickTagsCheckbox))
        (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Tags", comment: ""), false)
        tagsBtn = btn
        tagsBtn.addTarget(self, action: #selector(onClickTags), for: .touchUpInside)
        tagsCheckbox = checkbox
        tagsCheckbox.addTarget(self, action: #selector(onClickTagsCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)
        layout.translatesAutoresizingMaskIntoConstraints = false
        
        tapped = UITapGestureRecognizer(target: self, action: #selector(onClickTypesCheckbox))
        (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Types", comment: ""), false)
        typesBtn = btn
        typesBtn.addTarget(self, action: #selector(onClickTypes), for: .touchUpInside)
        typesCheckbox = checkbox
        typesCheckbox.addTarget(self, action: #selector(onClickTypesCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)
        layout.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(showAllGroupView)
        showAllGroupView.translatesAutoresizingMaskIntoConstraints = false
        showAllGroupView.heightAnchor.constraint(equalToConstant: showAllGroupHeight).isActive = true
        showAllGroupView.topAnchor.constraint(equalTo: separator1.bottomAnchor).isActive = true
        showAllGroupView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor).isActive = true
        showAllGroupView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
    }
    
    private func createAllTimeView() {
        allTimeView = HorizontalLayout(height: sectionHeaderHeight)
        
        let allTimeTap = UITapGestureRecognizer(target: self, action: #selector(allTimeTapped))
        allTimeTap.delegate = self
        allTimeView.addGestureRecognizer(allTimeTap)

        timeSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        timeSwitch.addTarget(self, action: #selector(onAllTimeClick), for: .valueChanged)
        allTimeView.addSubview(timeSwitch)

        scrollView.addSubview(allTimeView)
        allTimeView.translatesAutoresizingMaskIntoConstraints = false
        allTimeView.heightAnchor.constraint(equalToConstant: sectionHeaderHeight).isActive = true
        allTimeViewTopAnchor = allTimeView.topAnchor.constraint(equalTo: separator1.bottomAnchor)
        allTimeViewTopAnchor.isActive = true
        allTimeView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor).isActive = true
        allTimeView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor).isActive = true

        separator2.topAnchor.constraint(equalTo: allTimeView.bottomAnchor).isActive = true
        
        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 100, height: 30))
        label.text = NSLocalizedString("All Time", comment: "")
        allTimeView.addSubview(label)

        allTimeGroupView = VerticalLayout(width: scrollView.frame.width)
        
        let layout = HorizontalLayout(height: entryHeight)
        layout.layoutMargins.top = 0
        layout.layoutMargins.bottom = entryBottomMargin

        fromTimeBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        fromTimeBtn.addTarget(self, action: #selector(onClickFromTime), for: .touchUpInside)
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
        toTimeBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        toTimeBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        toTimeBtn.contentHorizontalAlignment = .right
        layout.addSubview(toTimeBtn)
        allTimeGroupView.addSubview(layout)

        let (layout2, btn, _, _) = createShowAllEntry(NSLocalizedString("Filter by", comment: ""), true)
        filterByBtn = btn
        filterByBtn.addTarget(self, action: #selector(onClickFilterBy), for: .touchUpInside)
        allTimeGroupView.addSubview(layout2)
        
        scrollView.addSubview(allTimeGroupView)
        allTimeGroupView.translatesAutoresizingMaskIntoConstraints = false
        allTimeGroupView.heightAnchor.constraint(equalToConstant: allTimeGroupHeight).isActive = true
        allTimeGroupView.topAnchor.constraint(equalTo: separator2.bottomAnchor).isActive = true
        allTimeGroupView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor).isActive = true
        allTimeGroupView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
    }
    
    private func createAllValueView() {
        let hlayout = HorizontalLayout(height: sectionHeaderHeight)
        hlayout.layoutMargins.top = 0
        hlayout.layoutMargins.bottom = 0
        hlayout.layoutMargins.left = 0
        hlayout.layoutMargins.right = 0

        valueSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        //valueSwitch.addTarget(self, action: #selector(onClickValueSwitch), for: .valueChanged)
        hlayout.addSubview(valueSwitch)

        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 80, height: 30))
        label.text = NSLocalizedString("All Value", comment: "")
        label.isUserInteractionEnabled = true
        hlayout.addSubview(label)

        //let viewTap = UITapGestureRecognizer(target: self, action: #selector(allValueViewTapped))
        //viewTap.delegate = self
        //allValueView.addGestureRecognizer(viewTap)

        allValueView.addSubview(hlayout)

        let layout = HorizontalLayout(height: entryHeight)
        layout.layoutMargins.top = 0
        layout.layoutMargins.bottom = entryBottomMargin

        fromValueBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        fromValueBtn.addTarget(self, action: #selector(onClickFromValue), for: .touchUpInside)
        fromValueBtn.setTitle(NSLocalizedString("---", comment: ""), for: .normal)
        fromValueBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        fromValueBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        fromValueBtn.contentHorizontalAlignment = .center
        layout.addSubview(fromValueBtn)

        let toLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        toLabel.textColor = LTheme.Color.gray_text_color
        toLabel.text = NSLocalizedString("to", comment: "")
        layout.addSubview(toLabel)

        toValueBtn = UIButton(frame: CGRect(x: 1, y: 0, width: 0, height: 40))
        toValueBtn.addTarget(self, action: #selector(onClickToValue), for: .touchUpInside)
        toValueBtn.setTitle(NSLocalizedString("---", comment: ""), for: .normal)
        toValueBtn.setTitleColor(LTheme.Color.base_text_color, for: .normal)
        toValueBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        toValueBtn.contentHorizontalAlignment = .center
        layout.addSubview(toValueBtn)

        allValueGroupView.addSubview(layout)
    }
    
    private func setContentHeight() {
        var height = contentSizeBaseHeight
        if !showAllSwitch.isOn {
            height += showAllGroupHeight
            allTimeViewTopAnchor.constant = showAllGroupHeight
        } else {
            allTimeViewTopAnchor.constant = 0
        }
        
        if !timeSwitch.isOn {
            height += allTimeGroupView.frame.height
        }
        
        /*if !valueSwitch.isOn {
            height += allValueGroupView.frame.height
        }*/
        preferredContentSize.height = height
    }
    
    private func presentPopOver(_ vc: UIViewController) {
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect =
            CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
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
        accountsBtn.isEnabled = search.searchAccounts
        accountsCheckbox.isSelected = search.searchAccounts
    }

    private func displayCategories() {
        displayMe(ids: search.categories, btn: categoriesBtn) {DBCategory.instance.get(id: $0)?.name}
        categoriesBtn.isEnabled = search.searchCategories
        categoriesCheckbox.isSelected = search.searchCategories
    }

    private func displayVendors() {
        displayMe(ids: search.vendors, btn: vendorsBtn) {DBVendor.instance.get(id: $0)?.name}
        vendorsBtn.isEnabled = search.searchVendors
        vendorsCheckbox.isSelected = search.searchVendors
    }

    private func displayTags() {
        displayMe(ids: search.tags, btn: tagsBtn) {DBTag.instance.get(id: $0)?.name}
        tagsBtn.isEnabled = search.searchTags
        tagsCheckbox.isSelected = search.searchTags
    }

    private func displayTypes() {
        displayMe(ids: search.types, btn: typesBtn) {
            var name = ""
            switch $0 {
            case 1:
                name = NSLocalizedString("Expense", comment: "")
            case 2:
                name = NSLocalizedString("Income", comment: "")
            case 3:
                name = NSLocalizedString("Transfer", comment: "")
            default:
                LLog.e("\(self)", "Unexpected type :\($0)")
            }
            return name
        }
        typesBtn.isEnabled = search.searchTypes
        typesCheckbox.isSelected = search.searchTypes
    }
    
    private func presentTime(_ initValue: Int64) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DatePickerViewController")
            as! DatePickerViewController

        vc.initValue = initValue
        vc.color = LTheme.Color.base_orange
        vc.delegate = self

        presentPopOver(vc)
    }
    
    private func presentAmountPicker(_ fromValue: Bool) {
        if !search.allValue {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectAmountViewController")
                as! SelectAmountViewController
            if fromValue {
                vc.oldValue = search.fromValue
            } else {
                vc.oldValue = search.toValue
            }
            vc.allowZero = true
            vc.color = LTheme.Color.base_orange
            vc.delegate = self

            presentPopOver(vc)
        }
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
    
    private func displayFromValue() {
        if search.fromValue == 0 { fromValueBtn.setTitle("---", for: .normal) }
        else { fromValueBtn.setTitle("\(search.fromValue)", for: .normal) }
        fromValueBtn.sizeToFit()
    }

    private func displayToValue() {
        if search.toValue == 0 { toValueBtn.setTitle("---", for: .normal) }
        else { toValueBtn.setTitle("\(search.toValue)", for: .normal) }
        toValueBtn.sizeToFit()
    }
    
    private func displayValues() {
        displayAccounts()
        displayCategories()
        displayVendors()
        displayTags()
        displayTypes()
        displayFilterBy()
        //displayFromValue()
       // displayToValue()
        displayFromTime()
        displayToTime()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //MARK: Actions
    
    @objc func onCancelClick() {
        if search.searchAccounts && (!search.accounts.isEmpty) ||
           search.searchCategories && (!search.categories.isEmpty) ||
           search.searchVendors && (!search.vendors.isEmpty) ||
           search.searchTags && (!search.tags.isEmpty) ||
           search.searchTypes && (!search.types.isEmpty) {}
        else {
            search.all = true
        }

        if (search.fromValue < 0.01) && (search.toValue < 0.01) {
            search.allValue = true
        }

        dismiss(animated: true, completion: nil)

        LPreferences.setRecordsSearchControls(controls: search)
        LBroadcast.post(LBroadcast.ACTION_UI_DB_SEARCH_CHANGED)
    }
    
    @objc func onShowAllClick() {
        showAllGroupView.isHidden = showAllSwitch.isOn
        search.all = showAllSwitch.isOn
        
        setContentHeight()
    }
    
    @objc func onAllTimeClick() {
        allTimeGroupView.isHidden = timeSwitch.isOn
        search.allTime = timeSwitch.isOn

        setContentHeight()
    }
    
    @objc func onClickFromTime() {
        searchSelectType = .FROM_TIME
        presentTime(search.from)
    }

    @objc func onClickToTime() {
        searchSelectType = .TO_TIME
        presentTime(search.to)
    }

    @objc func onClickFilterBy() {
        search.byEditTime = !search.byEditTime
        displayFilterBy()
    }

    @objc func onClickFromValue() {
        searchSelectType = .FROM_VALUE
        presentAmountPicker(true)
    }

    @objc func onClickToValue() {
        searchSelectType = .TO_VALUE
        presentAmountPicker(false)
    }
    
    @objc func showAllTapped() {
        showAllSwitch.isOn = !showAllSwitch.isOn
        onShowAllClick()
    }

    @objc func allTimeTapped() {
        timeSwitch.isOn = !timeSwitch.isOn
        onAllTimeClick()
    }

    @objc func allValueTapped() {
        valueSwitch.isOn = !valueSwitch.isOn
        //onClickValueSwitch()
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

    @objc func onClickTypes() {
        searchSelectType = .TYPE
        presentSelection(.TYPE, values: search.types)
    }
    
    @objc func onClickAccountsCheckbox() {
        accountsCheckbox.isSelected = !accountsCheckbox.isSelected
        search.searchAccounts = accountsCheckbox.isSelected
        accountsBtn.isEnabled = accountsCheckbox.isSelected
    }

    @objc func onClickCategoriesCheckbox() {
        categoriesCheckbox.isSelected = !categoriesCheckbox.isSelected
        search.searchCategories = categoriesCheckbox.isSelected
        categoriesBtn.isEnabled = categoriesCheckbox.isSelected
    }

    @objc func onClickVendorsCheckbox() {
        vendorsCheckbox.isSelected = !vendorsCheckbox.isSelected
        search.searchVendors = vendorsCheckbox.isSelected
        vendorsBtn.isEnabled = vendorsCheckbox.isSelected
    }

    @objc func onClickTagsCheckbox() {
        tagsCheckbox.isSelected = !tagsCheckbox.isSelected
        search.searchTags = tagsCheckbox.isSelected
        tagsBtn.isEnabled = tagsCheckbox.isSelected
    }

    @objc func onClickTypesCheckbox() {
        typesCheckbox.isSelected = !typesCheckbox.isSelected
        search.searchTypes = typesCheckbox.isSelected
        typesBtn.isEnabled = typesCheckbox.isSelected
    }
    
    func passNumberBack(_ caller: UIViewController, type: TypePassed, okPressed: Bool) {
        if okPressed {
            switch searchSelectType! {
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
            case .TYPE:
                if (type.allSelected || type.array64!.isEmpty) {
                    search.types = []
                } else {
                    search.types = type.array64!
                }
                displayTypes()
            case .FROM_TIME:
                search.from = LPreferences.getGeneralMilliseconds(true, millis: type.int64)
                displayFromTime()
            case .TO_TIME:
                search.to = LPreferences.getGeneralMilliseconds(false, millis: type.int64)
                displayToTime()
            case .FROM_VALUE:
                search.fromValue = type.double
                displayFromValue()
            case .TO_VALUE:
                search.toValue = type.double
                displayToValue()
            }
        }
    }
}
