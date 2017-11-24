//
//  LoginScreenViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/6/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LoginScreenViewController: UIViewController, FNotifyLoginViewControllerDelegate, FPassNameIdPasswordDelegate, UIPopoverPresentationControllerDelegate {

    var delegate: FLoginViewControllerDelegate?

    var nameCellHidden: Bool = false

    var name: String? = ""
    var userId: String = ""
    var password: String = ""
    var loginType: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            delegate?.showHideNameCell(hide: true)
        } else {
            nameCellHidden = false
            delegate?.showHideNameCell(hide: false)
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
        } else if let secondViewController = segue.destination as? LoginInfoTableViewController {
            delegate = secondViewController
            secondViewController.delegate = self
        } else if let secondViewController = segue.destination as? LoginTimerViewController {
            let popoverViewController = segue.destination

            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover

            popoverViewController.popoverPresentationController!.delegate = self

            secondViewController.name = name
            secondViewController.userId = userId
            secondViewController.password = password
            secondViewController.typeOfLogin = loginType
        }

    }

}
