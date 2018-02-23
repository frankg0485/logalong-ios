//
//  LoginScreenViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/6/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LoginScreenViewController: UIViewController, FNotifyLoginViewControllerDelegate, FPassNameIdPasswordDelegate, UIPopoverPresentationControllerDelegate, FNotifyReloadLoginScreenDelegate, FDisableEnableDoneButtonDelegate {

    var loginDelegate: FLoginViewControllerDelegate?
    var reloadLoginInfoDelegate: FReloadLoginScreenDelegate?
    var loginTypeDelegate: FLoginTypeDelegate?
    var reloadSwitchDelegate: FReloadLoginScreenDelegate?

    var nameCellHidden: Bool = false

    var name: String? = ""
    var userId: String = ""
    var password: String = ""
    var loginType: Int = 0

    let doneButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func disEnaDoneButton(_ enable: Bool) {
        doneButton.isEnabled = enable
    }

    private func setupNavigationBarItems() {
        let BTN_W: CGFloat = LTheme.Dimension.bar_button_width
        let BTN_H: CGFloat = LTheme.Dimension.bar_button_height

        cancelButton.addTarget(self, action: #selector(self.cancelButtonClicked), for: .touchUpInside)
        cancelButton.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
        cancelButton.setSize(w: BTN_W + 20, h: BTN_H)

        doneButton.addTarget(self, action: #selector(self.doneButtonClicked), for: .touchUpInside)
        doneButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)
        doneButton.setImage(#imageLiteral(resourceName: "ic_action_accept_disabled").withRenderingMode(.alwaysOriginal), for: .disabled)
        doneButton.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0)
        doneButton.setSize(w: BTN_W + 40, h: BTN_H)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)

        doneButton.isEnabled = false

        let titleBtn = UIButton(type: .custom)
        titleBtn.setSize(w: 80, h: 30)
        titleBtn.setTitle(NSLocalizedString("Profile", comment: ""), for: .normal)
        navigationItem.titleView = titleBtn
        //navigationController?.navigationBar.isTranslucent = false
        //navigationController?.navigationBar.barStyle = .black
    }

    func notifyReloadLoginScreen() {
        viewDidLoad()
        reloadLoginInfoDelegate?.reloadLoginScreen()
        reloadSwitchDelegate?.reloadLoginScreen()
    }

    func passLoginInfoBack(name: String?, id: String, password: String, typeOfLogin: Int) {
        self.name = name
        userId = id
        self.password = password
        loginType = typeOfLogin
    }

    @objc func cancelButtonClicked(_ sender: UIBarButtonItem) {
        //dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }

    @objc func doneButtonClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "StartTimer", sender: self)
    }

    func notifyShowHideNameCell(hide: Bool) {
        if (hide == true) {
            nameCellHidden = true
            loginDelegate?.showHideNameCell(hide: true)
        } else {
            nameCellHidden = false
            loginDelegate?.showHideNameCell(hide: false)
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondViewController = segue.destination as? CreateOrLoginTableViewController {
            secondViewController.delegate = self
            reloadSwitchDelegate = secondViewController
        } else if let secondViewController = segue.destination as? LoginInfoTableViewController {
            loginDelegate = secondViewController
            reloadLoginInfoDelegate = secondViewController
            loginTypeDelegate = secondViewController
            secondViewController.delegate = self
            secondViewController.disEnaDoneButtonDelegate = self
        } else if let secondViewController = segue.destination as? LoginTimerViewController {
            let popoverViewController = segue.destination

            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover

            popoverViewController.popoverPresentationController!.delegate = self

            secondViewController.name = name
            secondViewController.userId = userId
            secondViewController.password = password
            secondViewController.loginType = (loginTypeDelegate?.getFinalLoginType())!

            secondViewController.delegate = self
        }

    }

}
