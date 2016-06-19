//
//  DiscoverController.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/4.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import Alamofire
class DiscoverController: BaseController, UICollectionViewDelegate, UICollectionViewDataSource, DiscoverCellEndProtocol {
    var needsRefresh:Bool = false
    let commonIdentifier = "commonCollectionCell"
    let endIdentifier = "endCollectionCell"
    var collectionView:UICollectionView!
    var dataArray:Array<bookModel>?
    //    private var animationsCount = 0
    private var currentPage = 0
    private var pageWidth: CGFloat {
        return self.collectionViewLayout.itemSize.width + self.collectionViewLayout.minimumLineSpacing
    }
    
    private var contentOffset: CGFloat {
        return self.collectionView.contentOffset.x + self.collectionView.contentInset.left
    }
    private let collectionViewLayout: KFBHorizontalLinearFlowLayout = {
        let layout = KFBHorizontalLinearFlowLayout()
        layout.itemSize = CGSizeMake(screenWidth-68, collectionViewHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        return layout
    }()
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)   {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.navigationItem.title = "发现"
        let discoverItem = UITabBarItem(title: "发现", image: UIImage(named: "discover")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), selectedImage: UIImage(named: "discover_selected")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
        self.tabBarItem = discoverItem
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView = UICollectionView(frame: CGRectMake(0, 0, screenWidth, collectionViewHeight), collectionViewLayout: self.collectionViewLayout)
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        self.collectionView.backgroundColor = commonBackgroundColor
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.registerClass(DiscoverCellCommon.self, forCellWithReuseIdentifier: self.commonIdentifier)
        self.collectionView.registerClass(DiscoverCellEnd.self, forCellWithReuseIdentifier: self.endIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
        
        self.fetchRandomList()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if needsRefresh{
            needsRefresh = false
            self.fetchRandomList()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.dataArray != nil{
            return self.dataArray!.count+1
        }
        else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.dragging || collectionView.decelerating || collectionView.tracking {
            return
        }
        if indexPath.row == self.dataArray!.count{
            return
        }
        let selectedPage = indexPath.row
        if selectedPage == self.currentPage {
            let controller:BookInfoController = BookInfoController()
            controller.book = self.dataArray![indexPath.row]
            let navi = UINavigationController(rootViewController: controller)
            self.presentViewController(navi, animated: true, completion: nil)
        }
        //        else {
        //            self.scrollToPage(selectedPage, animated: true)
        //        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < self.dataArray!.count{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.commonIdentifier, forIndexPath: indexPath) as! DiscoverCellCommon
            cell.configureCellWithBook(self.dataArray![indexPath.row])
            return cell
        }else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.endIdentifier, forIndexPath: indexPath) as! DiscoverCellEnd
            cell.delegate = self
            return cell
        }
    }
    private func scrollToPage(page: Int, animated: Bool) {
        //        self.collectionView.userInteractionEnabled = false
        //        self.animationsCount+=1
        let pageOffset = CGFloat(page) * self.pageWidth - self.collectionView.contentInset.left
        self.collectionView.setContentOffset(CGPointMake(pageOffset, 0), animated: animated)
        self.currentPage = page
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.currentPage = Int(self.contentOffset / self.pageWidth)
    }
    
    //    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    //        self.animationsCount-=1
    //        if self.animationsCount == 0 {
    //            self.collectionView.userInteractionEnabled = true
    //        }
    //    }
    func fetchRandomList() -> Void {
        self.collectionView.userInteractionEnabled = false
        self.hud.show()
        Alamofire.request(.GET, CAWApiAddress+"/discover")
            .responseData {[weak self] response in
                if let strongSelf = self{
                    strongSelf.collectionView.userInteractionEnabled = true
                    switch response.result {
                    case .Success:
                        strongSelf.hud.dismiss()
                        let data = decodeData(response.data!)
                        let resp:BookListResponse = try! BookListResponse(data: data)
                        strongSelf.dataArray = resp.data as? Array<bookModel>
                        strongSelf.collectionView.reloadData()
                    case .Failure(let error):
                        let description = error.localizedDescription
                        strongSelf.hud.showErrorWithString(description)
                        strongSelf.needsRefresh = true
                    }
                    
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAnotherBatchOfBook() {
        self.fetchRandomList()
        self.scrollToPage(0, animated: false)
    }
    
}
