//
//  MainViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 3/6/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var headerView: HorizontalLayout!
    @IBOutlet weak var tableView: UITableView!
    let ADD_BUTTON_EXTRA_SPACE: CGFloat = 120

    var labelBalance: UILabel!
    var addBtn: UIButton!
    var dismissable = false
    var accountBalances = LAccountBalances()
    var timer = Timer()
    var shareViewPresented = false
    var isVisible = false
    var isRefreshPending = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwipe()
        tableView.dataSource = self
        tableView.delegate = self
        setupNavigationBarItems()
        createHeader()

        navigationController?.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: LTheme.Color.warn_text_color], for: .normal)

        accountBalances.scan()
        labelBalance.textColor = accountBalances.total >= 0 ? LTheme.Color.base_green : LTheme.Color.base_red
        labelBalance.text = String(format: "%.2f", abs(accountBalances.total))
        labelBalance.sizeToFit()

        tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()


        LBroadcast.register(LBroadcast.ACTION_LOG_IN, cb: #selector(self.login), listener: self)
        //TODO: should we 'unregister' this listener according to viewcontroller life cycle?
        LBroadcast.register(LBroadcast.ACTION_NETWORK_CONNECTED,
                            cb: #selector(self.networkConnected),
                            listener: self)
        LBroadcast.register(LBroadcast.ACTION_UI_SHARE_ACCOUNT, cb: #selector(self.shareAccountRequest), listener: self)

        LBroadcast.register(LBroadcast.ACTION_UI_DB_DATA_CHANGED,
                            cb: #selector(self.dbDataChanged),
                            listener: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        isVisible = true
        if isRefreshPending {
            refreshAll()
        }

        super.viewDidAppear(animated)
        if let request = LPreferences.getAccountShareRequest() {
            presentShareView(request)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        isVisible = false
        super.viewDidDisappear(animated)
    }

    @objc func dbDataChanged(notification: Notification) -> Void {
        //LLog.d("\(self)", "db changed")
        refreshAll()
    }

    private func refreshAll() {
        if isVisible {
            isRefreshPending = false

            accountBalances.scan()
            labelBalance.textColor = accountBalances.total >= 0 ? LTheme.Color.base_green : LTheme.Color.base_red
            labelBalance.text = String(format: "%.2f", abs(accountBalances.total))
            labelBalance.sizeToFit()

            tableView.reloadData()
        } else {
            isRefreshPending = true
        }
    }

    func onShareAccountConfirmDialogExit(_ ok: Bool, _ request: LAccountShareRequest) {
        shareViewPresented = false

        _ = LJournal.instance.confirmAccountShare(aid: request.accountGid, uid: request.userId, yes: ok)

        LPreferences.deleteAccountShareRequest(request: request)

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkForRequest), userInfo: nil, repeats: false)
    }

    @objc func checkForRequest() {
        if let request = LPreferences.getAccountShareRequest() {
            presentShareView(request)
        }
    }

    func presentShareView(_ request: LAccountShareRequest) {
        if shareViewPresented {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AccountShareRequest") as! ShareAccountConfirmViewController

        controller.modalPresentationStyle = UIModalPresentationStyle.popover
        controller.popoverPresentationController?.delegate = self
        controller.preferredContentSize = CGSize(width: 375, height: 230)

        controller.accountUserLabelText = "\(request.accountName) : \(request.userName) (\(request.userFullName))"
        controller.request = request

        let popoverPresentationController = controller.popoverPresentationController

        if let _popoverPresentationController = popoverPresentationController {
            // set the view from which to pop up
            _popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
            _popoverPresentationController.sourceView = self.view;
            _popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            // present (id iPhone it is a modal automatic full screen)
            dismissable = false

            shareViewPresented = true
            self.present(controller, animated: true, completion: nil)
        }
    }

    @objc func handleGestureLeft(_ gesture: UIGestureRecognizer) {
        tabBarController?.selectedIndex = 2
    }
    @objc func handleGestureRight(_ gesture: UIGestureRecognizer) {
        tabBarController?.selectedIndex = 0
    }

    private func setupSwipe() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGestureLeft(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGestureRight(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }

    private func setupNavigationBarItems() {
        let BTN_W: CGFloat = LTheme.Dimension.bar_button_width
        let BTN_H: CGFloat = LTheme.Dimension.bar_button_height
        //let BTN_S: CGFloat = LTheme.Dimension.bar_button_space

        navigationItem.titleView = UIView()

        addBtn = UIButton(type: .system)
        addBtn.addTarget(self, action: #selector(self.onAddClick), for: .touchUpInside)
        addBtn.setImage(#imageLiteral(resourceName: "ic_action_new").withRenderingMode(.alwaysOriginal), for: .normal)
        addBtn.setSize(w: BTN_W + ADD_BUTTON_EXTRA_SPACE, h: BTN_H)
        addBtn.imageEdgeInsets = UIEdgeInsetsMake(0, ADD_BUTTON_EXTRA_SPACE, 0, 0)

        let scheduleBtn = UIButton(type: .system)
        scheduleBtn.addTarget(self, action: #selector(self.onScheduleClick), for: .touchUpInside)
        scheduleBtn.setImage(#imageLiteral(resourceName: "ic_action_alarms").withRenderingMode(.alwaysOriginal), for: .normal)
        scheduleBtn.setSize(w: BTN_W, h: BTN_H)
        //scheduleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: scheduleBtn)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addBtn)
        //UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onAddClick))

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = LTheme.Color.top_bar_background
        navigationController?.navigationBar.barStyle = .black
    }

    private func createHeader()
    {
        headerView.backgroundColor = LTheme.Color.balance_header_bgd_color

        let fontsize: CGFloat = LTheme.Dimension.balance_header_font_size
        let labelHeader = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        labelHeader.layoutMargins = UIEdgeInsetsMake(0, LTheme.Dimension.balance_header_left_margin, 0, 0)
        //labelHeader.font = labelHeader.font.withSize(fontsize)
        labelHeader.font = UIFont.boldSystemFont(ofSize: fontsize)
        labelHeader.text = NSLocalizedString("Balance", comment: "")
        labelHeader.sizeToFit()

        labelBalance = UILabel(frame: CGRect(x: 1, y: 0, width: 100, height: 25))
        labelBalance.textAlignment = .right
        labelBalance.layoutMargins = UIEdgeInsetsMake(0, 0, 0, LTheme.Dimension.balance_header_right_margin)
        labelBalance.font = labelBalance.font.withSize(fontsize)
        labelBalance.sizeToFit()

        headerView.addSubview(labelHeader)
        headerView.addSubview(labelBalance)
    }

    @objc func onAddClick() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewAdditionTableViewController")
            as? NewAdditionTableViewController {

            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            vc.popoverPresentationController?.sourceView = addBtn
            vc.popoverPresentationController?.sourceRect = CGRect(x: addBtn.bounds.midX + ADD_BUTTON_EXTRA_SPACE,
                                                                  y: addBtn.bounds.maxY, width: 0, height: 0)

            vc.popoverPresentationController?.permittedArrowDirections = .up
            vc.popoverPresentationController!.delegate = self

            vc.myNavigationController = self.navigationController

            //149 = 3 * 50 (cell height) - 1 (cell separator height): so to hide the last cell separator
            vc.preferredContentSize = CGSize(width: 140, height: 149)

            dismissable = true

            self.present(vc, animated: true, completion: nil)
        }
    }

    @objc func onScheduleClick() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SchedulesTableViewController")
            as! SchedulesTableViewController

        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func shareAccountRequest(notification: Notification) -> Void {
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    if let request = LPreferences.getAccountShareRequest() {
                        presentShareView(request)
                    }
                }
            }
        }
    }

    @objc func networkConnected(notification: Notification) -> Void {
        navigationController?.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        navigationController?.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.blue], for: .selected)
        LLog.d("\(self)", "network connected")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return dismissable
    }

    @objc func login(notification: Notification) -> Void {
        if let bdata = notification.userInfo as? [String: Any] {
            if let status = bdata["status"] as? Int {
                if LProtocol.RSPS_OK == status {
                    return
                }
            }
        }

        presentPasswordPopover()
    }

    func presentPasswordPopover() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrentPasswordViewController") as!CurrentPasswordViewController

        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect =
            CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 22, width: 0, height: 0)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        vc.popoverPresentationController!.delegate = self

        vc.canCancel = false
        present(vc, animated: true, completion: nil)
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return accountBalances.accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountBalance", for: indexPath) as? MainTableViewCell

        let ab = accountBalances.balances[indexPath.row]
        let a = accountBalances.accounts[indexPath.row]
        cell?.nameLabel.text = a.name
        cell?.nameLabel.sizeToFit()

        let balanceLabel = cell?.balance
        let amount = ab.getLatestBalance()
        balanceLabel?.textColor = (amount > 0) ? LTheme.Color.base_green : LTheme.Color.base_red
        balanceLabel?.text = String(format: "%.2f", abs(amount))
        balanceLabel?.sizeToFit()
        return cell!
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
