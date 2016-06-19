//
//  SettingCells.swift
//  CAWReader
//
//  Created by wbuntu on 5/15/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit

class BaseSettingCell: UITableViewCell {
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    class var cellIdentifeir:String{
        get{
            return NSStringFromClass(self.classForCoder())
        }
    }
    class var cellHeight:CGFloat{
        get{
            return 44.5
        }
    }
}

protocol SettingDataCellDelegate:NSObjectProtocol {
    func didChangeStyle() ->Void
}

class SettingDataCell: BaseSettingCell {
    weak var delegate:SettingDataCellDelegate!
    let itemLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = commonTintColor
        label.textAlignment = .Left
        return label
    }()
    let dataLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = commonTintColor
        label.textAlignment = .Right
        return label
    }()
    var cellData:Int!
    let downButton:UIButton = {
        let btn = UIButton(type: .Custom)
        btn.titleLabel?.font = UIFont.systemFontOfSize(25)
        btn.showsTouchWhenHighlighted = false
        btn.backgroundColor = UIColor.clearColor()
        btn.setTitleColor(commonTintColor, forState: .Normal)
        btn.setTitle("-", forState: .Normal)
        btn.layer.cornerRadius = 16.5
        btn.layer.borderColor = commonTintColor.CGColor
        btn.layer.borderWidth = 0.5
        return btn
    }()
    let upButton:UIButton = {
        let btn = UIButton(type: .Custom)
        btn.titleLabel?.font = UIFont.systemFontOfSize(25)
        btn.showsTouchWhenHighlighted = false
        btn.backgroundColor = UIColor.clearColor()
        btn.setTitleColor(commonTintColor, forState: .Normal)
        btn.setTitle("+", forState: .Normal)
        btn.layer.cornerRadius = 16.5
        btn.layer.borderColor = commonTintColor.CGColor
        btn.layer.borderWidth = 0.5
        return btn
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(itemLabel)
        contentView.addSubview(dataLabel)
        contentView.addSubview(downButton)
        contentView.addSubview(upButton)
        itemLabel.snp_remakeConstraints { (make) in
            make.centerY.equalTo(contentView)
            make.height.equalTo(33)
            make.left.equalTo(contentView).offset(15)
        }
        upButton.addTarget(self, action: #selector(upData), forControlEvents: .TouchUpInside)
        upButton.snp_makeConstraints { (make) in
            make.right.equalTo(contentView).offset(-15)
            make.centerY.equalTo(contentView)
            make.height.equalTo(33)
            make.width.equalTo(80)
        }
        downButton.addTarget(self, action: #selector(downData), forControlEvents: .TouchUpInside)
        downButton.snp_makeConstraints { (make) in
            make.right.equalTo(upButton.snp_left).offset(-15)
            make.centerY.equalTo(contentView)
            make.height.equalTo(33)
            make.width.equalTo(80)
        }
        
        dataLabel.snp_makeConstraints { (make) in
            make.right.equalTo(downButton.snp_left).offset(-15)
            make.centerY.equalTo(contentView)
            make.height.equalTo(33)
            make.width.equalTo(44)
        }
        configureCell()
    }
    func configureCell(){
        
    }
    
    func downData() ->Void{
        
    }
    
    func upData() ->Void{
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingLineSpacingCell: SettingDataCell {
    
    override func configureCell() {
        cellData = WWMemory.shared.lineSpacing!
        itemLabel.text = "行间距"
        dataLabel.text = String(format: "%2.1f", Float(cellData)/10)
    }
    
    override func downData() {
        if cellData > 0{
            cellData! -= 1
            WWMemory.shared.lineSpacing = cellData!
            dataLabel.text = String(format: "%2.1f", Float(cellData)/10)
            delegate.didChangeStyle()
        }
    }
    override func upData() {
        if cellData < 20{
            cellData! += 1
            WWMemory.shared.lineSpacing = cellData!
            dataLabel.text = String(format: "%2.1f", Float(cellData)/10)
            delegate.didChangeStyle()
        }
    }
}
class SettingParagraphSpacingCell: SettingDataCell {
    override func configureCell() {
        cellData = WWMemory.shared.paragraphSpacing!
        itemLabel.text = "段间距"
        dataLabel.text = String(format: "%2.1f", Float(cellData)/10)
    }
    
    override func downData() {
        if cellData > 0{
            cellData! -= 1
            WWMemory.shared.paragraphSpacing = cellData!
            dataLabel.text = String(format: "%2.1f", Float(cellData)/10)
            delegate.didChangeStyle()
        }
    }
    override func upData() {
        if cellData < 20{
            cellData! += 1
            WWMemory.shared.paragraphSpacing = cellData!
            dataLabel.text = String(format: "%2.1f", Float(cellData)/10)
            delegate.didChangeStyle()
        }
    }
}

class SettingFirstHeadindentCell: SettingDataCell {
    override func configureCell() {
        cellData = WWMemory.shared.firstHeadIndent!
        itemLabel.text = "首行缩进"
        dataLabel.text = "\(cellData)"
    }
    
    override func downData() {
        if cellData > 0{
            cellData! -= 1
            WWMemory.shared.firstHeadIndent = cellData!
            dataLabel.text = "\(cellData!)"
            delegate.didChangeStyle()
        }
    }
    override func upData() {
        if cellData < 4{
            cellData! += 1
            WWMemory.shared.firstHeadIndent = cellData!
            dataLabel.text = "\(cellData!)"
            delegate.didChangeStyle()
        }
    }
}

class SettingPreviewCell: BaseSettingCell {
    var bglayer:CALayer = {
        let layer = CALayer()
        let previewCellHeight:CGFloat = screenHeight-64-SettingDataCell.cellHeight*3-0.5
        layer.frame = CGRectMake(0, 0, screenWidth, previewCellHeight)
        layer.contents = WWMemory.shared.bgImage.CGImage
        return layer
    }()
    var contentLayer:CALayer = {
        let layer = CALayer()
        let previewCellHeight:CGFloat = screenHeight-64-SettingDataCell.cellHeight*3-0.5
        layer.frame = CGRectMake(5, 10, screenWidth-10, previewCellHeight-20)
        return layer
    }()
    var contentImage:UIImage = UIImage(){
        didSet{
            contentView.layer.contents = contentImage
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.layer.addSublayer(bglayer)
        self.contentView.layer.addSublayer(contentLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}