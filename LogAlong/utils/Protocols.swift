//
//  Protocols.swift
//  LogAlong
//
//  Created by Frank Gao on 5/31/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

protocol FViewControllerDelegate: class {
    func passNumberBack(_ caller: UIViewController, type: TypePassed, okPressed: Bool)
}
/*
protocol FLoginViewControllerDelegate: class {
    func showHideNameCell(hide: Bool)
}

protocol FNotifyLoginViewControllerDelegate: class {
    func notifyShowHideNameCell(hide: Bool)
}
*/
protocol FPassCreationBackDelegate: class {
    func creationCallback(created: Bool)
}
/*
protocol FPassNameIdPasswordDelegate: class {
    func passLoginInfoBack(name: String?, id: String, password: String, typeOfLogin: Int)
}

protocol FNotifyReloadLoginScreenDelegate: class {
    func notifyReloadLoginScreen()
}

protocol FReloadLoginScreenDelegate: class {
    func reloadLoginScreen()
}

protocol FLoginTypeDelegate: class {
    func getFinalLoginType() -> Int
}

protocol FNotifyShowPasswordDelegate: class {
    func showPassword(show: Bool)
}
*/
protocol FShowPasswordCellsDelegate: class {
    func showPasswordCells()
}
/*
protocol FDisableEnableDoneButtonDelegate: class {
    func disEnaDoneButton(_ enable: Bool)
}
 */
