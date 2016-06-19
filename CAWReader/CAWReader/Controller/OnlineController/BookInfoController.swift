//
//  BookInfoController.swift
//  CAWReader
//
//  Created by wbuntu on 4/3/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit
import Alamofire
import CryptoSwift
class BookInfoController: BaseController, UITableViewDelegate, UITableViewDataSource, BookInfoCellBaseDelegate {
    var book:bookModel?
    var tableView:UITableView?
    let headIdentifier:String = "kBookInfoCellHead"
    let indexIdnetifier:String = "kBookInfoCellIndex"
    let introIdnetifier:String = "kBookInfoCellIntro"
    let introHeadIdnetifier:String = "kBookInfoCellIntroHead"
    let tagIdnetifier:String = "kBookInfoCellTag"
    let otherIdnetifier:String = "kBookInfoCellOther"
    let infoIdnetifier:String = "kBookInfoCellInfo"
    let starButton:UIButton = UIButton(type: UIButtonType.Custom)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.book?.title
        if self.navigationController?.viewControllers.count == 1{
            let leftBarButton = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.dismissCurrentController))
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
        starButton.frame = CGRectMake(0, 0, 33, 33)
        starButton.addTarget(self, action: #selector(self.starBook(_:)), forControlEvents: .TouchUpInside)
        starButton.setImage(UIImage(named: "unstar"), forState: .Normal)
        starButton.setImage(UIImage(named: "star"), forState: .Selected)
        let rightBarButton = UIBarButtonItem(customView: starButton)
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if WWMemory.shared.userShelf!.contains(book!){
            starButton.selected = true
        }else{
            starButton.selected = false
        }
        
        self.tableView = UITableView(frame: self.view.bounds, style: .Grouped)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        self.tableView!.showsVerticalScrollIndicator = false
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.estimatedRowHeight = 100.0
        self.tableView!.tableFooterView = UIView()
        
        self.tableView!.registerClass(BookInfoCellHead.self, forCellReuseIdentifier: self.headIdentifier)
        self.tableView!.registerClass(BookInfoCellIndex.self, forCellReuseIdentifier: self.indexIdnetifier)
        self.tableView!.registerClass(BookInfoCellIntroHead.self, forCellReuseIdentifier: self.introHeadIdnetifier)
        self.tableView!.registerClass(BookInfoCellIntro.self, forCellReuseIdentifier: self.introIdnetifier)
        self.tableView!.registerClass(BookInfoCellTag.self, forCellReuseIdentifier: self.tagIdnetifier)
        self.tableView!.registerClass(BookInfoCellInfo.self, forCellReuseIdentifier: self.infoIdnetifier)
        self.view.addSubview(self.tableView!)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0001
        }else{
        return 5
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==2 {
            return 3
        }else{
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:BookInfoCellBase?
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier(self.headIdentifier) as! BookInfoCellHead
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(self.indexIdnetifier) as! BookInfoCellIndex
        case 2:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier(self.introHeadIdnetifier) as! BookInfoCellIntroHead
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier(self.introIdnetifier) as! BookInfoCellIntro
            case 2:
                cell = tableView.dequeueReusableCellWithIdentifier(self.tagIdnetifier) as! BookInfoCellTag
            default:
                break
            }
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier(self.infoIdnetifier) as! BookInfoCellInfo
        default:
            cell = nil
        }
        cell!.configureCellWithBook(self.book!)
        cell?.delegate = self
        return cell!
    }
    func BICShowBookIndex() -> Void{
        let controller:BookIndexController = BookIndexController()
        controller.book = self.book
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func BICShowBookIndexWithCache() -> Void{
        starBook(starButton)
    }
    
    func dismissCurrentController() -> Void{
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func starBook(btn:UIButton) ->Void{
        let selected = !btn.selected
        if selected{
            collectBookWithMethod("add")
        }else{
            collectBookWithMethod("remove")
        }
    }
    
    func collectBookWithMethod(method:String) ->Void{
        let dic:Dictionary<String,String> = ["userId":WWMemory.shared.userId!,
                                             "bookId":"\(book!.bookid)",
                                             "method":method]
        self.hud.show()
        self.view.userInteractionEnabled = false
        let resultStr = encodeDictionary(dic)
        Alamofire.request(.GET, CAWApiAddress+"/collect", parameters: ["req":resultStr], encoding: .URL, headers: nil).responseData {[weak self] response in
            if let strongSelf = self{
                strongSelf.view.userInteractionEnabled = true
                switch response.result {
                case .Success:
                    let data = decodeData(response.data!)
                    let resp:BookCollectResponse = try! BookCollectResponse(data: data)
                    if resp.data{
                        strongSelf.hud.dismiss()
                        strongSelf.starButton.selected = !strongSelf.starButton.selected
                        if strongSelf.starButton.selected{
                            WWMemory.shared.userShelf!.append(strongSelf.book!)
                        }else{
                            if let index = WWMemory.shared.userShelf!.indexOf(strongSelf.book!){
                                WWMemory.shared.userShelf!.removeAtIndex(index)
                            }
                        }
                        strongSelf.tableView!.reloadData()
                        NSNotificationCenter.defaultCenter().postNotificationName(kModifyShelfNotification, object: nil)
                        NSNotificationCenter.defaultCenter().postNotificationName(kModifyCollectListNotification, object: nil)
                    }else{
                        strongSelf.hud.showImage(nil, status: "操作失败")
                    }
                case .Failure(let error):
                    let description = error.localizedDescription
                    strongSelf.hud.showErrorWithString(description)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
