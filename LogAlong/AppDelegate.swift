//
//  AppDelegate.swift
//  LogAlong
//
//  Created by Frank Gao on 3/6/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var shouldRotate = false
    var window: UIWindow?
    let uiRequest = UiRequest.instance
    let service = LService.instance

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)

        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.white
        }

        service.start()
        LServer.instance.delegate = LProtocol.instance

        if LPreferences.getUserIdNum() > 0 {
            LServer.instance.connect()
        }

        //DEBUG CODE
        //_ = DBTransaction.instance.deleteAll()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            self.endBackgroundTask(true)
        }
    }

    func endBackgroundTask(_ done: Bool) {
        LLog.d("\(self)", "Background task ended.")
        if (backgroundTask != UIBackgroundTaskInvalid) {
            if done {
                LServer.instance.disconnect()
            }
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }

    var workItem: DispatchWorkItem?
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        LLog.d("\(self)", "going to background, remaining: \(UIApplication.shared.backgroundTimeRemaining)")
        if let wi = workItem {
            wi.cancel()
        }

        registerBackgroundTask()
        workItem = DispatchWorkItem {
            DBAccountBalance.rescan()

            DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
                self.endBackgroundTask(true)
            })
        }
        DispatchQueue.global(qos: .default).async(execute: workItem!)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if shouldRotate {
            DispatchQueue.main.async {
                UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
            }
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //DBAccountBalance.rescanCancel()
        endBackgroundTask(false)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if uiRequest.state == .DISCONNECTED && LPreferences.getUserIdNum() > 0 {
            LLog.d("\(self)", "connection lost: reconnecting ...")
            LServer.instance.connect()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //LLog.d("\(self)", "going to terminate")
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return shouldRotate ? .allButUpsideDown : .portrait
        /*
        if let rootViewController = self.topViewControllerWithRootViewController(window?.rootViewController) {
            if (rootViewController.responds(to: Selector(("canRotate")))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown;
            }
        }

        // Only allow portrait (standard behaviour)
        return .portrait;
         */
    }

    /*
    private func topViewControllerWithRootViewController(_ rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if rootViewController.isKind(of: UITabBarController.self) {
            return topViewControllerWithRootViewController((rootViewController as! UITabBarController).selectedViewController)
        } else if rootViewController.isKind(of: UINavigationController.self) {
            return topViewControllerWithRootViewController((rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController.presentedViewController)
        }
        return rootViewController
    }
     */

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LLog.d("\(self)", "perform background fetching ...")
        //simply let system run for 15 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
            completionHandler(UIBackgroundFetchResult.newData)
        })
    }
}
