//
//  LibraryIndexCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/9.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class LibraryIndexCell: BaseCollectionViewCell {
    private let coverImageView:UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = UIViewContentMode.ScaleAspectFill
        return view
    }()
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(10)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        let shadowView = UIView()
        shadowView.layer.shadowOpacity = 0.8
        shadowView.layer.shadowOffset = CGSizeMake(0, 2)
        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.contentView.addSubview(shadowView)
        shadowView.addSubview(coverImageView)
        self.contentView.addSubview(titleLabel)
        
        shadowView.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(self.contentView)
            make.height.equalTo(libraryItemCoverHeiht)
        }
        
        coverImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(shadowView)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(shadowView.snp_bottom).offset(6)
            make.height.equalTo(14)
            make.width.equalTo(self.contentView)
        }
    }
    
    override func configureCellWithBook(book: bookModel) {
        super.configureCellWithBook(book)
        titleLabel.text = book.title
        if book.cover == "default.jpg"{
            self.coverImageView.image = commonPlaceHolder
        }else{
            let cover = book.cover.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            coverImageView.kf_setImageWithURL(NSURL(string: CAWResourceAddress+"/cover/"+cover)!, placeholderImage: commonPlaceHolder, optionsInfo: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
