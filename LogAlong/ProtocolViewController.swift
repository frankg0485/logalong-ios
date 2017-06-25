//
//  ProtocolViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/31/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit

protocol FViewControllerDelegate: class {
    func passDoubleBack(_ caller: UIViewController, myDouble: Double)
}


