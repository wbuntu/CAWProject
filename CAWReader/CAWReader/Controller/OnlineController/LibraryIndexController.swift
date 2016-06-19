//
//  LibraryIndexController.swift
//  CAWReader
//
//  Created by wbuntu on 4/3/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import CryptoSwift
class LibraryIndexController: BaseController, UICollectionViewDelegate, UICollectionViewDataSource,LibraryIndexReusableViewDelegate {
    var collectionView:UICollectionView!
    let identifier = "bookCell"
    var dataArray:[[bookModel]] = [[bookModel]]()
    let sectionTitles:[String] = ["今日热门","本周推荐","完结经典"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "文库"
        let closeBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.closeController))
        self.navigationItem.rightBarButtonItem = closeBarButtonItem
        
        let searchItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: #selector(self.showSearchVC))
        self.navigationItem.leftBarButtonItem = searchItem
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(libraryItemWidth, libraryItemHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        layout.headerReferenceSize = CGSizeMake(self.view.width, 44)
        layout.footerReferenceSize = CGSizeZero
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = commonBackgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(LibraryIndexCell.self, forCellWithReuseIdentifier: LibraryIndexCell.cellIdentifier)
        collectionView.registerClass(LibraryIndexReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: LibraryIndexReusableView.cellIdentifier)
        self.view.addSubview(collectionView)
        self.fetchLatestIndex()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader{
            let view:LibraryIndexReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: LibraryIndexReusableView.cellIdentifier, forIndexPath: indexPath) as! LibraryIndexReusableView
            view.titleLabel.text = sectionTitles[indexPath.section]
            view.currentSection = indexPath.section
            view.delegate = self
            return view
        }else{
            return UICollectionReusableView()
        }
    }
    
    func showAllBooksFromLocation(section:Int) {
        let controller = SectionListController()
        
        controller.hidesBottomBarWhenPushed = true
        controller.dataArray = dataArray[section]
        controller.sort = sectionTitles[section]
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let books = dataArray[section]
        return books.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:LibraryIndexCell = collectionView.dequeueReusableCellWithReuseIdentifier(LibraryIndexCell.cellIdentifier, forIndexPath: indexPath) as! LibraryIndexCell
        let book:bookModel = self.dataArray[indexPath.section][indexPath.row]
        cell.configureCellWithBook(book)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let book:bookModel = self.dataArray[indexPath.section][indexPath.row]
        let controller:BookInfoController = BookInfoController()
        controller.book = book
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchLatestIndex() -> Void {
        self.hud.show()
        Alamofire.request(.GET, CAWApiAddress+"/index")
            .responseData {[weak self] response in
                if let strongSelf = self{
                    switch response.result {
                    case .Success:
                        strongSelf.hud.dismiss()
                        let data = decodeData(response.data!)
                        let resp:LiabraryIndexResponse = try! LiabraryIndexResponse(data: data)
                        strongSelf.dataArray.append(resp.data.hot as! [bookModel])
                        strongSelf.dataArray.append(resp.data.recommend as! [bookModel])
                        strongSelf.dataArray.append(resp.data.complete as! [bookModel])
                        strongSelf.collectionView.reloadData()
                    case .Failure(let error):
                        let description = error.localizedDescription
                        strongSelf.hud.showErrorWithString(description)
                    }
                }
        }
    }
    
    func closeController() -> Void{
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showSearchVC() -> Void{
        let searchController = BookSearchController()
        searchController.modalTransitionStyle = .CrossDissolve
        let navi:UINavigationController = UINavigationController(rootViewController: searchController)
        self.presentViewController(navi, animated: true, completion: nil)
    }
}
