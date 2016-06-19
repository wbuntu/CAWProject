//
//  ReaderSearchController.swift
//  CAWReader
//
//  Created by wbuntu on 5/13/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit

protocol ReaderSearchControllerDelegate:NSObjectProtocol {
    func didSelectItem(row:Int) ->Void
}

class ReaderSearchController: BaseController,UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    weak var delegate:ReaderSearchControllerDelegate!
    var tableView:UITableView!
    var string:NSString!
    var rangeArray:[NSRange]!
    var dataArray:[(NSAttributedString,Int)] = [(NSAttributedString,Int)]()
    let searchBar:UISearchBar = {
        let bar = UISearchBar()
        bar.backgroundImage = UIImage()
        bar.placeholder = "全文搜索"
        bar.tintColor = commonTintColor
        return bar
    }()
    let identifier:String = "identifier"
    override func viewDidLoad() {
        super.viewDidLoad()
        let closeButton = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(exitCurrentController))
        self.navigationItem.rightBarButtonItem = closeButton
        
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        tableView = UITableView(frame: self.view.bounds, style: .Grouped)
        tableView.registerClass(ReaderSearchCell.self, forCellReuseIdentifier: identifier)
        tableView.backgroundColor = commonBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 52.5
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        
        searchBar.becomeFirstResponder()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! ReaderSearchCell
        let tuple = dataArray[indexPath.row]
        cell.configure(tuple)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        delegate.didSelectItem(row)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            searchResult(searchBar.text!)
        }
    }
    func searchResult(keyword:String) ->Void{
        hud.show()
        var index = 0
        let padding:Int = 6
        for range in rangeArray{
            let str = string.substringWithRange(range) as NSString
            if str.containsString(keyword){
                var ra = str.rangeOfString(keyword)
                let originalLocation = ra.location
                if ra.location-padding>0{
                    ra.location -= padding
                }else{
                    ra.location = 0
                }
                
                if originalLocation+ra.length+padding < str.length{
                    ra.length += padding*2
                }else{
                    ra.length = str.length - ra.location - 1
                }
                
                let tempStr = str.substringWithRange(ra)+"..."
                
                let tempRa = (tempStr as NSString).rangeOfString(keyword)
                let att:NSMutableAttributedString = NSMutableAttributedString(string: tempStr, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)])
                att.addAttributes([NSForegroundColorAttributeName:commonTintColor], range: tempRa)
                let tuple = (att as NSAttributedString,index)
                dataArray.append(tuple)
            }
            index += 1
        }
        if dataArray.count>0{
            hud.dismiss()
        }else{
            hud.showImage(nil, status: "木有结果")
        }
        tableView.reloadData()
    }
    func exitCurrentController() ->Void{
        self.searchBar.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
