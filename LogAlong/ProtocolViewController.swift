//
//  ProtocolViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/31/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit

protocol FViewControllerDelegate: class {
    func passNumberBack(_ caller: UIViewController, type: TypePassed)
}

protocol FTableViewControllerDelegate: class {
    func getId(name: String)
}
