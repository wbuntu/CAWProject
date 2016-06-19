//
//  ReaderFontCell.swift
//  CAWReader
//
//  Created by wbuntu on 5/14/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit

class BaseReaderFontCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = commonBackgroundColor
        self.selectionStyle = .None
        self.separatorInset = UIEdgeInsetsZero
        self.layoutMargins = UIEdgeInsetsZero
        self.preservesSuperviewLayoutMargins = false
        self.contentView.snp_makeConstraints { (make) in
            make.top.equalTo(self).priority(1000)
            make.left.right.bottom.equalTo(self)
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
            return 44.0
        }
    }
    class func buttonWithTitle(title:String) ->UIButton{
        let button:UIButton = UIButton(type: .Custom)
        button.backgroundColor = UIColor.clearColor()
        button.showsTouchWhenHighlighted = false
        button.titleLabel?.font = UIFont.systemFontOfSize(14)
        button.setTitleColor(commonTintColor, forState: .Normal)
        button.setTitle(title, forState: .Normal)
        return button
    }
    class func buttonWithImage(image:UIImage) ->UIButton{
        let button:UIButton = UIButton(type: .Custom)
        button.backgroundColor = UIColor.clearColor()
        button.showsTouchWhenHighlighted = false
        button.setImage(image, forState: .Normal)
        return button
    }
}

protocol ReaderFontSliserCellDelegate:NSObjectProtocol {
    func showPreviousChapter() ->Void
    func showNextChapter() ->Void
    func didSlideToPosition(position:Float) ->Void
}

class ReaderFontSliserCell: BaseReaderFontCell {
    weak var delegate:ReaderFontSliserCellDelegate!
    let leftButton:UIButton = ReaderFontSliserCell.buttonWithTitle("上一章")
    let rightButton:UIButton = ReaderFontSliserCell.buttonWithTitle("下一章")
    let slider:UISlider = {
        let tempSlider = UISlider()
        tempSlider.tintColor = commonTintColor
        return tempSlider
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(leftButton)
        contentView.addSubview(rightButton)
        contentView.addSubview(slider)
        
        leftButton.addTarget(self, action: #selector(showLastChapter), forControlEvents: .TouchUpInside)
        rightButton.addTarget(self, action: #selector(showNextChapter), forControlEvents: .TouchUpInside)
        slider.addTarget(self, action: #selector(sliderDidSlide), forControlEvents: .TouchUpInside)
        
        leftButton.snp_makeConstraints { (make) in
            make.left.equalTo(contentView).offset(8)
            make.width.equalTo(44)
            make.top.bottom.equalTo(contentView)
        }
        
        slider.snp_makeConstraints { (make) in
            make.left.equalTo(leftButton.snp_right).offset(8)
            make.top.bottom.equalTo(contentView)
        }
        
        rightButton.snp_makeConstraints { (make) in
            make.left.equalTo(slider.snp_right).offset(8)
            make.right.equalTo(contentView).offset(-8)
            make.width.equalTo(44)
            make.top.bottom.equalTo(contentView)
        }
        
    }
    
    func showLastChapter() ->Void{
        delegate.showPreviousChapter()
    }
    
    func showNextChapter() ->Void{
        delegate.showNextChapter()
    }
    
    func sliderDidSlide(wSlider:UISlider) ->Void{
        delegate.didSlideToPosition(wSlider.value)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol ReaderFontThemeCellDelegate:NSObjectProtocol {
    func showMoreTheme() ->Void
}

class ReaderFontThemeCell: BaseReaderFontCell {
    weak var delegate:ReaderFontThemeCellDelegate!
    let themeLabel:UILabel = {
        let label = UILabel(frame: CGRectMake(9,5.5,28,33))
        label.font = UIFont.systemFontOfSize(14)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = commonTintColor
        label.text = "主题"
        label.textAlignment = .Center
        return label
    }()
    
    let imageButtons:[UIButton] = {
        let itemWidth:CGFloat = (screenWidth-9-28-4*5-8-70-9)/4
        var buttons:[UIButton] = [UIButton]()
        for i in 0..<4{
            let button = UIButton(type: .Custom)
            button.backgroundColor = UIColor.clearColor()
            button.frame = CGRectMake(9+28+8+CGFloat(i)*(4+itemWidth), 0, itemWidth, 44)
            buttons.append(button)
        }
        return buttons
    }()
    let imageViews:[UIView] = {
        let rect = CGRectMake(0, 0, 33, 33)
        let v1 = UIView(frame: rect)
        v1.backgroundColor = ReaderTheme.complex_default.colorComponent().backgroundColor
        v1.layer.cornerRadius = 16.5
        v1.layer.masksToBounds = true
        
        let v2 = UIView(frame: rect)
        v2.backgroundColor = ReaderTheme.complex_5.colorComponent().backgroundColor
        v2.layer.cornerRadius = 16.5
        v2.layer.masksToBounds = true
        
        let v3 = UIView(frame: rect)
        v3.backgroundColor = ReaderTheme.complex_4.colorComponent().backgroundColor
        v3.layer.cornerRadius = 16.5
        v3.layer.masksToBounds = true
        
        let v4 = UIView(frame: rect)
        v4.backgroundColor = ReaderTheme.pure_6.colorComponent().backgroundColor
        v4.layer.cornerRadius = 16.5
        v4.layer.masksToBounds = true
        
        let views:[UIView] = [v1,v2,v3,v4]
        return views
    }()
    let themes:[ReaderTheme] = [.complex_default,.complex_5,.complex_4,.pure_6]
    
    let moreButton:UIButton = {
        let btn = UIButton(type: .Custom)
        btn.titleLabel?.font = UIFont.systemFontOfSize(14)
        btn.showsTouchWhenHighlighted = false
        btn.backgroundColor = UIColor.clearColor()
        btn.setTitleColor(commonTintColor, forState: .Normal)
        btn.setTitle("更多", forState: .Normal)
        btn.layer.cornerRadius = 16.5
        btn.layer.borderColor = commonTintColor.CGColor
        btn.layer.borderWidth = 0.5
        btn.frame = CGRectMake(screenWidth-70-9, 5.5, 70, 33)
        return btn
    }()
    //15+28+8+buttonWidth*4+8*3+8+44+15 = screenWidth
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(themeLabel)
        let itemWidth:CGFloat = (screenWidth-9-28-4*5-8-70-9)/4
        let origin = CGPointMake((itemWidth-33)/2, 5.5)
        for i in 0..<4{
            let btn = imageButtons[i]
            btn.addTarget(self, action: #selector(switchThemeButton), forControlEvents: .TouchUpInside)
            contentView.addSubview(btn)
            let im = imageViews[i]
            im.userInteractionEnabled = false
            im.frame.origin = origin
            btn.addSubview(im)
        }
        moreButton.addTarget(self, action: #selector(showMore), forControlEvents: .TouchUpInside)
        contentView.addSubview(moreButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func switchThemeButton(btn:UIButton) ->Void{
        let index = imageButtons.indexOf(btn)!
        let theme = themes[index]
        WWMemory.shared.theme = theme
        WWMemory.shared.renderTheme()
    }
    
    func showMore() ->Void{
        delegate.showMoreTheme()
    }
}

protocol ReaderFontSizeCellDelegate:NSObjectProtocol {
    func sizeCellSizeUp() ->Void
    func sizeCellSizeDown() ->Void
}

class ReaderFontSizeCell: BaseReaderFontCell {
    weak var delegate:ReaderFontSizeCellDelegate!
    let fontLabel:UILabel = {
        let label = UILabel(frame: CGRectMake(9,5.5,28,33))
        label.font = UIFont.systemFontOfSize(14)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = commonTintColor
        label.text = "字号"
        label.textAlignment = .Center
        return label
    }()
    let sizeDownButton:UIButton = {
        let width = (screenWidth-9-28-8*2-9)/2
        let btn = UIButton(type: .Custom)
        btn.titleLabel?.font = UIFont.systemFontOfSize(14)
        btn.showsTouchWhenHighlighted = false
        btn.backgroundColor = UIColor.clearColor()
        btn.setTitleColor(commonTintColor, forState: .Normal)
        btn.setTitle("小", forState: .Normal)
        btn.layer.cornerRadius = 16.5
        btn.layer.borderColor = commonTintColor.CGColor
        btn.layer.borderWidth = 0.5
        btn.frame = CGRectMake(9+28+8, 5.5, width, 33)
        return btn
    }()
    let sizeUpButton:UIButton = {
        let width = (screenWidth-9-28-8*2-9)/2
        let btn = UIButton(type: .Custom)
        btn.titleLabel?.font = UIFont.systemFontOfSize(14)
        btn.showsTouchWhenHighlighted = false
        btn.backgroundColor = UIColor.clearColor()
        btn.setTitleColor(commonTintColor, forState: .Normal)
        btn.setTitle("大", forState: .Normal)
        btn.layer.cornerRadius = 16.5
        btn.layer.borderColor = commonTintColor.CGColor
        btn.layer.borderWidth = 0.5
        btn.frame = CGRectMake(screenWidth-9-width, 5.5, width, 33)
        return btn
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(fontLabel)
        
        sizeDownButton.addTarget(self, action: #selector(sizeDown), forControlEvents: .TouchUpInside)
        contentView.addSubview(sizeDownButton)
        
        sizeUpButton.addTarget(self, action: #selector(sizeUp), forControlEvents: .TouchUpInside)
        contentView.addSubview(sizeUpButton)
    }
    
    func sizeUp() ->Void{
        delegate.sizeCellSizeUp()
    }
    
    func sizeDown() ->Void{
        delegate.sizeCellSizeDown()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}