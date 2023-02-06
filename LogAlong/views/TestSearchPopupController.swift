//
//  TestSearchPopupController.swift
//  LogAlong
//
//  Created by Frank Gao on 2/5/23.
//  Copyright © 2023 Swoag Technology. All rights reserved.
//

import UIKit

class TestSearchPopupController: UIViewController {
    private var headerView: HorizontalLayout!
    private var search: LRecordSearch!
    
    override func viewDidLoad() {
        displayHeader()
        displayShowAllView()
        displayAllValueView()
        displayAllTimeView()
    }
    
    private func displayHeader() {
        headerView = HorizontalLayout(height: 45)
        
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        headerView.addSubview(spacer)
        
        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 60, height: 30))
        label.text = NSLocalizedString("Select Records", comment: "")
        headerView.addSubview(label)
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 25 + 10, height: 25))
        //btn.addTarget(self, action: #selector(onCancelClick), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "ic_action_cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        headerView.addSubview(btn)
        
        headerView.backgroundColor = LTheme.Color.dialog_border_color
        
        self.view.addSubview(headerView)
    }
    
    private func displayShowAllView() {
        
    }
    
    private func displayAllValueView() {
        
    }
    
    private func displayAllTimeView() {
        
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
}
