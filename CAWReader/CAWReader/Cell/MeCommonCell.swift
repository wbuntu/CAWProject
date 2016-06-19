//
//  MeCommonCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/5/5.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class MeCommonCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        self.selectionStyle = .None
        let headSepearator = UIView()
        headSepearator.backgroundColor = UIColor(hex: 0xFFC8C7CC)
        
        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = UIColor(hex: 0xFFC8C7CC)
        
        self.contentView.addSubview(headSepearator)
        self.contentView.addSubview(bottomSeparator)
        
        headSepearator.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
        
        bottomSeparator.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.contentView)
            make.height.equalTo(0.5)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
