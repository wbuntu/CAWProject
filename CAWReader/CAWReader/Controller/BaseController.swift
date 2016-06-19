//
//  BaseController.swift
//  CAWReader
//
//  Created by wbuntu on 16/3/27.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import WSProgressHUD
class BaseController: UIViewController {
    lazy var hud: WSProgressHUD = {
        let tempHud:WSProgressHUD = WSProgressHUD(view: self.view)
        self.view.addSubview(tempHud)
        return tempHud
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.edgesForExtendedLayout = .None
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.frame.size.height -= 64
        self.view.backgroundColor = commonBackgroundColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
