//
//  LoginScreenViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/6/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LoginScreenViewController: UIViewController, FNotifyLoginViewControllerDelegate, FPassNameIdPasswordDelegate, UIPopoverPresentationControllerDelegate, FNotifyReloadLoginScreenDelegate {

    var loginDelegate: FLoginViewControllerDelegate?
    var reloadLoginInfoDelegate: FReloadLoginScreenDelegate?
    var loginTypeDelegate: FLoginTypeDelegate?
    var reloadSwitchDelegate: FReloadLoginScreenDelegate?

    var nameCellHidden: Bool = false

    var name: String? = ""
    var userId: String = ""
    var password: String = ""
    var loginType: Int = 0

    @IBOutlet weak var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        if !LPreferences.getUserId().isEmpty {
            doneButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
