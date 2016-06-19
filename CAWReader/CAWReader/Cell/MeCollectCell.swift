//
//  MeCollectCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/5/5.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class MeCollectCell: MeCommonCell {
    private let rightDisclosure:UIImageView = UIImageView(image: UIImage(named:"ic_arrowDetail"))
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.text = "收藏"
        self.contentView.addSubview(self.rightDisclosure)
        
        self.rightDisclosure.snp_makeConstraints { (make) in
            make.width.equalTo(8)
            make.height.equalTo(13)
            make.right.equalTo(self.contentView).offset(-15)
            make.centerY.equalTo(self.contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MeSettingCell: MeCommonCell {
    private let rightDisclosure:UIImageView = UIImageView(image: UIImage(named:"ic_arrowDetail"))
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.text = "设置"
        self.contentView.addSubview(self.rightDisclosure)
        
        self.rightDisclosure.snp_makeConstraints { (make) in
            make.width.equalTo(8)
            make.height.equalTo(13)
            make.right.equalTo(self.contentView).offset(-15)
            make.centerY.equalTo(self.contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
