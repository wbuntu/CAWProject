//
//  ReaderCollectionCell.swift
//  CAWReader
//
//  Created by wbuntu on 5/12/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit

class ReaderCollectionCell: UICollectionViewCell {
    
    var image:UIImage=UIImage(){
        didSet{
            contentLayer.contents = image.CGImage
        }
    }
    
    let bgLayer:CALayer = {
        let layer = CALayer()
        layer.frame = UIScreen.mainScreen().bounds
        layer.contents = WWMemory.shared.bgImage.CGImage
        return layer
    }()
    let contentLayer:CALayer = {
        let layer = CALayer()
        layer.frame = CGRectMake(5, 10, UIScreen.mainScreen().bounds.width-10, UIScreen.mainScreen().bounds.height-20)
        return layer
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.userInteractionEnabled = false
        self.backgroundColor = commonBackgroundColor
        self.contentView.layer.addSublayer(bgLayer)
        self.contentView.layer.addSublayer(contentLayer)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(renderBG), name: kChangeBGLayerNotificaton, object: nil)
    }
    
    func renderBG() ->Void{
        bgLayer.contents = WWMemory.shared.bgImage.CGImage
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    class var cellIdentifier:String{
        get{
            return NSStringFromClass(self.classForCoder())
        }
    }
}
