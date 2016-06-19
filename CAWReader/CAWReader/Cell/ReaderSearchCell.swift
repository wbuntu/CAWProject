//
//  ReaderSearchCell.swift
//  CAWReader
//
//  Created by wbuntu on 5/13/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit

class ReaderSearchCell: UITableViewCell {
    let page:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = commonTintColor
        label.backgroundColor = UIColor.clearColor()
        return label
    }()
    let result:UILabel = {
        let label = UILabel()
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clearColor()
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        self.contentView.addSubview(page)
        self.contentView.addSubview(result)
        page.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(15)
            make.top.equalTo(contentView).offset(8)
            make.height.equalTo(13)
        }
        
        result.snp_makeConstraints { (make) in
            make.left.equalTo(page)
            make.top.equalTo(page.snp_bottom).offset(8)
            make.right.equalTo(contentView).offset(-15)
            make.bottom.equalTo(contentView).offset(-8)
        }
    }
    
    func configure(tuple:(NSAttributedString,Int)) ->Void{
        page.text = "第\(tuple.1+1)页"
        result.attributedText = tuple.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
