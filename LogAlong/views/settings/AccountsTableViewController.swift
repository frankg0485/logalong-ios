//
//  AccountsTableViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/11/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

enum SettingsListType {
    case ACCOUNT
    case CATEGORY
    case VENDOR
    case TAG
}
class AccountsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, FPassCreationBackDelegate {

    var listType: SettingsListType!
    var titleButton: UIButton!

    var accounts: [LAccount] = []
    var categories: [LCategory] = []
    var vendors: [LVendor] = []
    var tags: [LTag] = []
    var isVisible = false
    var isRefreshPending = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        getEntries()

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = nil

        LBroadcast.register(LBroadcast.ACTION_UI_DB_DATA_CHANGED,
                            cb: #selector(self.dbDataChanged),
                            listener: self)
        LBroadcast.register(LBroadcast.ACTION_UI_UPDATE_ACCOUNT, cb: #selector(self.uiUpdateAccount), listener: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    private func refreshAll() {
        if isVisible {
            getEntries()
            tableView.reloadData()
        }
    }

    private func setupNavigationBarItems() {
        //navigationItem.leftBarButtonItem = editButtonItem
        let BTN_W: CGFloat = LTheme.Dimension.bar_button_width
        let BTN_H: CGFloat = LTheme.Dimension.bar_button_height

        titleButton = UIButton(type: .custom)
        //titleButton.addTarget(self, action: #selector(self.onTitleClick), for: .touchUpInside)
        titleButton.setSize(w: 180, h: 30)
        navigationItem.titleView = titleButton

        let cancelButton = UIButton(type: .system)
        cancelButton.addTarget(self, action: #selector(self.onCancelClick), for: .touchUpInside)
        cancelButton.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
        cancelButton.setSize(w: BTN_W + 20, h: BTN_H)

        let addButton = UIButton(type: .system)
        addButton.addTarget(self, action: #selector(self.onAddClick), for: .touchUpInside)
        addButton.setImage(#imageLiteral(resourceName: "ic_action_new").withRenderingMode(.alwaysOriginal), for: .normal)
        addButton.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0)
        addButton.setSize(w: BTN_W + 40, h: BTN_H)

        let deleteButton = UIButton(type: .system)
        deleteButton.addTarget(self, action: #selector(self.onDeleteClick), for: .touchUpInside)
        deleteButton.setImage(#imageLiteral(resourceName: "ic_action_discard").withRenderingMode(.alwaysOriginal), for: .normal)
        deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 15)
        deleteButton.setSize(w: BTN_W + 20, h: BTN_H)
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: cancelButton),
                                             UIBarButtonItem(customView: deleteButton)]
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)

        //navigationController?.navigationBar.isTranslucent = false
        //navigationController?.navigationBar.barStyle = .black
    }

    private func getEntries() {
        switch (listType!) {
        case .ACCOUNT:
            accounts = DBAccount.instance.getAll()
            titleButton.setTitle(NSLocalizedString("Accounts", comment: ""), for: .normal)
        case .CATEGORY:
            categories = DBCategory.instance.getAll()
            titleButton.setTitle(NSLocalizedString("Categories", comment: ""), for: .normal)
        case .VENDOR:
            vendors = DBVendor.instance.getAll()
            titleButton.setTitle(NSLocalizedString("Payee/Payers", comment: ""), for: .normal)
        case .TAG:
            tags = DBTag.instance.getAll()
            titleButton.setTitle(NSLocalizedString("Tags", comment: ""), for: .normal)
        }
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

    //------------------ ACCOUNT --------------------------
    @objc func uiUpdateAccount(notification: Notification) -> Void {
        accounts = DBAccount.instance.getAll()
        tableView.reloadData()
    }

    func unshareAllFromAccount(_ accountId: Int64) {
        let account = DBAccount.instance.get(id: accountId)!
        account.share = ""
        account.setOwner(Int64(LPreferences.getUserIdNum()))
        _ = DBAccount.instance.update(account)
        _ = LJournal.instance.removeUserFromAccount(uid: 0, aid: account.gid)
    }

    func unshareMyselfFromAccount(_ accountId: Int64) {
        let account = DBAccount.instance.get(id: accountId)!
        DBAccount.deleteEntries(of: accountId)
        _ = DBAccount.instance.remove(id: accountId)
        _ = LJournal.instance.removeUserFromAccount(uid: Int64(LPreferences.getUserIdNum()), aid: account.gid)
    }

    func do_account_share_update(_ accountId: Int64, _ selections: Set<Int64>, _ origSelections: Set<Int64>) {
        guard let account = DBAccount.instance.get(id: accountId) else { return }
        if (selections.isEmpty) {
            if (account.getOwner() == LPreferences.getUserIdNum()) {
                //removing everyone from shared group
                unshareAllFromAccount(accountId)
            } else {
                //unshare myself
                unshareMyselfFromAccount(accountId)
            }
            return
        }

        let journal = LJournal.instance
        //first update all existing users if there's any removal
        for ii in origSelections {
            if (!selections.contains(ii)) {
                account.removeShareUser(ii)
                _ = journal.removeUserFromAccount(uid: ii, aid: account.gid)
            }
        }

        //now request for new share
        for ii in selections {
            var newShare = false
            if (!origSelections.contains(ii)) {
                newShare = true
            } else if (account.getShareUserState(ii) > LAccount.ACCOUNT_SHARE_PERMISSION_OWNER) {
                newShare = true
            }

            if (newShare) {
                // new share request: new member is added to group
                account.addShareUser(ii, LAccount.ACCOUNT_SHARE_INVITED)
                _ = journal.addUserToAccount(uid: ii, aid: account.gid)
            }
        }
        _ = DBAccount.instance.update(account)
    }

    func getAccountCurrentShares(_ account: LAccount) -> Set<Int64> {
        var selectedUsers: Set<Int64> = []
        if (!account.getShareIdsStates().shareIds.isEmpty) {
            for ii in account.getShareIdsStates().shareIds {
                if (ii == LPreferences.getUserIdNum()) {
                    continue
                }
                if (LPreferences.getShareUserId(ii) != nil) {
                    let shareState = account.getShareUserState(ii)
                    if (LAccount.ACCOUNT_SHARE_PERMISSION_OWNER >= shareState
                        || LAccount.ACCOUNT_SHARE_INVITED == shareState) {
                        selectedUsers.insert(ii)
                    }
                } else {
                    LLog.w("\(self)", "unexpected: unknown shared user")
                }
            }
        }
        return selectedUsers
    }

    func onShareAccountDialogExit(_ applyToAllAccounts: Bool, _ accountId: Int64,
                                  _ selections: Set<Int64>, origSelections: Set<Int64>) {
        var set: Set<Int64> = []

        if (applyToAllAccounts) {
            for account in DBAccount.instance.getAll() {
                set.insert(account.id)
            }

            for id in set {
                if let account = DBAccount.instance.get(id: id) {
                    if (account.getOwner() == Int64(LPreferences.getUserIdNum())) {
                        let selectedUsers = getAccountCurrentShares(account)
                        do_account_share_update(id, selections, selectedUsers)
                    }
                }
            }
        } else {
            do_account_share_update(accountId, selections, origSelections)
        }

        accounts = DBAccount.instance.getAll()
        tableView.reloadData()
    }

    @IBAction func shareButtonClicked(_ sender: UIButton) {
        if LPreferences.getUserIdNum() == 0 {
            presentReminderView()
        } else {
            if let cell = sender.superview?.superview as? AccountsTableViewCell {
                let name = cell.nameLabel.text!
                if let account = DBAccount.instance.get(name: name) {
                    presentShareView(account)
                }
            }
        }
    }

    func presentReminderView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProfileReminder") as! ProfileReminderViewController

        presentPopOver(controller)
    }

    func presentShareView(_ account: LAccount) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ShareAccount") as! ShareAccountViewController

        controller.account = account
        controller.origSelectedIds = getAccountCurrentShares(account)
        controller.accountsVC = self

        presentPopOver(controller)
    }

    //------------------ CATEGORY -------------------------
    //------------------ VENDOR ---------------------------
    //------------------ TAG ------------------------------

/*    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.backgroundColor = LTheme.Color.row_released_color
        cell.layer.borderWidth = 1
        cell.layer.borderColor = tableView.backgroundColor?.cgColor
    }*/

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (listType!) {
        case .ACCOUNT:
            return accounts.count
        case .CATEGORY:
            return categories.count
        case .VENDOR:
            return vendors.count
        case .TAG:
            return tags.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AccountCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AccountsTableViewCell else {
            fatalError("The dequeued cell is not an instance of AccountsTableViewCell.")
        }

        cell.shareButton.isHidden = true
        cell.shareIconConstraint.constant = -50

        switch (listType!) {
        case .ACCOUNT:
            cell.shareButton.isHidden = false
            cell.shareIconConstraint.constant = 5

            let account = accounts[indexPath.row]

            cell.nameLabel.text = account.name

            let shareIds = accounts[indexPath.row].getShareIdsStates().shareIds
            let shareStates = accounts[indexPath.row].getShareIdsStates().shareStates

            var shareImageNumber = 0

            for ii in 0..<shareIds.count {
                if shareStates[ii] == LAccount.ACCOUNT_SHARE_INVITED {
                    cell.shareButton.setImage(#imageLiteral(resourceName: "ic_action_share_yellow").withRenderingMode(.alwaysOriginal), for: .normal)
                    shareImageNumber = 1
                    break
                } else if shareStates[ii] == LAccount.ACCOUNT_SHARE_PERMISSION_READ_WRITE {
                    cell.shareButton.setImage(#imageLiteral(resourceName: "ic_action_share_green").withRenderingMode(.alwaysOriginal), for: .normal)
                    shareImageNumber = 2
                }
            }

            if shareImageNumber == 0 {
                cell.shareButton.setImage(#imageLiteral(resourceName: "ic_action_share_dark").withRenderingMode(.alwaysOriginal), for: .normal)
            }

        case .CATEGORY:
            let category = categories[indexPath.row]
            cell.nameLabel.text = category.name

        case .VENDOR:
            let vendor = vendors[indexPath.row]
            cell.nameLabel.text = vendor.name

        case .TAG:
            let tag = tags[indexPath.row]
            cell.nameLabel.text = tag.name
        }

        return cell
    }


    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }

        return .none
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            switch (listType!) {
            case .ACCOUNT:
                let acnt = accounts.remove(at: indexPath.row)
                DBAccount.deleteEntries(of: acnt.id)
                if DBAccount.instance.remove(id: acnt.id) {
                    _ = LJournal.instance.deleteAccount(gid: acnt.gid)
                }
            case .CATEGORY:
                let cat = categories.remove(at: indexPath.row)
                if DBCategory.instance.remove(id: cat.id) {
                    _ = LJournal.instance.deleteCategory(gid: cat.gid)
                }
            case .VENDOR:
                let vend = vendors.remove(at: indexPath.row)
                if DBVendor.instance.remove(id: vend.id) {
                    _ = LJournal.instance.deleteVendor(gid: vend.gid)
                }
            case .TAG:
                let tag = tags.remove(at: indexPath.row)
                if DBTag.instance.remove(id: tag.id) {
                    _ = LJournal.instance.deleteTag(gid: tag.gid)
                }
            }

            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }


    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */


    // MARK: - Navigation

    @objc func onCancelClick() {
        tableView.setEditing(false, animated: true)
        tableView.endEditing(true)

        navigationController?.popViewController(animated: true)
    }

    @objc func onAddClick() {
        presentCreateEditViewController(create: true)
    }

    @objc func onDeleteClick() {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            tableView.endEditing(true)
        } else {
            tableView.setEditing(true, animated: true)
        }
    }

    @IBAction func onOptionClicked(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? AccountsTableViewCell {
            let name = cell.nameLabel.text!
            presentCreateEditViewController(create: false, name: name)
        }
    }

    private func presentCreateEditViewController(create: Bool, name: String? = nil) {
        tableView.setEditing(false, animated: true)
        tableView.endEditing(true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreateViewController") as! CreateViewController

        controller.isCreate = create
        controller.entryName = name ?? ""

        switch (listType!) {
        case .ACCOUNT:
            controller.createType = SelectType.ACCOUNT
        case .CATEGORY:
            controller.createType = SelectType.CATEGORY
        case .VENDOR:
            controller.createType = SelectType.VENDOR
        case .TAG:
            controller.createType = SelectType.TAG
        }
        controller.delegate = self

        presentPopOver(controller)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func creationCallback(created: Bool) {
        //if created {
        //    getEntries()
        //    tableView.reloadData()
        //}
    }
}
