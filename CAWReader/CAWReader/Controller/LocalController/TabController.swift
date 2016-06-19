//
//  TabController.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/4.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class TabController: UITabBarController {    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = commonBackgroundColor
        self.tabBar.translucent = false
        self.tabBar.backgroundColor = commonBackgroundColor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.showLibrary), name: showLibraryNofification, object: nil)
        self.tabBar.tintColor = commonTintColor
        let discover = UINavigationController(rootViewController: DiscoverController())
        let shelf = UINavigationController(rootViewController: ShelfController())
        let me = UINavigationController(rootViewController: MeController())
        self.viewControllers = [discover,shelf,me]
        self.selectedIndex = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit{
       NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func showLibrary() -> Void{
        let controller:LibraryIndexController = LibraryIndexController()
        let navi:UINavigationController = UINavigationController(rootViewController: controller)
        self.presentViewController(navi, animated: true, completion: nil)
    }
    
    func showLoginController() -> Void{
        let controller = LoginController()
        controller.tabController = self
        self.presentViewController(controller, animated: true) { 
            self.selectedIndex = 1
        }
    }
}
