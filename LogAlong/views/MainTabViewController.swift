//
//  MainTabViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 6/9/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let ICON_W = LTheme.Dimension.tab_bar_icon_width
        let ICON_H = LTheme.Dimension.tab_bar_icon_height

        // Do any additional setup after loading the view.
        //tabBar.barTintColor = LTheme.Color.header_color

        let img0 = #imageLiteral(resourceName: "ic_action_go_to_today-dark").resizedImageWithinRect(rectSize: CGSize(width: ICON_W, height: ICON_H))
        tabBar.items![0].image = img0.image(alpha: 0.8).withRenderingMode(.alwaysOriginal)
        tabBar.items![0].selectedImage = img0.withRenderingMode(.alwaysOriginal)
        tabBar.items![0].imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        tabBar.items![0].title = ""

        tabBar.items![1].titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -12)
        //setting font here has no effect
        //tabBar.items![1].setTitleTextAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)], for: .selected)
        //tabBar.items![1].setTitleTextAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)], for: .normal)

        let img2 = #imageLiteral(resourceName: "ic_action_settings-dark").resizedImageWithinRect(rectSize: CGSize(width: ICON_W - 2, height: ICON_H - 2))
        tabBar.items![2].image = img2.image(alpha: 0.8).withRenderingMode(.alwaysOriginal)
        tabBar.items![2].selectedImage = img2.withRenderingMode(.alwaysOriginal)
        tabBar.items![2].imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        tabBar.items![2].title = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let vc = viewController as? UINavigationController {
            vc.navigationBar.barTintColor = LTheme.Color.top_bar_background
            vc.popToRootViewController(animated: true)
        }
    }
}
