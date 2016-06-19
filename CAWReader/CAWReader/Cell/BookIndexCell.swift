//
//  BookIndexCell.swift
//  CAWReader
//
//  Created by wbuntu on 16/4/6.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

public protocol BookIndexCellDelegate:NSObjectProtocol{
    
}

class BookIndexCell: BaseTableViewCell {
    weak var delegate:BookIndexCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.snp_removeConstraints()
        self.textLabel?.font = UIFont.systemFontOfSize(16)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configureCellWithChapter(chapter: vChapter) {
        super.configureCellWithChapter(chapter)
        self.textLabel?.text = chapter.chapterTitle
    }
}








