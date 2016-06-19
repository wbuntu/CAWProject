//
//  ReaderBookmarkController.swift
//  CAWReader
//
//  Created by wbuntu on 5/13/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit
import MJRefresh
protocol ReaderBookmarkControllerDelegate:NSObjectProtocol {
    func cancelAddingBookmark() ->Void
    func didSelectBookmark(row:Int) ->Void
}

class ReaderBookmarkController: BaseController, UITableViewDelegate, UITableViewDataSource {
    var currentString:String!
    var currentRow:String!
    var currentChapter:String!
    var currentLocation:Int!
    var rangeArray:Array<NSRange>!
    weak var delegate:ReaderBookmarkControllerDelegate!
    var currentMark:(NSAttributedString,Int)!
    var dataArray:[(NSAttributedString,Int)] = [(NSAttributedString,Int)]()
    var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, screenWidth, screenHeight-64-49), style: .Grouped)
    let identifier:String = "kBookmarkCell"
    var isOnScreen:Bool = false
    let addButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named:"addMark"), forState: .Normal)
        button.showsTouchWhenHighlighted = false
        button.frame = CGRectMake(15, screenHeight-64-49, 49, 49)
        return button
    }()
    let bookmarkButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named:"bookmarkEmpty"), forState: .Normal)
        button.showsTouchWhenHighlighted = false
        button.frame = CGRectMake(screenWidth-15-49, screenHeight-64-49, 49, 49)
        return button
    }()
    let token:String = "\u{FFFC}"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRectMake(0,0,100,50))
        label.font = UIFont.systemFontOfSize(20)
        label.textAlignment = .Center
        label.textColor = UIColor.grayColor()
        label.backgroundColor = UIColor.clearColor()
        label.text = "暂无书签"
        
        label.center = self.view.center
        self.view.addSubview(label)
        
        tableView.registerClass(ReaderSearchCell.self, forCellReuseIdentifier: identifier)
        tableView.backgroundColor = commonBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 52.5
        tableView.tableFooterView = UIView()
        tableView.mj_header = MJRefreshStateHeader()
        
        self.view.addSubview(tableView)
        
        self.view.addSubview(addButton)
        addButton.addTarget(self, action: #selector(addMark), forControlEvents: .TouchUpInside)
        self.view.addSubview(bookmarkButton)
        bookmarkButton.addTarget(self, action: #selector(hideBookmark), forControlEvents: .TouchUpInside)
    }
    
    func configureBookmark(textcontent:NSString,currentRow:Int,chapterId:String,ranges:Array<NSRange>) ->Void{
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            self.currentChapter = chapterId
            let currentRange = ranges[currentRow]
            self.currentLocation = currentRange.location
            var currentStr:String!
            let currentTempStr = textcontent.substringWithRange(currentRange) as NSString
            if currentRange.length>12{
                currentStr = currentTempStr.substringToIndex(12)
            }else{
                currentStr = currentTempStr as String
            }
            if (currentStr.stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString(self.token, withString: "") as NSString).length == 0{
                currentStr = "插图"
            }
            let currentAtt:NSMutableAttributedString = NSMutableAttributedString(string: currentStr, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)])
            self.currentMark = (currentAtt,currentRow)
            
            self.dataArray = [(NSAttributedString,Int)]()
            var enbaleAdd:Bool = true
            
            if let mark = WWMemory.shared.bookmarks![chapterId]{
                let bookmarks:[String] = mark.componentsSeparatedByString(",")
                for singleMark in bookmarks {
                    let markLocation = Int(singleMark)!
                    if markLocation == currentRow{
                        enbaleAdd = false
                    }
                    var index:Int = 0
                    for range in ranges{
                        if NSLocationInRange(markLocation, range){
                            var tempStr:String!
                            if markLocation+12<textcontent.length{
                                tempStr = textcontent.substringWithRange(NSMakeRange(markLocation, 12))
                            }else{
                                tempStr = textcontent.substringFromIndex(markLocation)
                            }
                            
                            if (tempStr.stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString(self.token, withString: "") as NSString).length == 0{
                                tempStr = "插图"
                            }else{
                                tempStr = tempStr+"..."
                            }
                            
                            let att:NSMutableAttributedString = NSMutableAttributedString(string: tempStr, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)])
                            self.dataArray.append((att,index))
                        }
                        index += 1
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.addButton.enabled = enbaleAdd
                if self.dataArray.count>0{
                    self.tableView.hidden = false
                    self.tableView.reloadData()
                }else{
                    self.tableView.hidden = true
                }
            })
        }
    }
    
    func addMark() ->Void{
        if let mark = WWMemory.shared.bookmarks![currentChapter]{
            WWMemory.shared.bookmarks![currentChapter] = mark+","+"\(currentLocation)"
        }else{
            WWMemory.shared.bookmarks![currentChapter] = "\(currentLocation)"
        }
        tableView.hidden = false
        addButton.enabled = false
        dataArray.append(currentMark)
        tableView.reloadData()
//        let indexPath = NSIndexPath(forRow: dataArray.count-1, inSection: 0)
//        tableView.beginUpdates()
//        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//        tableView.endUpdates()
    }
    
    func hideBookmark() ->Void{
        delegate.cancelAddingBookmark()
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
        let row = dataArray[indexPath.row].1
        delegate.didSelectBookmark(row)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            let tuple = dataArray[indexPath.row]
            if tuple.1 == currentMark.1{
                addButton.enabled = true
            }
            dataArray.removeAtIndex(indexPath.row)
            var mark:[String] = WWMemory.shared.bookmarks![currentChapter]!.componentsSeparatedByString(",")
            mark.removeAtIndex(indexPath.row)
            WWMemory.shared.bookmarks![currentChapter] = mark.joinWithSeparator(",")
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.endUpdates()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
