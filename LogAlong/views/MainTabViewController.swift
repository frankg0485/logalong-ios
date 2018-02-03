//
//  MainTabViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 6/9/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let ICON_W = LTheme.Dimension.tab_bar_icon_width
        let ICON_H = LTheme.Dimension.tab_bar_icon_height

        // Do any additional setup after loading the view.
        tabBar.barTintColor = LTheme.Color.header_color

        let img0 =  #imageLiteral(resourceName: "ic_action_go_to_today").resizedImageWithinRect(rectSize: CGSize(width: ICON_W, height: ICON_H))
        tabBar.items![0].image = img0.image(alpha: 0.5).withRenderingMode(.alwaysOriginal)
        tabBar.items![0].selectedImage = img0.withRenderingMode(.alwaysOriginal)
        tabBar.items![0].imageInsets = UIEdgeInsetsMake(8, 0, -8, 0)
        tabBar.items![0].title = ""

        tabBar.items![1].titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -12)
        //setting font here has no effect
        //tabBar.items![1].setTitleTextAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)], for: .selected)
        //tabBar.items![1].setTitleTextAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)], for: .normal)

        let img2 = #imageLiteral(resourceName: "ic_action_settings").resizedImageWithinRect(rectSize: CGSize(width: ICON_W - 1, height: ICON_H - 1))
        tabBar.items![2].image = img2.image(alpha: 0.5).withRenderingMode(.alwaysOriginal)
        tabBar.items![2].selectedImage = img2.withRenderingMode(.alwaysOriginal)
        tabBar.items![2].imageInsets = UIEdgeInsetsMake(8, 0, -8, 0)
        tabBar.items![2].title = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
