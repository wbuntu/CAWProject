//
//  BaseTableViewCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/7.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import SnapKit
class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        self.contentView.snp_makeConstraints { (make) in
            make.top.equalTo(self).priority(1000)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self).offset(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configureCellWithBook(book:bookModel) -> Void{
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    func configureCellWithChapter(chapter:vChapter) -> Void{
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
