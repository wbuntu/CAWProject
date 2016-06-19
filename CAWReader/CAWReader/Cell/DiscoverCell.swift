//
//  DiscoverCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/4.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import EDStarRating
class DiscoverCellCommon: UICollectionViewCell {
    let coverImageView:UIImageView = UIImageView()
    let titleLabel:UILabel = UILabel()
    let authorLabel:UILabel = UILabel()
//    let starRating:EDStarRating = EDStarRating()
    let introLabel:UILabel = UILabel()
    private let shadowView:UIView = {
        let sshadowView = UIView()
        sshadowView.layer.shadowOpacity = 0.8
        sshadowView.layer.shadowOffset = CGSizeMake(0, 3)
        sshadowView.layer.shadowColor = UIColor.blackColor().CGColor
        sshadowView.layer.shouldRasterize = true
        sshadowView.layer.rasterizationScale = UIScreen.mainScreen().scale
        return sshadowView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let bakgroundView:UIView = UIView()
        bakgroundView.frame = CGRectMake(0, 20, self.contentView.bounds.width, self.contentView.bounds.height-60)
        bakgroundView.backgroundColor = UIColor.whiteColor()
        bakgroundView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).CGColor
        bakgroundView.layer.cornerRadius = 6.0
        bakgroundView.layer.borderWidth = 0.5
        self.contentView.addSubview(bakgroundView)
        let superview = bakgroundView
        
        self.coverImageView.contentMode = .ScaleAspectFill
        self.coverImageView.clipsToBounds = true
//        let mask:CALayer = CALayer()
//        mask.frame = self.coverImageView.layer.bounds
//        mask.shadowOffset = CGSizeMake(0, 3)
//        mask.shadowOpacity = 0.9
//        self.coverImageView.layer.insertSublayer(mask, atIndex: 0)
        
        let coverContainer:UIView = UIView()
        coverContainer.addSubview(self.shadowView)
        self.shadowView.snp_makeConstraints { (make) in
            make.width.equalTo(110)
            make.height.equalTo(156)
            make.center.equalTo(coverContainer)
        }
        self.shadowView.addSubview(self.coverImageView)
        
        self.coverImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(shadowView)
        }
        
        superview.addSubview(coverContainer)
        coverContainer.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(138)
            make.height.equalTo(182)
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(8)
        }
        
        self.titleLabel.numberOfLines = 2
        self.titleLabel.font = UIFont.systemFontOfSize(19)
        self.titleLabel.textAlignment = .Center
        self.titleLabel.lineBreakMode = .ByWordWrapping
        superview.addSubview(self.titleLabel)
        self.titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(coverContainer.snp_bottom)
            make.centerX.equalTo(superview)
            make.width.equalTo(superview.bounds.width-32)
        }
        
        self.authorLabel.font = UIFont.systemFontOfSize(15)
        self.authorLabel.textAlignment = .Center
        superview.addSubview(self.authorLabel)
        self.authorLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp_bottom).offset(4)
            make.width.equalTo(self.titleLabel)
            make.centerX.equalTo(superview)
        }
        
//        self.starRating.backgroundColor = UIColor.whiteColor()
//        self.starRating.starImage = UIImage(named: "star-template")!
//        self.starRating.starHighlightedImage = UIImage(named: "star-highlighted-template")!
//        self.starRating.maxRating = 10
//        self.starRating.rating = 0.0
//        self.starRating.userInteractionEnabled = false
//        self.starRating.displayMode = EDStarRatingDisplayAccurate
//        superview.addSubview(self.starRating)
//        self.starRating.snp_makeConstraints { (make) in
//            make.width.equalTo(superview.bounds.width-60)
//            make.height.equalTo(44)
//            make.top.equalTo(authorLabel.snp_bottom)
//            make.centerX.equalTo(superview)
//        }
        
        self.introLabel.font = UIFont.systemFontOfSize(16)
        self.introLabel.numberOfLines = 0
        self.introLabel.textAlignment = .Center
        self.introLabel.lineBreakMode = .ByWordWrapping
        superview.addSubview(self.introLabel)
        self.introLabel.snp_makeConstraints { (make) in
            make.width.equalTo(self.titleLabel)
            make.centerX.equalTo(superview)
            make.top.equalTo(self.authorLabel.snp_bottom).offset(4).priority(1000)
            make.bottom.lessThanOrEqualTo(superview)
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configureCellWithBook(book:bookModel) -> Void{
        if book.cover == "default.jpg"{
            self.coverImageView.image = commonPlaceHolder
        }else{
            let cover = book.cover.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            self.coverImageView.kf_setImageWithURL(NSURL(string: CAWResourceAddress+"/cover/"+cover)!, placeholderImage: commonPlaceHolder, optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }
        self.titleLabel.text  = book.title
        self.authorLabel.text = book.author
//        self.starRating.rating = Float(book.rating)!
        let style:NSMutableParagraphStyle = NSMutableParagraphStyle()
        if let str = book.subIntro{
            if book.numberOfLines == 1 {
                style.alignment = .Center
            }else{
                style.alignment = .Left
                style.firstLineHeadIndent = self.introLabel.font.pointSize
            }
            self.introLabel.attributedText = NSMutableAttributedString(string: str, attributes: [NSParagraphStyleAttributeName:style])
        }else{
            self.introLabel.text = "暂无简介"
        }
    }
}

public protocol DiscoverCellEndProtocol:NSObjectProtocol{
    func loadAnotherBatchOfBook() -> Void
}

class DiscoverCellEnd: UICollectionViewCell {
    weak var delegate:DiscoverCellEndProtocol?
    let coverImageView:UIImageView = UIImageView()
    let findMoreButton:UIButton = UIButton(type: UIButtonType.System)
    override init(frame: CGRect) {
        super.init(frame: frame)
        let superview = self.contentView
        let layer = CALayer()
        layer.frame = CGRectMake(0, 20, self.contentView.bounds.width, self.contentView.bounds.height-60)
        layer.backgroundColor = UIColor.whiteColor().CGColor
        layer.borderColor = UIColor(white: 0.8, alpha: 1.0).CGColor
        layer.cornerRadius = 6.0
        layer.borderWidth = 0.5
        superview.layer.insertSublayer(layer, above: superview.layer)
        
        self.coverImageView.contentMode = .ScaleAspectFill
        self.coverImageView.layer.borderWidth = 1.0
        self.coverImageView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).CGColor
        self.coverImageView.layer.cornerRadius = 6.0
        self.coverImageView.clipsToBounds = true
        self.coverImageView.image = commonPlaceHolder
        //        let mask:CALayer = CALayer()
        //        mask.frame = self.coverImageView.layer.bounds
        //        mask.shadowOffset = CGSizeMake(0, 3)
        //        mask.shadowOpacity = 0.9
        //        self.coverImageView.layer.insertSublayer(mask, atIndex: 0)
        
        let coverContainer:UIView = UIView()
        coverContainer.addSubview(self.coverImageView)
        self.coverImageView.snp_makeConstraints { (make) in
            make.width.equalTo(110)
            make.height.equalTo(156)
            make.center.equalTo(coverContainer)
        }
        
        superview.addSubview(coverContainer)
        coverContainer.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(138)
            make.height.equalTo(182)
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(30)
        }
        
        let findMoreLabel:UILabel = UILabel()
        findMoreLabel.font = UIFont.systemFontOfSize(18)
        findMoreLabel.textAlignment = .Center
        findMoreLabel.text = "发现更多的小说"
        superview.addSubview(findMoreLabel)
        findMoreLabel.snp_makeConstraints { (make) in
            make.top.equalTo(coverContainer.snp_bottom)
            make.centerX.equalTo(superview)
            make.width.equalTo(140)
        }
        
        
        let changeBatchButton:UIButton = UIButton(type: UIButtonType.System)
        changeBatchButton.setTitle("换一批", forState: UIControlState.Normal)
        changeBatchButton.addTarget(self, action: #selector(self.changeBatchBook), forControlEvents: UIControlEvents.TouchUpInside)
        changeBatchButton.layer.cornerRadius = 20
        changeBatchButton.layer.borderColor = self.findMoreButton.tintColor.CGColor
        changeBatchButton.layer.borderWidth = 0.5
        superview.addSubview(changeBatchButton)
        changeBatchButton.snp_makeConstraints { (make) in
            make.top.equalTo(findMoreLabel.snp_bottom).offset(60)
            make.centerX.equalTo(superview)
            make.height.equalTo(40)
            make.width.equalTo(160)
        }
        
        self.findMoreButton.setTitle("去找小说", forState: UIControlState.Normal)
        self.findMoreButton.addTarget(self, action: #selector(self.findMoreBook), forControlEvents: UIControlEvents.TouchUpInside)
        self.findMoreButton.layer.cornerRadius = 20
        self.findMoreButton.layer.borderColor = self.findMoreButton.tintColor.CGColor
        self.findMoreButton.layer.borderWidth = 0.5
        superview.addSubview(self.findMoreButton)
        self.findMoreButton.snp_makeConstraints { (make) in
            make.top.equalTo(changeBatchButton.snp_bottom).offset(8)
            make.centerX.equalTo(superview)
            make.height.equalTo(40)
            make.width.equalTo(160)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeBatchBook() -> Void {
        self.delegate?.loadAnotherBatchOfBook()
    }
    
    
    func findMoreBook() -> Void {
//        self.findMoreButton.userInteractionEnabled = false
        NSNotificationCenter.defaultCenter().postNotificationName(showLibraryNofification, object: nil)
    }
}














