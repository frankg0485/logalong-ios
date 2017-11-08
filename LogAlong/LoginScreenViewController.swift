//
//  LoginScreenViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 11/6/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LoginScreenViewController: UIViewController, FNotifyLoginViewControllerDelegate {

    var delegate: FLoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func notifyShowHideNameCell(hide: Bool) {
        if (hide == true) {
            delegate?.showHideNameCell(hide: true)
        } else {
            delegate?.showHideNameCell(hide: false)
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondViewController = segue.destination as? CreateOrLoginTableViewController {
            secondViewController.delegate = self
        } else if let secondViewController = segue.destination as? LoginInfoTableViewController {
            delegate = secondViewController
        }

    }

}
