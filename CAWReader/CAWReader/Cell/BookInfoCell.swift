
//
//  BookInfoCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/5.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import EDStarRating
import TagListView

public protocol BookInfoCellBaseDelegate:NSObjectProtocol{
    func BICShowBookIndex() -> Void
    func BICShowBookIndexWithCache() -> Void
}

class BookInfoCellBase: BaseTableViewCell {
    weak var delegate:BookInfoCellBaseDelegate?
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BookInfoCellHead: BookInfoCellBase {
    private let coverImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .ScaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private let titleLabel:UILabel = UILabel()
    private let starRating:EDStarRating = EDStarRating()
    private let authorLabel:UILabel = UILabel()
    private let tagList:TagListView = TagListView()
    private let shadowView:UIView = {
        let sshadowView = UIView()
        sshadowView.layer.shadowOpacity = 0.8
        sshadowView.layer.shadowOffset = CGSizeMake(0, 3)
        sshadowView.layer.shadowColor = UIColor.blackColor().CGColor
        sshadowView.layer.shouldRasterize = true
        sshadowView.layer.rasterizationScale = UIScreen.mainScreen().scale
        return sshadowView
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let superview = self.contentView
        
        superview.addSubview(shadowView)
        shadowView.snp_makeConstraints { (make) in
            make.width.equalTo(102)
            make.height.equalTo(148)
            make.top.equalTo(superview).offset(8).priority(999)
            make.left.equalTo(superview).offset(8)
            make.bottom.equalTo(superview).offset(-8)
        }
        
        shadowView.addSubview(coverImageView)
        coverImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(shadowView)
        }
        
        self.titleLabel.font = UIFont.systemFontOfSize(19)
        self.titleLabel.textAlignment = .Left
        self.titleLabel.numberOfLines = 2
        self.titleLabel.lineBreakMode = .ByWordWrapping
        superview.addSubview(self.titleLabel)
        self.titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.shadowView)
            make.left.equalTo(self.shadowView.snp_right).offset(8)
            make.right.equalTo(superview).offset(-8)
        }
        
        self.starRating.backgroundColor = UIColor.whiteColor()
        self.starRating.starImage = UIImage(named: "star-template")!
        self.starRating.starHighlightedImage = UIImage(named: "star-highlighted-gold-template")!
        self.starRating.maxRating = 10
        self.starRating.rating = 0.0
        self.starRating.userInteractionEnabled = false
        self.starRating.displayMode = EDStarRatingDisplayAccurate
        superview.addSubview(self.starRating)
        self.starRating.snp_makeConstraints { (make) in
            make.height.equalTo(13)
            make.top.equalTo(self.titleLabel.snp_bottom).offset(8)
            make.left.equalTo(self.shadowView.snp_right)
            make.right.equalTo(self.titleLabel)
        }
        
        self.authorLabel.font = UIFont.systemFontOfSize(17)
        self.authorLabel.textAlignment = .Left
        self.authorLabel.numberOfLines = 1
        self.authorLabel.lineBreakMode = .ByTruncatingTail
        superview.addSubview(self.authorLabel)
        self.authorLabel.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.right.equalTo(self.titleLabel)
            make.top.greaterThanOrEqualTo(self.starRating.snp_bottom).offset(8)
            make.centerY.greaterThanOrEqualTo(self.shadowView)
        }
        self.tagList.textFont = UIFont.systemFontOfSize(17)
        self.tagList.alignment = .Left
        self.tagList.cornerRadius = 3.0
        self.tagList.paddingX = 6
        self.tagList.paddingY = 6
        self.tagList.marginX = 6
        self.tagList.marginY = 6
        superview.addSubview(self.tagList)
        self.tagList.snp_makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.right.equalTo(self.titleLabel)
            make.bottom.equalTo(self.shadowView).offset(-10)
        }
        
        self.contentView.bringSubviewToFront(shadowView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureCellWithBook(book:bookModel) -> Void{
        super.configureCellWithBook(book)
        if book.cover == "default.jpg"{
            self.coverImageView.image = commonPlaceHolder
        }else{
            let cover = book.cover.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            self.coverImageView.kf_setImageWithURL(NSURL(string: CAWResourceAddress+"/cover/"+cover)!, placeholderImage: commonPlaceHolder, optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }
        self.titleLabel.text = book.title
        self.starRating.rating = Float(book.rating)!
        self.authorLabel.text = book.author
        self.tagList.removeAllTags()
        self.tagList.addTag(book.sort)
        self.tagList.addTag(book.status)
    }
}

class BookInfoCellIndex: BookInfoCellBase {
    let cacheButton:UIButton = UIButton(type: .Custom)
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let superview = self.contentView
        
        let indexButton:UIButton = UIButton(type: .Custom)
        indexButton.addTarget(self, action: #selector(self.showBookIndex), forControlEvents: .TouchUpInside)
        indexButton.titleLabel!.font = UIFont.systemFontOfSize(16)
        indexButton.setTitle("目录", forState: .Normal)
        indexButton.setTitleColor(commonTintColor, forState: .Normal)
        superview.addSubview(indexButton)
        indexButton.snp_makeConstraints { (make) in
            make.top.equalTo(superview).offset(6).priority(999)
            make.bottom.equalTo(superview).offset(-6)
            make.centerX.equalTo(superview.snp_centerX).offset(-superview.bounds.width*0.25)
            make.width.equalTo(100)
            make.height.equalTo(32)
        }
        
        cacheButton.addTarget(self, action: #selector(self.showBookIndexWithCache), forControlEvents: .TouchUpInside)
        cacheButton.titleLabel!.font = UIFont.systemFontOfSize(16)
//        cacheButton.setTitle("加入书架", forState: .Normal)
        cacheButton.setTitleColor(commonTintColor, forState: .Normal)
        superview.addSubview(cacheButton)
        cacheButton.snp_makeConstraints { (make) in
            make.top.bottom.equalTo(indexButton)
            make.centerX.equalTo(superview.snp_centerX).offset(superview.bounds.width*0.25)
            make.width.equalTo(100)
            make.height.equalTo(32)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureCellWithBook(book:bookModel) -> Void{
        super.configureCellWithBook(book)
        if WWMemory.shared.userShelf!.contains(book){
            cacheButton.setTitle("已加入书架", forState: .Normal)
        }else{
            cacheButton.setTitle("加入书架", forState: .Normal)
        } 
    }
    
    func showBookIndex() -> Void {
        self.delegate?.BICShowBookIndex()
    }
    
    func showBookIndexWithCache() -> Void {
        self.delegate?.BICShowBookIndexWithCache()
    }
}

class BookInfoCellIntroHead : BookInfoCellBase{
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let superview = self.contentView
        let label:UILabel = UILabel()
        label.font = UIFont.systemFontOfSize(16)
        label.textAlignment = .Center
        label.text = "作品简介"
        superview.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.top.equalTo(superview).offset(8).priority(999)
            make.bottom.equalTo(superview).offset(-8)
            make.left.equalTo(superview).offset(8)
            make.width.equalTo(64)
            make.height.equalTo(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureCellWithBook(book:bookModel) -> Void{
        super.configureCellWithBook(book)
    }
}

class BookInfoCellIntro: BookInfoCellBase {
    private let introLabel:UILabel = UILabel()
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let superview = self.contentView
        self.introLabel.userInteractionEnabled = true
        self.introLabel.font = UIFont.systemFontOfSize(16)
        self.introLabel.numberOfLines = 0
        self.introLabel.textAlignment = .Left
        self.introLabel.lineBreakMode = .ByWordWrapping
        superview.addSubview(self.introLabel)
        self.introLabel.snp_makeConstraints { (make) in
            make.top.equalTo(superview).offset(8).priority(999)
            make.left.equalTo(superview).offset(8)
            make.right.bottom.equalTo(superview).offset(-8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureCellWithBook(book:bookModel) -> Void{
        super.configureCellWithBook(book)
        let style:NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.firstLineHeadIndent = self.introLabel.font.pointSize
        if let str = book.intro{
            self.introLabel.attributedText = NSMutableAttributedString(string: str, attributes: [NSParagraphStyleAttributeName:style])
        }else{
            self.introLabel.attributedText = NSMutableAttributedString(string: "暂无简介", attributes: [NSParagraphStyleAttributeName:style])
        }
    }
}

class BookInfoCellTag: BookInfoCellBase {
    private let tagList:TagListView = TagListView()
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let superview = self.contentView
        let impressionLabel:UILabel = UILabel()
        impressionLabel.font = UIFont.systemFontOfSize(16)
        impressionLabel.textAlignment = .Center
        impressionLabel.textColor = UIColor.brownColor()
        impressionLabel.text = "印象"
        superview.addSubview(impressionLabel)
        impressionLabel.snp_makeConstraints { (make) in
            make.width.equalTo(32)
            make.height.equalTo(16)
            make.top.left.equalTo(superview).offset(8).priority(999)
        }
        
        self.tagList.textFont = UIFont.systemFontOfSize(16)
        self.tagList.alignment = .Left
        self.tagList.cornerRadius = 3.0
        superview.addSubview(self.tagList)
        self.tagList.snp_makeConstraints { (make) in
            make.top.equalTo(impressionLabel.snp_bottom).offset(8)
            make.left.equalTo(superview).offset(8)
            make.right.equalTo(superview).offset(-8)
            make.bottom.equalTo(superview).offset(-8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureCellWithBook(book:bookModel) -> Void{
        super.configureCellWithBook(book)
        self.tagList.removeAllTags()
        if book.tags.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)>0 {
            let tempArray:Array<String> = book.tags.componentsSeparatedByString(",")
            for str in tempArray{
                let tempStr = str as NSString
                if tempStr.length > 6 {
                    self.tagList.addTag(tempStr.substringToIndex(6))
                }else{
                    self.tagList.addTag(str)
                }
            }
        }else{
            self.tagList.addTag("暂无印象")
        }

    }
}

class BookInfoCellInfo: BookInfoCellBase {
    let author:UILabel = UILabel()
    let wordcount:UILabel = UILabel()
    let clickcount:UILabel = UILabel()
    let updatetime:UILabel = UILabel()
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let superview = self.contentView
        let label:UILabel = UILabel()
        label.text = "小说信息"
        label.font = UIFont.systemFontOfSize(16)
        label.textAlignment = .Center
        superview.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.width.equalTo(64)
            make.height.equalTo(20)
            make.top.equalTo(superview).offset(8).priority(999)
            make.left.equalTo(superview).offset(8)
        }
        self.author.font = UIFont.systemFontOfSize(16)
        self.author.textAlignment = .Left
        superview.addSubview(self.author)
        self.author.snp_makeConstraints { (make) in
            make.top.equalTo(label.snp_bottom).offset(4)
            make.left.equalTo(label)
            make.height.equalTo(20)
            make.right.lessThanOrEqualTo(superview)
        }
        
        self.wordcount.font = UIFont.systemFontOfSize(16)
        self.wordcount.textAlignment = .Left
        superview.addSubview(self.wordcount)
        self.wordcount.snp_makeConstraints { (make) in
            make.top.equalTo(self.author.snp_bottom).offset(4)
            make.left.equalTo(label)
            make.height.equalTo(20)
            make.right.lessThanOrEqualTo(superview)
        }
        
        self.clickcount.font = UIFont.systemFontOfSize(16)
        self.clickcount.textAlignment = .Left
        superview.addSubview(self.clickcount)
        self.clickcount.snp_makeConstraints { (make) in
            make.top.equalTo(self.wordcount.snp_bottom).offset(4)
            make.left.equalTo(label)
            make.height.equalTo(20)
            make.right.lessThanOrEqualTo(superview)
        }
        
        self.updatetime.font = UIFont.systemFontOfSize(16)
        self.updatetime.textAlignment = .Left
        superview.addSubview(self.updatetime)
        self.updatetime.snp_makeConstraints { (make) in
            make.top.equalTo(self.clickcount.snp_bottom).offset(4)
            make.left.equalTo(label)
            make.height.equalTo(20)
            make.right.lessThanOrEqualTo(superview)
            make.bottom.equalTo(superview).offset(-8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureCellWithBook(book:bookModel) -> Void{
        super.configureCellWithBook(book)
        self.author.text = "作者: "+book.author
        self.wordcount.text = "字数: "+book.wordcount
        self.clickcount.text = "点击数: "+book.clickcount
        self.updatetime.text = "更新时间: "+book.updatetime
    }
}

class BookInfoCellSS: BookInfoCellBase {
    private let sortButton:UIButton = UIButton(type: .System)
    private let statusButton:UIButton = UIButton(type: .System)
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let superview = self.contentView
        let tagLabel:UILabel = UILabel()
        tagLabel.font = UIFont.systemFontOfSize(16)
        tagLabel.textAlignment = .Center
        tagLabel.textColor = UIColor.brownColor()
        tagLabel.text = "标签"
        superview.addSubview(tagLabel)
        tagLabel.snp_makeConstraints { (make) in
            make.width.equalTo(32)
            make.height.equalTo(16)
            make.top.left.equalTo(superview).offset(8).priority(999)
        }
        self.sortButton.addTarget(self, action: #selector(self.showBookWithSort), forControlEvents: .TouchUpInside)
        self.sortButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        self.sortButton.layer.borderColor = self.sortButton.tintColor.CGColor
        self.sortButton.layer.borderWidth = 0.5
        self.sortButton.layer.cornerRadius = 16
        superview.addSubview(self.sortButton)
        self.sortButton.snp_makeConstraints { (make) in
            make.top.equalTo(tagLabel.snp_bottom).offset(6).priority(998)
            make.bottom.equalTo(superview).offset(-6)
            make.centerX.equalTo(superview.snp_centerX).offset(-superview.bounds.width*0.25)
            make.width.equalTo(100)
            make.height.equalTo(32)
        }
        self.statusButton.addTarget(self, action: #selector(self.showBookWithStatus), forControlEvents: .TouchUpInside)
        self.statusButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        self.statusButton.layer.borderColor = self.statusButton.tintColor.CGColor
        self.statusButton.layer.borderWidth = 0.5
        self.statusButton.layer.cornerRadius = 16
        superview.addSubview(self.statusButton)
        self.statusButton.snp_makeConstraints { (make) in
            make.top.bottom.equalTo(self.sortButton)
            make.centerX.equalTo(superview.snp_centerX).offset(superview.bounds.width*0.25)
            make.width.equalTo(100)
            make.height.equalTo(32)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureCellWithBook(book:bookModel) -> Void{
        super.configureCellWithBook(book)
        self.sortButton.setTitle(book.sort, forState: .Normal)
        self.statusButton.setTitle(book.status, forState: .Normal)
    }
    
    func showBookWithSort() -> Void {
        let sort = self.sortButton.titleLabel?.text
        print(sort)
    }
    
    func showBookWithStatus() -> Void {
        let status = self.statusButton.titleLabel?.text
        print(status)
    }
}