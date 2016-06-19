//
//  ReaderControlletr.swift
//  CAWReader
//
//  Created by wbuntu on 16/3/27.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import CoreText
import Alamofire
import WSProgressHUD
import pop
class ReaderControlletr: UIViewController {
    let bgLayer:CALayer = {
        let layer = CALayer()
        layer.frame = UIScreen.mainScreen().bounds
        layer.contents = WWMemory.shared.bgImage.CGImage
        return layer
    }()
    var collectionView:UICollectionView!
    var isHidden:Bool = true
    var chapterId:String!
    var chapter:chapterModel!
    var currentChapterIndexPath:NSIndexPath!
    let mSize:CGSize = CGSizeMake(UIScreen.mainScreen().bounds.width-10, UIScreen.mainScreen().bounds.height-20)
    let token:String = "\u{FFFC}"
    var images:Dictionary = Dictionary<String,UIImage>()
    var rangeArray:Array = Array<NSRange>()
    var attStr:NSMutableAttributedString = NSMutableAttributedString()
    var dataDictionary:Dictionary<Int,UIImage> = Dictionary<Int,UIImage>()
    let backgroundQueue:NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    var textColor:UIColor = WWMemory.shared.theme!.colorComponent().textColor
    lazy var hud: WSProgressHUD = {
        let tempHud:WSProgressHUD = WSProgressHUD(view: self.view)
        tempHud.frame = CGRectMake(0, 64, tempHud.frame.width, tempHud.frame.height-64)
        self.view.addSubview(tempHud)
        return tempHud
    }()
    let pageWidth:CGFloat = UIScreen.mainScreen().bounds.width
    
    var volumeArray:Array<volumeModel>!
    var book:bookModel!
    
    let indexController:ReaderIndexController = ReaderIndexController()
    var indexView:UIView!
    
    let bookmarkController:ReaderBookmarkController = ReaderBookmarkController()
    var bookmarkView:UIView!
    
    let fontController:ReaderFontController = ReaderFontController()
    var fontView:UIView!
    let titleLabel:UILabel = {
        let label = UILabel(frame: CGRectMake(0,0,screenWidth-120,44))
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.boldSystemFontOfSize(17)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        return label
    }()
    var tap:UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = commonBackgroundColor
        self.view.layer.insertSublayer(bgLayer, atIndex: 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(renderBg), name: kChangeBGLayerNotificaton, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(themeCellDidSelectTheme), name: kChangeTextColorNotification, object: nil)
        
        let searchItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: #selector(showSearchVC))
        self.navigationItem.rightBarButtonItem = searchItem
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.itemSize = UIScreen.mainScreen().bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsetsZero
        layout.headerReferenceSize = CGSizeZero
        layout.footerReferenceSize = CGSizeZero
        
        collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerClass(ReaderCollectionCell.self, forCellWithReuseIdentifier: ReaderCollectionCell.cellIdentifier)
        self.view.addSubview(collectionView)
        
        self.addChildViewController(fontController)
        fontController.delegate = self
        fontView = fontController.view
        fontView.frame = CGRectMake(0, screenHeight, screenWidth, 0)
        fontView.hidden = true
        self.view.addSubview(fontView)
        
        self.addChildViewController(indexController)
        indexController.book = book
        indexController.volumeArray = volumeArray
        indexController.delegate = self
        indexView = indexController.view
        indexView.frame = CGRectMake(0, screenHeight, screenWidth, 0)
        indexView.hidden = true
        self.view.addSubview(indexView)
        
        self.addChildViewController(bookmarkController)
        bookmarkController.delegate = self
        bookmarkView = bookmarkController.view
        bookmarkView.frame = CGRectMake(0, screenHeight, screenWidth, 0)
        bookmarkView.hidden = true
        self.view.addSubview(bookmarkView)
        
        tap = UITapGestureRecognizer(target: self, action:#selector(didTap))
        self.view.addGestureRecognizer(tap)
        
        loadContent()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    func loadContent() ->Void{
        self.view.userInteractionEnabled = false
        self.hud.show()
        //前期完全的阻塞式
        //中期期可以让下载图片与排版并发，但是显示依赖于全部网络操作和排班操作完成
        //后期在中期基础上，让排版与下载并发，保存图片的rect，在显示时异步加载
        
        let block0 = NSBlockOperation {[weak self] in
            if let strongSelf = self{
                strongSelf.fetchContent()
            }
        }
        let block1 = NSBlockOperation{[weak self] in
            if let strongSelf = self{
                strongSelf.paging()
            }
        }
        block1.addDependency(block0)
        
        let block2 = NSBlockOperation{ [weak self] in
            if let strongSelf = self{
                strongSelf.hud.dismiss()
                strongSelf.view.userInteractionEnabled = true
                strongSelf.title = strongSelf.chapter.title
                strongSelf.collectionView.reloadData()
            }
        }
        block2.addDependency(block1)
        
        self.backgroundQueue.addOperation(block0)
        self.backgroundQueue.addOperation(block1)
        NSOperationQueue.mainQueue().addOperation(block2)
    }
    
    func showSearchVC() ->Void{
        let controller:ReaderSearchController = ReaderSearchController()
        controller.string = attStr.string as NSString
        controller.rangeArray = rangeArray
        controller.delegate = self
        let navi:UINavigationController = UINavigationController(rootViewController: controller)
        self.presentViewController(navi, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.isHidden
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension ReaderControlletr:ReaderSearchControllerDelegate{
    func didSelectItem(row: Int) {
        let offSetX = CGFloat(row)*pageWidth
        changeNaviAndPannel()
        collectionView.setContentOffset(CGPointMake(offSetX, 0), animated: false)
    }
}

extension ReaderControlletr:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rangeArray.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ReaderCollectionCell.cellIdentifier, forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let tempCell:ReaderCollectionCell = cell as! ReaderCollectionCell
        tempCell.image = fetchCellImage(indexPath.row)
    }
    
    func fetchCellImage(row:Int) ->UIImage{
        if let im = dataDictionary[row]{
            return im
        }else{
            let range = rangeArray[row]
            let im:UIImage = imageWithAttributedString(attStr.attributedSubstringFromRange(range))
            dataDictionary[row] = im
            return im
        }
    }
    
    func didTap(tap:UITapGestureRecognizer) -> Void {
        let location = tap.locationInView(self.view)
        let offsetX:CGFloat = collectionView.contentOffsetX
        if location.x>(self.view.bounds.midX+50) {
            if !self.isHidden{
                self.isHidden = true
                UIView.animateWithDuration(NSTimeInterval(UINavigationControllerHideShowBarDuration), animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.fontView.frame = CGRectMake(0, screenHeight, screenWidth, 0)
                    }, completion: { (finished) in
                        self.fontView.hidden = true
                })
                self.navigationController?.setNavigationBarHidden(self.isHidden, animated: true)
            }
            if offsetX < pageWidth*CGFloat(rangeArray.count-1){
                collectionView.setContentOffset(CGPointMake(offsetX+pageWidth, 0), animated: false)
            }else{
                showNext()
            }
        }else if location.x<(self.view.bounds.midX-50){
            if !self.isHidden{
                self.isHidden = true
                UIView.animateWithDuration(NSTimeInterval(UINavigationControllerHideShowBarDuration), animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.fontView.frame = CGRectMake(0, screenHeight, screenWidth, 0)
                    }, completion: { (finished) in
                        self.fontView.hidden = true
                })
                self.navigationController?.setNavigationBarHidden(self.isHidden, animated: true)
            }
            
            if offsetX > 0{
                collectionView.setContentOffset(CGPointMake(offsetX-pageWidth, 0), animated: false)
            }else{
                showPrevious()
            }
        }else{
            changeNaviAndPannel()
        }
    }
    
    func changeNaviAndPannel() ->Void{
        self.isHidden = !self.isHidden
        if self.isHidden{
            UIView.animateWithDuration(NSTimeInterval(UINavigationControllerHideShowBarDuration), animations: {
                    self.setNeedsStatusBarAppearanceUpdate()
                    self.fontView.frame = CGRectMake(0, screenHeight, screenWidth, 0)
                }, completion: { (finished) in
                    self.fontView.hidden = true
            })
            
        }else{
            fontView.hidden = false
            
                UIView.animateWithDuration(NSTimeInterval(UINavigationControllerHideShowBarDuration), animations: {
                self.setNeedsStatusBarAppearanceUpdate()
                self.fontView.frame = CGRectMake(0, 64, screenWidth, screenHeight-64)
                })
        }
        self.navigationController?.setNavigationBarHidden(self.isHidden, animated: true)
    }
    func disableTapOnBack() ->Void{
        tap.enabled = false
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    func enableTapOnBack() ->Void{
        self.navigationItem.rightBarButtonItem?.enabled = true
        tap.enabled = true
        self.navigationItem.setHidesBackButton(false, animated: true)
    }
}

extension ReaderControlletr:ReaderFontControllerDelegate{
    
    func showIndex() {
        changeIndexViewVisibility()
    }
    
    func showBookmark() {
        changeBookmarkViewVisibility()
    }
    
    func showFont() {
        fontController.isOnScreen = !fontController.isOnScreen
        if fontController.isOnScreen{
            disableTapOnBack()
            fontController.currentPonit = Float(collectionView.contentOffsetX/collectionView.contentSize.width)
        }else{
            enableTapOnBack()
        }
    }
    func upFontSize() {
        if WWMemory.shared.fontSize! < 20{
            WWMemory.shared.fontSize! += 1
            themeCellReloadFontSize()
        }
    }
    func downFontSize() {
        if WWMemory.shared.fontSize! > 14{
            WWMemory.shared.fontSize! -= 1
            themeCellReloadFontSize()
        }
    }
    
    func themeCellReloadFontSize() ->Void{
        let item = Int(collectionView.contentOffsetX/pageWidth)
        let range:NSRange = rangeArray[item]
        rangeArray = Array<NSRange>()
        attStr = NSMutableAttributedString()
        dataDictionary = Dictionary<Int,UIImage>()
        collectionView.reloadData()
//        hud.show()
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            self.generateAttStr()
            self.paging()
            var index:Int = 0
            for ra in  self.rangeArray{
                if NSLocationInRange(range.location, ra){
                    break
                }
                index += 1
            }
            dispatch_async(dispatch_get_main_queue(), {
//                self.hud.dismiss()
                self.collectionView.reloadData()
                self.collectionView.setContentOffset(CGPointMake(CGFloat(index)*self.pageWidth, 0), animated: false)
            })
        }
    }
    
    func themeCellDidSelectTheme() {
        dataDictionary = Dictionary<Int,UIImage>()
        textColor = WWMemory.shared.theme!.colorComponent().textColor
        let item = Int(collectionView.contentOffsetX/pageWidth)
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    func renderBg() ->Void{
        bgLayer.contents = WWMemory.shared.bgImage.CGImage
    }
    
    func showNext() {
        self.view.userInteractionEnabled = false
        var tempChapter:NSIndexPath!
        let chapters = volumeArray[currentChapterIndexPath.section].chapters
        if currentChapterIndexPath.row < chapters.count - 1{
            tempChapter = NSIndexPath(forRow: currentChapterIndexPath.row+1, inSection: currentChapterIndexPath.section)
            let aChapter = chapters[tempChapter.row] as! vChapter
            tryLoadChapter(aChapter.chapterId,indexPath: tempChapter, isPrevious: false)
        }else if currentChapterIndexPath.section < volumeArray.count - 1{
            tempChapter = NSIndexPath(forItem: 0, inSection: currentChapterIndexPath.section+1)
            if let aChapter:vChapter = volumeArray[currentChapterIndexPath.section].chapters[currentChapterIndexPath.row] as? vChapter{
                tryLoadChapter(aChapter.chapterId,indexPath: tempChapter, isPrevious: false)
            }
        }else{
            self.hud.showImage(nil, status: "最后一页")
            self.view.userInteractionEnabled = true
        }
    }
    func showPrevious() {
        self.view.userInteractionEnabled = false
        var tempChapter:NSIndexPath!
        if currentChapterIndexPath.row > 0{
            tempChapter = NSIndexPath(forRow: currentChapterIndexPath.row-1, inSection: currentChapterIndexPath.section)
            let aChapter:vChapter = volumeArray[tempChapter.section].chapters[tempChapter.row] as! vChapter
            tryLoadChapter(aChapter.chapterId,indexPath: tempChapter, isPrevious: true)
        }else if currentChapterIndexPath.section > 0{
            let section = currentChapterIndexPath.section - 1
            if let aChapter:vChapter = volumeArray[section].chapters.last as? vChapter{
                let item = volumeArray[section].chapters.count - 1
                tempChapter = NSIndexPath(forItem: item, inSection: section)
                tryLoadChapter(aChapter.chapterId,indexPath: tempChapter, isPrevious: true)
            }
        }else{
            self.hud.showImage(nil, status: "第一页")
            self.view.userInteractionEnabled = true
        }
    }
    
    func tryLoadChapter(chapterIdStr:String, indexPath:NSIndexPath, isPrevious:Bool) ->Void{
        self.hud.show()
        Alamofire.request(.HEAD, CAWResourceAddress+"/content/"+chapterIdStr+".json")
            .responseData {[weak self] response in
                if let strongSelf = self{
                    switch response.result {
                    case .Success:
                        if response.response?.statusCode == 200{
                            strongSelf.loadValidChapter(chapterIdStr, indexPath: indexPath)
                        }else{
                            strongSelf.hud.showImage(nil, status: "文件不存在")
                            strongSelf.currentChapterIndexPath = indexPath
                            if isPrevious{
                                strongSelf.showPrevious()
                            }else{
                                strongSelf.showNext()
                            }
                        }
                    case .Failure(let error):
                        let description = error.localizedDescription
                        strongSelf.hud.showErrorWithString(description)
                        strongSelf.view.userInteractionEnabled = true
                    }
                    
                }
        }
    }
    
    func slideToPoint(point:Float) {
        let page = Int(Float(rangeArray.count-1)*point)
        let offsetX = CGFloat(page) * pageWidth
        collectionView.setContentOffset(CGPointMake(offsetX, 0), animated: false)
    }
}


extension ReaderControlletr:ReaderIndexControllerDelegate{
    func didSelectValidChapter(chapterId:String, indexPath:NSIndexPath) {
        changeIndexViewVisibility()
        changeNaviAndPannel()
        loadValidChapter(chapterId, indexPath: indexPath)
    }
    
    func loadValidChapter(chapterId:String, indexPath:NSIndexPath) ->Void{
        self.chapterId = chapterId
        self.currentChapterIndexPath = indexPath
        images = Dictionary<String,UIImage>()
        rangeArray = Array<NSRange>()
        attStr = NSMutableAttributedString()
        dataDictionary = Dictionary<Int,UIImage>()
        collectionView.reloadData()
        loadContent()
    }
    
    func cancelIndexSelection() {
        changeIndexViewVisibility()
    }
    
    func changeIndexViewVisibility() ->Void{
        indexController.isOnScreen = !indexController.isOnScreen
        if indexController.isOnScreen{
            disableTapOnBack()
            
            indexView.hidden = false
            let show:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
            show.toValue = NSValue(CGRect: CGRectMake(0, 64, screenWidth, screenHeight-64))
            indexView.pop_addAnimation(show, forKey: "kShow")
        }else{
            let hide:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
            hide.toValue = NSValue(CGRect: CGRectMake(0, screenHeight, screenWidth, 0))
            hide.completionBlock = {[weak self] (animation,finished) in
                if let strongSelf = self{
                    if finished{
                        strongSelf.enableTapOnBack()
                        strongSelf.indexView.hidden = true
                    }
                }
            }
            indexView.pop_addAnimation(hide, forKey: "kHide")
        }
    }
}

extension ReaderControlletr:ReaderBookmarkControllerDelegate{
    func cancelAddingBookmark() {
        changeBookmarkViewVisibility()
    }
    
    func didSelectBookmark(row: Int) {
        changeBookmarkViewVisibility()
        changeNaviAndPannel()
        collectionView.setContentOffset(CGPointMake(pageWidth*CGFloat(row), 0), animated: false)
    }
    
    func changeBookmarkViewVisibility() ->Void{
        bookmarkController.isOnScreen = !bookmarkController.isOnScreen
        if bookmarkController.isOnScreen{
            disableTapOnBack()
            
            bookmarkView.hidden = false
            let show:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
            show.toValue = NSValue(CGRect: CGRectMake(0, 64, screenWidth, screenHeight-64))
            show.completionBlock = {[weak self] (animation,finished) in
                if let strongSelf = self{
                    let offsetX:CGFloat = strongSelf.collectionView.contentOffsetX
                    let currentPageRow = Int(offsetX/strongSelf.pageWidth)
                    strongSelf.bookmarkController.configureBookmark(strongSelf.attStr.string as NSString, currentRow: currentPageRow, chapterId: strongSelf.chapterId, ranges: strongSelf.rangeArray)
                }
            }
            bookmarkView.pop_addAnimation(show, forKey: "kShow")
        }else{
            let hide:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
            hide.toValue = NSValue(CGRect: CGRectMake(0, screenHeight, screenWidth, 0))
            hide.completionBlock = {[weak self] (animation,finished) in
                if let strongSelf = self{
                    if finished{
                        strongSelf.enableTapOnBack()
                        strongSelf.bookmarkView.hidden = true
                    }
                }
            }
            bookmarkView.pop_addAnimation(hide, forKey: "kHide")
        }
    }
}

extension ReaderControlletr{
    func fetchContent() -> Void {
        let url = NSURL(string: CAWResourceAddress+"/content/"+self.chapterId!+".json")
        var jsonStr:String?
        do {
            jsonStr = try String(contentsOfURL: url!)
        }catch (let error){
            print(error)
            self.hud.showErrorWithString("似乎已断开与互联网的连接")
            self.view.userInteractionEnabled = true
            return
        }
        self.chapter = chapterModel(string: jsonStr, error: nil)
        generateAttStr()
    }
    
    func generateAttStr() ->Void{
        //text ParagraphStyle
        let pa = NSMutableParagraphStyle()
        let font = UIFont.systemFontOfSize(CGFloat(WWMemory.shared.fontSize!))
        pa.firstLineHeadIndent = CGFloat(WWMemory.shared.firstHeadIndent!)*font.pointSize
        pa.paragraphSpacing = CGFloat(WWMemory.shared.paragraphSpacing!)
        pa.lineSpacing = CGFloat(WWMemory.shared.lineSpacing!)
        
        if self.chapter.images.count>0{
            let manager = NSFileManager.defaultManager()
            for image in self.chapter.images {
                let str:String = image.imageName
                if let _ = self.images[str]{
                    continue
                }else{
                    let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!+"/"+str
                    if manager.fileExistsAtPath(path){
                        let im = UIImage(contentsOfFile: path)!
                        self.images[str] = im
                    }else{
                        let temp = CAWResourceAddress+"/images/"+image.imageName
                        let data = NSData(contentsOfURL: NSURL(string: temp)!)!
                        try! data.writeToFile(path, options: NSDataWritingOptions.DataWritingAtomic)
                        let im:UIImage = UIImage(data: data)!
                        self.images[str] = im
                    }
                }
            }
            let imagePrefix = "chapter-"+"\(self.chapter.cid)"
            
            for str in self.chapter.content{
                if str.hasPrefix(imagePrefix){
                    var  imageCallback =  CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { (refCon: UnsafeMutablePointer<Void>) in
                        
                        }, getAscent: { (refCon: UnsafeMutablePointer<Void>) -> CGFloat in
                            let ptr = UnsafePointer<UIImage>(refCon)
                            let im = ptr.memory
                            //coretext排版问题：当CTRun的宽度大于path的宽度时，排班出的高度为0
                            if im.size.width*0.7 > UIScreen.mainScreen().bounds.width-10{
                                return im.size.height*(UIScreen.mainScreen().bounds.width-10)/im.size.width
                            }
                            return im.size.height*0.7
                        }, getDescent: { (refCon: UnsafeMutablePointer<Void>) -> CGFloat in
                            return 0
                        }, getWidth: { (refCon: UnsafeMutablePointer<Void>) -> CGFloat in
                            let ptr = UnsafePointer<UIImage>(refCon)
                            let im = ptr.memory
                            if im.size.width*0.7 > UIScreen.mainScreen().bounds.width-10{
                                return UIScreen.mainScreen().bounds.width-10
                            }
                            return im.size.width*0.7
                    })
                    let temp = str
                    let attachment:NSMutableAttributedString = NSMutableAttributedString(string: self.token)
                    let im:UIImage = self.images[temp]!
                    let ptr = UnsafeMutablePointer<UIImage>.alloc(1)
                    ptr.initialize(im)
                    let runDelegate = CTRunDelegateCreate(&imageCallback, ptr)
                    attachment.addAttributes([kCTRunDelegateAttributeName as String:runDelegate!], range: NSMakeRange(0, 1))
                    attachment.addAttributes(["imageName":temp], range: NSMakeRange(0, 1))
                    self.attStr.appendAttributedString(attachment)
                    self.attStr.appendAttributedString(NSAttributedString(string:"\n"))
                }else{
                    
                    let att:NSAttributedString = NSAttributedString(string: str.stringByAppendingString("\n"), attributes: [NSFontAttributeName:font,NSParagraphStyleAttributeName:pa])
                    self.attStr.appendAttributedString(att)
                }
            }
        }else{
            if self.chapter.content.count>0{
                var tempStr:String = ""
                for str in self.chapter.content{
                    tempStr += str
                    tempStr += "\n"
                }
                let att:NSAttributedString = NSAttributedString(string: tempStr, attributes: [NSFontAttributeName:font,NSParagraphStyleAttributeName:pa])
                self.attStr.appendAttributedString(att)
            }else{
                let att:NSAttributedString = NSAttributedString(string: self.chapter.title, attributes: [NSFontAttributeName:font,NSParagraphStyleAttributeName:pa])
                self.attStr.appendAttributedString(att)
            }
        }
    }
    
    func paging() -> Void {
        let length = self.attStr.length
        var currentIdex = 0;
        let frameStter = CTFramesetterCreateWithAttributedString(self.attStr)
        var transform = CGAffineTransformIdentity
        while currentIdex<length{
            let path = CGPathCreateWithRect(CGRectMake(0, 0, self.mSize.width, self.mSize.height), &transform)
            let frame = CTFramesetterCreateFrame(frameStter, CFRangeMake(currentIdex, 0), path, nil)
            let ra = CTFrameGetVisibleStringRange(frame)
            let range = NSMakeRange(ra.location, ra.length)
            self.rangeArray.append(range)
            currentIdex += ra.length
        }
    }
    
    func imageWithAttributedString(attIn:NSAttributedString) -> UIImage{
        let finalStr = (attIn.string as NSString).stringByReplacingOccurrencesOfString(token, withString: "").stringByReplacingOccurrencesOfString("\n", withString: "") as NSString
        var isSingleImage:Bool = false
        if finalStr.length == 0{
            isSingleImage = true
        }
        let att:NSMutableAttributedString = NSMutableAttributedString(attributedString: attIn)
        att.addAttributes([NSForegroundColorAttributeName:textColor], range: NSMakeRange(0, att.length))
        UIGraphicsBeginImageContextWithOptions(mSize, false, 0.0)
        var transform = CGAffineTransformIdentity
        let path = CGPathCreateWithRect(CGRectMake(0, 0, mSize.width, mSize.height), &transform)
        let frameStter = CTFramesetterCreateWithAttributedString(att)
        let frame = CTFramesetterCreateFrame(frameStter, CFRangeMake(0, att.length), path, nil)
        let ctx = UIGraphicsGetCurrentContext()!
        CGContextTranslateCTM(ctx, 0, mSize.height)
        CGContextScaleCTM(ctx, 1, -1)
        CTFrameDraw(frame, ctx)
        let lines:Array = CTFrameGetLines(frame) as Array
        var originsArray = [CGPoint](count:lines.count, repeatedValue: CGPointZero)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &originsArray)
        for i in 0..<lines.count {
            let line = lines[i]
            var lineAscent = CGFloat()
            var lineDescent = CGFloat()
            var lineLeading = CGFloat()
            CTLineGetTypographicBounds(line as! CTLineRef, &lineAscent, &lineDescent, &lineLeading)
            let runs:Array = CTLineGetGlyphRuns(line as! CTLine) as Array
            for j in 0..<runs.count{
                let run = runs[j]
                let attributes:Dictionary = CTRunGetAttributes(run as! CTRun) as Dictionary
                if let imageName:String = attributes["imageName"] as? String {
                    var  runAscent = CGFloat()
                    var  runDescent = CGFloat()
                    let  lineOrigin = originsArray[i]
                    let width =  CGFloat(CTRunGetTypographicBounds(run as! CTRun, CFRangeMake(0,0), &runAscent, &runDescent, nil))
                    
                    let  runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line as! CTLine,
                        CTRunGetStringRange(run as! CTRun).location, nil),
                                              lineOrigin.y - runDescent,
                                              width,
                                              runAscent + runDescent)
                    //获取frame的rect，转化为坐标界面中的rect，可以不在这时候绘制，仅仅占位，或者在后续中添加为其他的view，或者对触摸做出响应
                    //                    CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
                    //                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    //                    CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                    let image:UIImage = self.images[imageName]!
                    var size = image.size
                    size.width *= 0.7
                    size.height *= 0.7
                    //line rect 居中
                    var  imageDrawRect = CGRectMake(self.mSize.width/2-size.width/2, runRect.origin.y, size.width, size.height)
                    //大于分页宽度时，设定为分页宽度
                    if size.width > self.mSize.width
                    {
                        imageDrawRect.size.width = mSize.width
                        imageDrawRect.size.height = size.height * width/size.width
                        imageDrawRect.origin.x = 0
                    }
                    //单页内只有一张图片时，居中绘制
                    if isSingleImage{
                        imageDrawRect.origin = CGPointMake(imageDrawRect.origin.x, (mSize.height-imageDrawRect.size.height)/2)
                    }
                    
                    let p:UIBezierPath = UIBezierPath(roundedRect: imageDrawRect, byRoundingCorners: .AllCorners, cornerRadii: CGSizeMake(10, 10))
                    p.addClip()
                    CGContextDrawImage(ctx, imageDrawRect, image.CGImage)
                }else{
                    continue
                }
            }
        }
        let im = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return im
    }
}




