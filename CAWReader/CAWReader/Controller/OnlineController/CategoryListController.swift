//
//  CategoryListController.swift
//  CAWReader
//
//  Created by wbuntu on 5/8/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import CryptoSwift

class CategoryListController: BaseController, UITableViewDelegate, UITableViewDataSource {
    var sort:String!
    var location:Int = 0
    var tableView:UITableView!
    let identifier = "bookCell"
    var dataArray:Array<bookModel> = Array<bookModel>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = sort
        tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            if let strongSelf = self{
                strongSelf.fetchInitialList()
            }
        })
        
        tableView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: {[weak self] in
            if let strongself = self{
                strongself.fetchMoreList()
            }
        })
        
        tableView.backgroundColor = commonBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 164.5
        tableView.registerClass(BookListCell.self, forCellReuseIdentifier: self.identifier)
        self.view.addSubview(tableView)
        
        tableView.mj_header.beginRefreshing()
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
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchInitialList() -> Void {
        let resultStr = encodeDictionary(["sort":sort,"location":"0"])
        Alamofire.request(.GET, CAWApiAddress+"/sort", parameters: ["req":resultStr], encoding: .URL, headers: nil).responseData {[weak self] response in
            if let strongSelf = self{
                switch response.result {
                case .Success:
                    let data = decodeData(response.data!)
                    let resp:BookListResponse = try! BookListResponse(data: data)
                    strongSelf.dataArray = resp.data as! Array<bookModel>
                    
                    strongSelf.tableView.mj_header.endRefreshing()
                    strongSelf.tableView.mj_footer.resetNoMoreData()
                    
                    strongSelf.location = strongSelf.dataArray.count
                    strongSelf.tableView.reloadData()
                case .Failure(let error):
                    let description = error.localizedDescription
                    strongSelf.hud.showErrorWithString(description)
                }
            }
        }
    }
    
    func fetchMoreList() -> Void{
        self.hud.show()
        self.view.userInteractionEnabled = false
        let resultStr = encodeDictionary(["sort":sort,"location":"\(location)"])
        Alamofire.request(.GET, CAWApiAddress+"/sort", parameters: ["req":resultStr], encoding: .URL, headers: nil).responseData {[weak self] response in
            if let strongSelf = self{
                strongSelf.view.userInteractionEnabled = true
                switch response.result {
                case .Success:
                    let data = decodeData(response.data!)
                    let resp:BookListResponse = try! BookListResponse(data: data)
                    let tempArray = resp.data as! Array<bookModel>
                    if tempArray.count > 0{
                        
                        strongSelf.dataArray.appendContentsOf(tempArray)
                        strongSelf.hud.dismiss()
                        strongSelf.tableView.mj_footer.endRefreshing()
                        strongSelf.location += strongSelf.dataArray.count
                        
                        strongSelf.tableView.reloadData()
                    }else{
                        strongSelf.hud.dismiss()
                        strongSelf.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }
                case .Failure(let error):
                    let description = error.localizedDescription
                    strongSelf.hud.showErrorWithString(description)
                }
            }
        }
    }
}