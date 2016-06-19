//
//  MeController.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/4.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class MeController: BaseController, UITableViewDelegate, UITableViewDataSource {
    let collectIdentifier = "collectIdentifier"
    let headerCellIdnetifier = "headerIdentifier"
    let exitIdnetifier = "exitIdnetifier"
    let versionIdentifier = "versionIdentifier"
    let settingIdentifier = "MeSettingCell"
    var tableView:UITableView!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let meItem = UITabBarItem(title: "我", image: UIImage(named: "user")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), selectedImage: UIImage(named: "user_selected")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
        self.tabBarItem = meItem
        
        tableView = UITableView(frame: self.view.bounds, style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = commonBackgroundColor
        
        tableView.registerClass(MeCollectCell.self, forCellReuseIdentifier: collectIdentifier)
        tableView.registerClass(MeHeaderCell.self, forCellReuseIdentifier: headerCellIdnetifier)
        tableView.registerClass(MeVersionCell.self, forCellReuseIdentifier: versionIdentifier)
        tableView.registerClass(MeExitCell.self, forCellReuseIdentifier: exitIdnetifier)
        tableView.registerClass(MeSettingCell.self, forCellReuseIdentifier: settingIdentifier)
        tableView.separatorStyle = .None
        
        self.view.addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloginNotifiation), name: kLoginAgainNotification, object: nil)
    }
    
    func reloginNotifiation() -> Void{
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0001
        }
        return 30
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 136.5
        }else{
            return 44.5
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(headerCellIdnetifier, forIndexPath: indexPath) as! MeHeaderCell
            cell.nameLabel.text = WWMemory.shared.userName
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(collectIdentifier, forIndexPath: indexPath)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(settingIdentifier, forIndexPath: indexPath)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier(versionIdentifier, forIndexPath: indexPath)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier(exitIdnetifier, forIndexPath: indexPath)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            let controller = CollectionListController()
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
            self.hidesBottomBarWhenPushed = false
        case 2:
            let controller = SettingController()
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
            self.hidesBottomBarWhenPushed = false
        case 4:
            if let tabBarController:TabController = self.tabBarController as? TabController{
                tabBarController.showLoginController()
            }
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

