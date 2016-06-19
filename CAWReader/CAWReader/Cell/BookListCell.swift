//
//  BookListCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/7.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import EDStarRating
import TagListView

protocol BookListCellDelegate:NSObjectProtocol {
    
}

class BookListCell: UITableViewCell {

    weak var delegate:BookListCellDelegate?
    private let coverImageView:UIImageView = UIImageView()
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
        self.contentView.layer.shouldRasterize = true
        self.contentView.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.backgroundColor = commonBackgroundColor
        self.selectionStyle = .None
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        self.contentView.snp_makeConstraints { (make) in
            make.top.equalTo(self).priority(1000)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self).offset(0.5)
        }
        
        let superview = self.contentView
        self.coverImageView.contentMode = .ScaleAspectFill
        self.coverImageView.clipsToBounds = true
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
        
        self.starRating.backgroundColor = commonBackgroundColor
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
        
        self.tagList.textFont = UIFont.systemFontOfSize(16)
        self.tagList.alignment = .Left
        self.tagList.cornerRadius = 3.0
        superview.addSubview(self.tagList)
        self.tagList.snp_makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(self.authorLabel.snp_bottom).offset(8)
            make.left.right.equalTo(self.titleLabel)
            make.bottom.equalTo(self.shadowView).offset(-0.5)
        }
        self.contentView.bringSubviewToFront(shadowView)
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
        self.titleLabel.text = book.title
        self.starRating.rating = Float(book.rating)!
        self.authorLabel.text = book.author
        self.tagList.removeAllTags()
        if book.tags.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)>0 {
            let tempArray:Array<String> = book.tags.componentsSeparatedByString(",")
            var i = 0
            for str in tempArray{
                if i>1{
                    break
                }
                let tempStr = str as NSString
                if tempStr.length > 6 {
                    self.tagList.addTag(tempStr.substringToIndex(6))
                }else{
                    self.tagList.addTag(str)
                }
                i += 1
            }
        }else{
            self.tagList.addTag("暂无印象")
        }
    }

}
