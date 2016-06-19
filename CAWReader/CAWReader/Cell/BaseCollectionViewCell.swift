//
//  BaseCollectionViewCell.swift
//  CAWReader
//
//  Created by wbuntu on 5/10/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = commonBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    class var cellIdentifier:String{
        get{
            return NSStringFromClass(self.classForCoder())
        }
    }
    func configureCellWithBook(book:bookModel) -> Void{
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
