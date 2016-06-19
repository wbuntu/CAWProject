//
//  MeExitCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/5/5.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class MeExitCell: MeCommonCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(18)
        label.textAlignment = .Center
        label.textColor = UIColor.redColor()
        label.text = "退出当前账号"
        self.contentView.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.center.equalTo(self.contentView)
            make.height.equalTo(18)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
