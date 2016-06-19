//
//  CategoryController.swift
//  CAWReader
//
//  Created by wbuntu on 5/8/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit
protocol CategoryControllerDelegate:NSObjectProtocol {
    func didSelectSort(sort:String) -> Void
}
class CategoryController: UITableViewController {
    weak var delegate:CategoryControllerDelegate!
    var visualEffectView:UIVisualEffectView!
    let identifier = "kIdentifier"
    let dataArray:Array<String> = ["冒险类","爱情类","惊悚类","魔幻类","科幻类","机战类","社会类","校园类","热血类","武侠类","推理类","搞笑类","温情类","运动类","同人类"]
    override func viewDidLoad() {
        super.viewDidLoad()
        visualEffectView = UIVisualEffectView(frame: self.tableView.bounds)
        visualEffectView.effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        self.tableView.backgroundView = visualEffectView
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: identifier)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        cell.textLabel?.textColor = commonTintColor
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = dataArray[indexPath.row]
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sort = dataArray[indexPath.row]
        delegate.didSelectSort(sort)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
