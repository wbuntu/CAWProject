//
//  MeVersionCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/5/5.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class MeVersionCell: MeCommonCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.text = "版本"
        let label = UILabel()
        label.textAlignment = .Right
        label.textColor = UIColor.grayColor()
        let str = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        label.text = "v"+str
        self.contentView.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
