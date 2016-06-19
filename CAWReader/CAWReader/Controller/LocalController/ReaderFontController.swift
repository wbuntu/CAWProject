//
//  ReaderFontController.swift
//  CAWReader
//
//  Created by wbuntu on 5/14/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit
import pop
protocol ReaderFontControllerDelegate:NSObjectProtocol {
    func showIndex() ->Void
    func showBookmark() ->Void
    func showFont() ->Void
    func upFontSize() ->Void
    func downFontSize() ->Void
    func showNext() ->Void
    func showPrevious() ->Void
    func slideToPoint(point:Float) ->Void
}

class ReaderFontController: BaseController {
    weak var delegate:ReaderFontControllerDelegate!
    var currentPonit:Float!
    let indexButton:UIButton = {
        let button:UIButton = UIButton(type: .Custom)
        button.frame = CGRectMake(15, 0, 49, 49)
        button.setImage(UIImage(named: "index"), forState: .Normal)
        button.showsTouchWhenHighlighted = false
        return button
    }()
    let bookmakrButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named:"bookmark"), forState: .Normal)
        button.showsTouchWhenHighlighted = false
        button.frame = CGRectMake(screenWidth-15-49, 0, 49, 49)
        return button
    }()
    
    let fontButton:UIButton = {
        let button = UIButton(type: .Custom)
        button.setImage(UIImage(named:"font"), forState: .Normal)
        button.setImage(UIImage(named:"fontEmpty"), forState: .Selected)
        button.showsTouchWhenHighlighted = false
        button.frame = CGRectMake((screenWidth-49)/2, 0, 49, 49)
        return button
    }()
    var isOnScreen:Bool = false{
        didSet{
            showFontPannel()
        }
    }
    let fontCellHeight:CGFloat = 44.5
    var tableView:UITableView!
    var tap:UITapGestureRecognizer!
    var moreThemeView:UIView!
    let themes:[ReaderTheme] = [.pure_1,.pure_2,.pure_3,.pure_4,.pure_5,.pure_6,.pure_7,.pure_8,.pure_9,.pure_10,.pure_11,.pure_12,.complex_1,.complex_2,.complex_3,.complex_4,.complex_5,.complex_default]
    //width: 8+itemWidth*6+4*5+8
    //height 49+44*3 = 21+44*2+20
    //19  44  4  44  4  18  44  4
    let pureLabel:UILabel = {
        let label = UILabel(frame: CGRectMake(8,4,28,19))
        label.font = UIFont.systemFontOfSize(14)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = commonTintColor
        label.text = "纯色"
        label.textAlignment = .Center
        return label
    }()
    let complexLabel:UILabel = {
        let label = UILabel(frame: CGRectMake(8,19+44+4+44+4+4,28,18))
        label.font = UIFont.systemFontOfSize(14)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = commonTintColor
        label.text = "纹理"
        label.textAlignment = .Center
        return label
    }()
    let imageButtons:[UIButton] = {
        let itemWidth:CGFloat = (screenWidth-(8+4*5+8))/6
        var buttons:[UIButton] = [UIButton]()
        for i in 0..<6{
            let button = UIButton(type: .Custom)
            button.backgroundColor = UIColor.clearColor()
            button.frame = CGRectMake(8+CGFloat(i)*(4+itemWidth), 19+4, itemWidth, 44)
            buttons.append(button)
        }
        for i in 0..<6{
            let button = UIButton(type: .Custom)
            button.backgroundColor = UIColor.clearColor()
            button.frame = CGRectMake(8+CGFloat(i)*(4+itemWidth), 19+44+4+4, itemWidth, 44)
            buttons.append(button)
        }
        
        for i in 0..<6{
            let button = UIButton(type: .Custom)
            button.backgroundColor = UIColor.clearColor()
            button.frame = CGRectMake(8+CGFloat(i)*(4+itemWidth), 19+44+4+44+4+18+4, itemWidth, 44)
            buttons.append(button)
        }
        
        return buttons
    }()
    let imageViews:[UIView] = {
        let themes:[ReaderTheme] = [.pure_1,.pure_2,.pure_3,.pure_4,.pure_5,.pure_6,.pure_7,.pure_8,.pure_9,.pure_10,.pure_11,.pure_12,.complex_1,.complex_2,.complex_3,.complex_4,.complex_5,.complex_default]
        let itemWidth:CGFloat = (screenWidth-(8+4*5+8))/6
        let origin = CGPointMake((itemWidth-33)/2, 5.5)
        let rect = CGRectMake(0, 0, 33, 33)
        var views:[UIView] = [UIView]()
        for theme in themes{
            let v = UIView(frame: rect)
            v.frame.origin = origin
            v.backgroundColor = theme.colorComponent().backgroundColor
            v.layer.cornerRadius = 16.5
            v.layer.masksToBounds = true
            v.userInteractionEnabled = false
            views.append(v)
        }
        return views
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        
        let emptyView = UIView(frame: CGRectMake(0,0,screenWidth,self.view.height-49-BaseReaderFontCell.cellHeight*3))
        emptyView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(emptyView)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        emptyView.addGestureRecognizer(tap)
        tap.enabled = false
        
        let pannelView:UIView = UIView(frame: CGRectMake(0,self.view.height-49,screenWidth,49))
        pannelView.backgroundColor = commonBackgroundColor
        self.view.addSubview(pannelView)
        
        pannelView.addSubview(indexButton)
        indexButton.addTarget(self, action: #selector(handleIndex), forControlEvents: .TouchUpInside)
        
        pannelView.addSubview(fontButton)
        fontButton.addTarget(self, action: #selector(handleFont), forControlEvents: .TouchUpInside)
        
        pannelView.addSubview(bookmakrButton)
        bookmakrButton.addTarget(self, action: #selector(handleBookmark), forControlEvents: .TouchUpInside)
        
        tableView = UITableView(frame: CGRectMake(0, self.view.height-49, self.view.width, 0), style: .Plain)
        tableView.backgroundColor = commonBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.hidden = true
        tableView.registerClass(ReaderFontSizeCell.self, forCellReuseIdentifier: ReaderFontSizeCell.cellIdentifeir)
        tableView.registerClass(ReaderFontThemeCell.self, forCellReuseIdentifier: ReaderFontThemeCell.cellIdentifeir)
        tableView.registerClass(ReaderFontSliserCell.self, forCellReuseIdentifier: ReaderFontSliserCell.cellIdentifeir)
        tableView.rowHeight = BaseReaderFontCell.cellHeight
        self.view.addSubview(tableView)
        
        moreThemeView = UIView(frame: CGRectMake(0, self.view.height-49-BaseReaderFontCell.cellHeight*3-4, self.view.width, BaseReaderFontCell.cellHeight*3+49+4))
        self.view.addSubview(moreThemeView)
        moreThemeView.backgroundColor = commonBackgroundColor
        moreThemeView.addSubview(pureLabel)
        moreThemeView.addSubview(complexLabel)
        for btn in imageButtons{
            btn.addTarget(self, action: #selector(switchThemeButton), forControlEvents: .TouchUpInside)
            moreThemeView.addSubview(btn)
            let index = imageButtons.indexOf(btn)!
            let imageView = imageViews[index]
            btn.addSubview(imageView)
        }
        moreThemeView.alpha = 0
    }
    
    func switchThemeButton(btn:UIButton) ->Void{
        let index = imageButtons.indexOf(btn)!
        let theme = themes[index]
        WWMemory.shared.theme = theme
        WWMemory.shared.renderTheme()
    }
    
    func tapHandler() ->Void{
        if moreThemeView.alpha == 0{
           handleFont(fontButton)
        }else{
            UIView.animateWithDuration(0.4, animations: { 
                self.moreThemeView.alpha = 0
            })
        }
    }
    
    func handleIndex() ->Void{
        delegate.showIndex()
    }
    
    func handleBookmark() ->Void{
        delegate.showBookmark()
    }
    
    func handleFont(btn:UIButton) ->Void{
        delegate.showFont()
        btn.selected = !btn.selected
        if btn.selected{
            tap.enabled = true
            indexButton.hidden = true
            bookmakrButton.hidden = true
        }else{
            tap.enabled = false
            indexButton.hidden = false
            bookmakrButton.hidden = false
        }
    }
    
    func showFontPannel() ->Void{
        if isOnScreen{
            tableView.hidden = false
            let show:POPSpringAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            show.toValue = NSValue(CGRect: CGRectMake(0, self.view.height-49-BaseReaderFontCell.cellHeight*3, self.view.width, BaseReaderFontCell.cellHeight*3))
            show.completionBlock = {[weak self](animation,finished) in
                if let strongSelf = self{
                    if finished{
                        strongSelf.tableView.reloadData()
                    }
                }
            }
            tableView.pop_addAnimation(show, forKey: "kShow")
        }else{
            let hide:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
            hide.toValue = NSValue(CGRect: CGRectMake(0, self.view.height-49, self.view.width, 0))
            hide.completionBlock = {[weak self] (animation,finished) in
                if let strongSelf = self{
                    strongSelf.tableView.hidden = true
                }
            }
            tableView.pop_addAnimation(hide, forKey: "kHide")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ReaderFontController:UITableViewDelegate, UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch  indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(ReaderFontSizeCell.cellIdentifeir, forIndexPath: indexPath) as! ReaderFontSizeCell
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(ReaderFontThemeCell.cellIdentifeir, forIndexPath: indexPath) as! ReaderFontThemeCell
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(ReaderFontSliserCell.cellIdentifeir, forIndexPath: indexPath) as! ReaderFontSliserCell
            cell.slider.value = currentPonit
            cell.delegate = self
            return cell
        default:
            break
        }
       return UITableViewCell()
    }
}

extension ReaderFontController:ReaderFontSizeCellDelegate, ReaderFontThemeCellDelegate,ReaderFontSliserCellDelegate{
    func sizeCellSizeUp() {
        delegate.upFontSize()
    }
    func sizeCellSizeDown() {
        delegate.downFontSize()
    }
    
    func showPreviousChapter() {
        delegate.showPrevious()
    }
    
    func showNextChapter() {
        delegate.showNext()
    }
    
    func didSlideToPosition(position:Float) {
        delegate.slideToPoint(position)
    }
    
    func showMoreTheme() {
        UIView.animateWithDuration(0.4, animations: {
            self.moreThemeView.alpha = 1
        })
    }
}


