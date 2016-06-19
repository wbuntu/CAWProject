//
//  BookSearchController.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/9.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import Alamofire
import pop
class BookSearchController: BaseController, CategoryControllerDelegate {
    let searchBar:UISearchBar = UISearchBar()
    let segment:UISegmentedControl = UISegmentedControl(items: ["书名","作者"])
    let tableView = UITableView()
    var dataArray:Array<bookModel> = Array<bookModel>()
    let identifier = "kBookListCell"
    let label:UILabel = {
        let tempLabel = UILabel()
        tempLabel.backgroundColor = UIColor.clearColor()
        tempLabel.font = UIFont.systemFontOfSize(20)
        tempLabel.textColor = UIColor.grayColor()
        tempLabel.lineBreakMode = .ByWordWrapping
        tempLabel.numberOfLines = 0
        tempLabel.textAlignment = .Center
        tempLabel.text = "彼黍离离，\n彼稷之苗，\n行迈靡靡，\n中心摇摇。"
        return tempLabel
    }()
    let categoryCtrl:CategoryController = CategoryController()
    var categoryTable:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let closeBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.closeController))
        self.navigationItem.rightBarButtonItem = closeBarButtonItem
        
        let category:UIBarButtonItem = UIBarButtonItem(title: "类别", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.showCategoryController))
        self.navigationItem.leftBarButtonItem = category
        
        self.segment.frame = CGRectMake(segment.frame.origin.x, segment.frame.origin.y, 100, segment.frame.height)
        self.segment.tintColor = commonTintColor
        self.segment.selectedSegmentIndex = 0
        self.navigationItem.titleView = self.segment
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.placeholder = "搜索"
        self.searchBar.tintColor = commonTintColor
        self.view.addSubview(self.searchBar)
        self.searchBar.snp_makeConstraints { (make) in
            make.height.equalTo(44)
            make.width.equalTo(self.view)
            make.top.left.equalTo(self.view)
        }
        
        self.view.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
        
        self.tableView.backgroundColor = commonBackgroundColor
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 164.5
        self.tableView.registerClass(BookListCell.self, forCellReuseIdentifier: self.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.snp_makeConstraints { (make) in
            make.top.equalTo(self.searchBar.snp_bottom)
            make.left.right.bottom.equalTo(self.view)
        }
        categoryCtrl.delegate = self
        categoryTable = categoryCtrl.tableView
        categoryTable.frame = CGRectMake(0, 0, self.view.width, 0)
        categoryTable.hidden = true
        self.view.addSubview(categoryTable)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func closeController() -> Void{
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func showCategoryController() -> Void{
        self.view.endEditing(true)
        let hidden = !categoryTable.hidden
        if hidden{
            let hideAnimate:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
            hideAnimate.toValue = NSValue(CGRect: CGRectMake(0, 0, self.view.width, 0))
            hideAnimate.completionBlock = {[weak self](animation,finished) in
                if finished{
                    if let strongSelf = self{
                        strongSelf.categoryTable.hidden = true
                    }
                }
            }
            categoryTable.pop_addAnimation(hideAnimate, forKey: "hideAnimation")
        }else{
            let showAnimate:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
            showAnimate.toValue = NSValue(CGRect: self.view.bounds)
            showAnimate.animationDidStartBlock = {[weak self](animation) in
                if let strongSelf = self{
                    strongSelf.categoryTable.hidden = false
                }
            }
            categoryTable.pop_addAnimation(showAnimate, forKey: "showAnimation")
        }
    }
    func didSelectSort(sort: String) {
        let controller = CategoryListController()
        controller.sort = sort
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension BookSearchController:UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            self.fetchSearchResult()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.identifier, forIndexPath: indexPath) as! BookListCell
        let book:bookModel = self.dataArray[indexPath.row]
        cell.configureCellWithBook(book)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let book = self.dataArray[indexPath.row]
        let controller:BookInfoController = BookInfoController()
        controller.book = book
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func fetchSearchResult() -> Void{
        self.hud.show()
        self.view.userInteractionEnabled = false
        let type = String(self.segment.selectedSegmentIndex)
        let keyword = self.searchBar.text!
        let resultStr = encodeDictionary(["type":type,"keyword":keyword])
        Alamofire.request(.GET, CAWApiAddress+"/search", parameters: ["req":resultStr], encoding: .URL, headers: nil).responseData {[weak self] response in
            if let strongSelf = self{
                strongSelf.view.userInteractionEnabled = true
                switch response.result {
                case .Success:
                    let data = decodeData(response.data!)
                    let resp:BookListResponse = try! BookListResponse(data: data)
                    strongSelf.dataArray = resp.data as! Array<bookModel>
                    if strongSelf.dataArray.count > 0{
                        strongSelf.hud.dismiss()
                        strongSelf.tableView.reloadData()
                        strongSelf.tableView.setContentOffset(CGPointZero, animated: true)
                    }else{
                        strongSelf.hud.showImage(nil, status: "木有匹配的结果")
                    }
                case .Failure(let error):
                    let description = error.localizedDescription
                    strongSelf.hud.showErrorWithString(description)
                }
            }
        }
    }
}



























