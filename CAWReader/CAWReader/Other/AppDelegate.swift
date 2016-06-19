//
//  AppDelegate.swift
//  CAWReader
//
//  Created by wbuntu on 16/3/27.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import CryptoSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().setBackgroundImage(UIImage.fromColor(UIColor(white: 0.95, alpha: 1.0)), forBarPosition: .Any, barMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = commonTintColor
        
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor();
        if WWMemory.shared.isLogin!{
            let rootController:TabController = TabController()
            window?.rootViewController = rootController
        }else{
            let rootController:LoginController = LoginController()
            window?.rootViewController = rootController 
        }
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        WWMemory.shared.save()

    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        WWMemory.shared.save()

    }


}
extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}


