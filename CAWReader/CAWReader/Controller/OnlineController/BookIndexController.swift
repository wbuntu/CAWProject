//
//  BookIndexController.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/6.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import Alamofire
class BookIndexController: BaseController, UITableViewDelegate, UITableViewDataSource {
    var book:bookModel?
    var index:indexModel?
    var volumeArray:Array<volumeModel> = Array<volumeModel>()
    var tableView:UITableView?
    let identifier:String = "kBookIndexCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = book?.title
        self.tableView = UITableView(frame: self.view.bounds, style: .Grouped)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.tableView!.tableFooterView = UIView()
        self.tableView!.registerClass(BookIndexCell.self, forCellReuseIdentifier: self.identifier)
        self.view.addSubview(self.tableView!)
        self.fetchBookIndex()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.enabled = true
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
                            let controller:ReaderControlletr = ReaderControlletr()
                            controller.book = strongSelf.book
                            controller.volumeArray = strongSelf.volumeArray
                            controller.chapterId = chapter.chapterId
                            controller.currentChapterIndexPath = indexPath
                            strongSelf.hidesBottomBarWhenPushed = true
                            strongSelf.navigationController?.setNavigationBarHidden(true, animated: false)
                            
                            let transition:CATransition = CATransition()
                            transition.duration = 0.4
                            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                            transition.type = kCATransitionFade
                            strongSelf.navigationController?.view.layer.addAnimation(transition, forKey: nil)
                            
                            strongSelf.navigationController?.pushViewController(controller, animated: false)
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
    
    func fetchBookIndex() -> Void{
        self.hud.show()
        Alamofire.request(.GET, CAWResourceAddress+"/index/"+String(self.book!.sfid)+".json")
            .responseData {[weak self] response in
                if let strongSelf = self{
                    switch response.result {
                    case .Success:
                        strongSelf.index = try! indexModel(data: response.data)
                        strongSelf.volumeArray = (strongSelf.index?.volumes as? Array<volumeModel>)!
                        if strongSelf.volumeArray.count > 0{
                            strongSelf.hud.dismiss()
                        }else{
                            strongSelf.hud.showImage(nil, status: "暂无章节数据")
                        }
                        strongSelf.tableView!.reloadData()
                    case .Failure(let error):
                        let description = error.localizedDescription
                        strongSelf.hud.showErrorWithString(description)
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}










