//
//  CollectionListController.swift
//  CAWReader
//
//  Created by wbuntu on 5/12/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit
import Alamofire
class CollectionListController:BaseController, UITableViewDelegate, UITableViewDataSource {
    var tableView:UITableView!
    let identifier = "bookCell"
    var dataArray:[bookModel]{
        get{
            return WWMemory.shared.userShelf!
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadNotifiation), name: kModifyCollectListNotification, object: nil)
        tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        tableView.backgroundColor = commonBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 164.5
        tableView.registerClass(BookListCell.self, forCellReuseIdentifier: self.identifier)
        self.view.addSubview(tableView)
    }
    func reloadNotifiation() -> Void{
        tableView.reloadData()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.identifier, forIndexPath: indexPath) as! BookListCell
        let book:bookModel = dataArray[indexPath.row]
        cell.configureCellWithBook(book)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let book = dataArray[indexPath.row]
        let controller:BookInfoController = BookInfoController()
        controller.book = book
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            let book = dataArray[indexPath.row]
            deleteBookAtIndexPath(book, indexPath: indexPath)
        }
    }
    
    func deleteBookAtIndexPath(book:bookModel, indexPath:NSIndexPath) ->Void{
        let dic:Dictionary<String,String> = ["userId":WWMemory.shared.userId!,
                                             "bookId":"\(book.bookid)",
                                             "method":"remove"]
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
                        if let index = WWMemory.shared.userShelf!.indexOf(book){
                            WWMemory.shared.userShelf!.removeAtIndex(index)
                        }
                        strongSelf.tableView.beginUpdates()
                        strongSelf.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        strongSelf.tableView.endUpdates()
                        NSNotificationCenter.defaultCenter().postNotificationName(kModifyShelfNotification, object: nil)
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