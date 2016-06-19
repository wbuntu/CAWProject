//
//  ShelfController.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/4.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class ShelfController: BaseController, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView:UICollectionView!
    let identifier = "bookCell"
    var dataArray:[bookModel]{
        get{
            return WWMemory.shared.userShelf!
        }
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.navigationItem.title = "书架"
        let shelfItem = UITabBarItem(title: "书架", image: UIImage(named: "shelf")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), selectedImage: UIImage(named: "shelf_selected")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
        self.tabBarItem = shelfItem
        
        let closeBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "书城", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.showOnlineBook))
        self.navigationItem.rightBarButtonItem = closeBarButtonItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadNotifiation), name: kLoginAgainNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadNotifiation), name: kModifyShelfNotification, object: nil)
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(libraryItemWidth, libraryItemHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        layout.headerReferenceSize = CGSizeZero
        layout.footerReferenceSize = CGSizeZero
        collectionView = UICollectionView(frame: CGRectMake(0, 0, screenWidth, collectionViewHeight), collectionViewLayout: layout)
        collectionView.backgroundColor = commonBackgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(LibraryIndexCell.self, forCellWithReuseIdentifier: LibraryIndexCell.cellIdentifier)
        collectionView.registerClass(LibraryIndexReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: LibraryIndexReusableView.cellIdentifier)
        self.view.addSubview(collectionView)
    }
    func reloadNotifiation() -> Void{
        collectionView.reloadData()
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:LibraryIndexCell = collectionView.dequeueReusableCellWithReuseIdentifier(LibraryIndexCell.cellIdentifier, forIndexPath: indexPath) as! LibraryIndexCell
        let book:bookModel = dataArray[indexPath.row]
        cell.configureCellWithBook(book)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let book:bookModel = dataArray[indexPath.row]
        let controller:BookIndexController = BookIndexController()
        controller.book = book
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showOnlineBook() -> Void {
        NSNotificationCenter.defaultCenter().postNotificationName(showLibraryNofification, object: nil)
    }
}
