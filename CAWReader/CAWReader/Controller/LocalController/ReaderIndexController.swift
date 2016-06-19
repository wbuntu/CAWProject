//
//  ReaderIndexController.swift
//  CAWReader
//
//  Created by wbuntu on 5/13/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit
import Alamofire

protocol ReaderIndexControllerDelegate: NSObjectProtocol {
    func didSelectValidChapter(chapterId:String, indexPath:NSIndexPath) ->Void
    func cancelIndexSelection() ->Void
}

class ReaderIndexController: BaseController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate:ReaderIndexControllerDelegate!
    var book:bookModel!
    var volumeArray:Array<volumeModel>!
    var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, screenWidth, screenHeight-64-49), style: .Grouped)
    let identifier:String = "kBookIndexCell"
    var isOnScreen:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = book.title
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.tableView.tableFooterView = UIView()
        self.tableView.registerClass(BookIndexCell.self, forCellReuseIdentifier: self.identifier)
        self.view.addSubview(self.tableView)
        
        let button:UIButton = UIButton(type: .Custom)
        button.frame = CGRectMake(15, screenHeight-64-49, 49, 49)
        button.setImage(UIImage(named: "cancel"), forState: .Normal)
        button.showsTouchWhenHighlighted = false
        button.addTarget(self, action: #selector(cancelSelection), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.volumeArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let volume:volumeModel = self.volumeArray[section]
        return volume.chapters.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let volmue:volumeModel = self.volumeArray[section]
        return volmue.volumeTitle
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.identifier, forIndexPath: indexPath) as! BookIndexCell
        let chapter:vChapter = self.volumeArray[indexPath.section].chapters[indexPath.row] as! vChapter
        cell.configureCellWithChapter(chapter)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chapter:vChapter = self.volumeArray[indexPath.section].chapters[indexPath.row] as! vChapter
        self.hud.show()
        Alamofire.request(.HEAD, CAWResourceAddress+"/content/"+chapter.chapterId+".json")
            .responseData {[weak self] response in
                if let strongSelf = self{
                    switch response.result {
                    case .Success:
                        if response.response?.statusCode == 200{
                            strongSelf.hud.dismiss()
                            strongSelf.delegate.didSelectValidChapter(chapter.chapterId, indexPath: indexPath)
                        }else{
                            strongSelf.hud.showImage(nil, status: "文件不存在")
                        }
                    case .Failure(let error):
                        let description = error.localizedDescription
                        strongSelf.hud.showErrorWithString(description)
                    }
                    
                }
        }
    }
    func cancelSelection() ->Void{
        delegate.cancelIndexSelection()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
