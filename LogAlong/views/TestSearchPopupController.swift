//
//  TestSearchPopupController.swift
//  LogAlong
//
//  Created by Frank Gao on 2/5/23.
//  Copyright © 2023 Swoag Technology. All rights reserved.
//

import UIKit

class TestSearchPopupController: UIViewController {
    private var search: LRecordSearch!
    
    private var headerView: HorizontalLayout!
    private var scrollView: UIScrollView!
    
    private var showAllView: HorizontalLayout!
    private var separator1: UIView!
    private var showAllGroupView: VerticalLayout!

    private var allValueView: HorizontalLayout!
    private var separator2: UIView!
    private var allValueGroupView: VerticalLayout!
    
    private var allTimeGroupView: VerticalLayout!
    private var separator3: UIView!
    private var allTimeView: HorizontalLayout!
    
    private var showAllSwitch: UISwitch!
    private var timeSwitch: UISwitch!
    private var valueSwitch: UISwitch!
    
    private var accountsCheckbox: LCheckbox!
    private var categoriesCheckbox: LCheckbox!
    private var vendorsCheckbox: LCheckbox!
    private var tagsCheckbox: LCheckbox!
    private var typesCheckbox: LCheckbox!
    
    private let sectionHeaderHeight: CGFloat = 50
    private let entryHeight: CGFloat = 50
    
    override func viewDidLoad() {
        search = LPreferences.getRecordsSearchControls()
        
        createHeader()
        createScrollView()
        createSwitches()
        createSeparators()
        createShowAllView()
        createAllValueView()
        createAllTimeView()
        
    }
    
    //MARK: Display
    
    private func createSwitches() {
        showAllSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 60, height: entryHeight * 0.6))
        //showAllSwitch.addTarget(self, action: #selector(onShowAllClick), for: .valueChanged)
        timeSwitch = UISwitch()
        valueSwitch = UISwitch()
        
        showAllSwitch.isOn = search.all
        timeSwitch.isOn = search.allTime
        valueSwitch.isOn = search.allValue
        //separator3.isHidden = valueSwitch.isOn
    }
    
    private func createHeader() {
        headerView = HorizontalLayout(height: 45)
        
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
        print(headerView.frame)
        print(scrollView.frame.width)
    }
    
    private func createSeparators() {
        
    }
    
    private func createShowAllView() {
        showAllView = HorizontalLayout(height: sectionHeaderHeight)

        //let showAllTap = UITapGestureRecognizer(target: self, action: #selector(showAllTapped))
        //showAllTap.delegate = self
        //showAllView.addGestureRecognizer(showAllTap)

        showAllView.addSubview(showAllSwitch)

        let showAllLabel = UILabel(frame: CGRect(x: 1, y: 0, width: 100, height: sectionHeaderHeight * 0.6))
        showAllLabel.text = NSLocalizedString("Show All", comment: "")
        showAllView.addSubview(showAllLabel)

        /*var tapped = UITapGestureRecognizer(target: self, action: #selector(onClickAccountsCheckbox))
        var (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Accounts", comment: ""), false)
        accountsBtn = btn
        accountsBtn.addTarget(self, action: #selector(onClickAccounts), for: .touchUpInside)
        accountsCheckbox = checkbox
        accountsCheckbox.addTarget(self, action: #selector(onClickAccountsCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)

        tapped = UITapGestureRecognizer(target: self, action: #selector(onClickCategoriesCheckbox))
        (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Categories", comment: ""), false)
        categoriesBtn = btn
        categoriesBtn.addTarget(self, action: #selector(onClickCategories), for: .touchUpInside)
        categoriesCheckbox = checkbox
        categoriesCheckbox.addTarget(self, action: #selector(onClickCategoriesCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)

        tapped = UITapGestureRecognizer(target: self, action: #selector(onClickVendorsCheckbox))
        (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Payee/Payers", comment: ""), false)
        vendorsBtn = btn
        vendorsBtn.addTarget(self, action: #selector(onClickVendors), for: .touchUpInside)
        vendorsCheckbox = checkbox
        vendorsCheckbox.addTarget(self, action: #selector(onClickVendorsCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)

        tapped = UITapGestureRecognizer(target: self, action: #selector(onClickTagsCheckbox))
        (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Tags", comment: ""), false)
        tagsBtn = btn
        tagsBtn.addTarget(self, action: #selector(onClickTags), for: .touchUpInside)
        tagsCheckbox = checkbox
        tagsCheckbox.addTarget(self, action: #selector(onClickTagsCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)

        tapped = UITapGestureRecognizer(target: self, action: #selector(onClickTypesCheckbox))
        (layout, btn, checkbox, label) = createShowAllEntry(NSLocalizedString("Types", comment: ""), false)
        typesBtn = btn
        typesBtn.addTarget(self, action: #selector(onClickTypes), for: .touchUpInside)
        typesCheckbox = checkbox
        typesCheckbox.addTarget(self, action: #selector(onClickTypesCheckbox), for: .touchUpInside)
        label.addGestureRecognizer(tapped)
        showAllGroupView.addSubview(layout)*/

        scrollView.addSubview(showAllView)
    }
    
    private func createAllValueView() {
        
    }
    
    private func createAllTimeView() {
        
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
    
    @objc func showAllToggle() {
        showAllSwitch.isOn = !showAllSwitch.isOn
        onShowAllClick()
    }

    @objc func allTimeToggle() {
        timeSwitch.isOn = !timeSwitch.isOn
        //onAllTimeClick()
    }

    @objc func allValueToggle() {
        valueSwitch.isOn = !valueSwitch.isOn
        //onClickValueSwitch()
    }

}
