//
//  MeHeaderCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/5/5.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class MeHeaderCell: UITableViewCell {
    let avatar:UIImageView = UIImageView(image: UIImage(named:"ic_headportraits"))
    let nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(16)
        label.textAlignment = .Center
        label.backgroundColor = UIColor.clearColor()
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        self.backgroundColor = UIColor.clearColor()
        
        self.contentView.addSubview(avatar)
        avatar.snp_makeConstraints { (make) in
            make.top.equalTo(self.contentView).offset(8)
            make.centerX.equalTo(self.contentView)
            make.width.height.equalTo(80)
        }
        self.contentView.addSubview(nameLabel)
        self.nameLabel.snp_makeConstraints { (make) in
            make.top.equalTo(avatar.snp_bottom).offset(15)
            make.centerX.equalTo(self.contentView)
            make.height.equalTo(17)
            make.width.lessThanOrEqualTo(self.contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
