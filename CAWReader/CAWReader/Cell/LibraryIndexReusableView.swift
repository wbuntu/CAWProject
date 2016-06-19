//
//  LibraryIndexReusableView.swift
//  CAWReader
//
//  Created by wbuntu on 5/10/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit

protocol LibraryIndexReusableViewDelegate:NSObjectProtocol {
    func showAllBooksFromLocation(section:Int) ->Void
}

class LibraryIndexReusableView: UICollectionReusableView {
    weak var delegate:LibraryIndexReusableViewDelegate!
    var currentSection:Int!
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(18)
        label.textColor = commonTintColor
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = .Left
        return label
    }()
    let allButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.titleLabel?.font = UIFont.systemFontOfSize(13)
        button.setTitle("全部", forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.setTitleColor(UIColor.grayColor(), forState: .Normal)
        button.showsTouchWhenHighlighted = false
        return button
    }()
    private let rightDisclosure:UIImageView = UIImageView(image: UIImage(named:"ic_arrowDetail"))
    private let separator:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xFFC8C7CC)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = commonBackgroundColor
        
        self.addSubview(titleLabel)
        self.addSubview(allButton)
        self.addSubview(rightDisclosure)
        self.addSubview(separator)
        
        titleLabel.snp_makeConstraints { (make) in
            make.height.equalTo(18)
            make.left.equalTo(self).offset(15)
            make.centerY.equalTo(self)
        }
        
        rightDisclosure.snp_makeConstraints { (make) in
            make.width.equalTo(8)
            make.height.equalTo(13)
            make.right.equalTo(self).offset(-15)
            make.centerY.equalTo(self)
        }
        allButton.addTarget(self, action: #selector(didClickAllButton), forControlEvents: .TouchUpInside)
        allButton.snp_makeConstraints { (make) in
            make.right.equalTo(rightDisclosure.snp_left).offset(-8)
            make.width.equalTo(44)
            make.height.equalTo(self)
            make.centerY.equalTo(self)
        }
        
        separator.snp_makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.equalTo(self).offset(15)
            make.right.bottom.equalTo(self)
        }
    }
    
    func didClickAllButton() -> Void{
        delegate.showAllBooksFromLocation(currentSection)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    class var cellIdentifier:String{
        get{
            return NSStringFromClass(self.classForCoder())
        }
    }
    
    class var cellHeight:CGFloat{
        get{
            return 28
        }
    }
}
