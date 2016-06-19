//
//  ReaderTheme.swift
//  CAWReader
//
//  Created by wbuntu on 5/14/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit

struct ReaderColorComponent {
    let backgroundColor:UIColor
    let textColor:UIColor
    let headerFooterColor:UIColor
}

enum ReaderTheme:Int {
    case pure_1
    case pure_2
    case pure_3
    case pure_4
    case pure_5
    case pure_6
    case pure_7
    case pure_8
    case pure_9
    case pure_10
    case pure_11
    case pure_12
    
    case complex_default
    case complex_1
    case complex_2
    case complex_3
    case complex_4
    case complex_5
    static let pureThemeArray:[ReaderTheme] = [.pure_1,.pure_2,.pure_3,.pure_4,.pure_5,.pure_6,.pure_7,.pure_8,.pure_9,.pure_10,.pure_11,.pure_12]
    static let pureColorScheme:[((CGFloat,CGFloat,CGFloat),(CGFloat,CGFloat,CGFloat),(CGFloat,CGFloat,CGFloat))] = [
        ((254,255,255),(0,0,0),(180,181,181)),
        ((239,236,226),(59,56,45),(168,165,155)),
        ((227,215,190),(57,49,35),(174,163,144)),
        ((219,211,197),(42,42,38),(166,160,152)),
        ((163,164,165),(28,29,30),(123,124,125)),
        ((0,0,0),(117,118,119),(73,74,75)),
        ((223,233,204),(67,70,59),(177,185,164)),
        ((198,237,205),(62,78,58),(150,179,156)),
        ((51,82,76),(155,170,166),(98,122,118)),
        ((39,60,52),(173,198,181),(98,118,110)),
        ((38,53,73),(177,187,197),(102,112,128)),
        ((90,66,44),(170,160,150),(129,108,92))
    ]
    static let complexThemeArray:[ReaderTheme] = [.complex_1,.complex_2,.complex_3,.complex_4,.complex_5,.complex_default]
    static let complexColorScheme:[(String,(CGFloat,CGFloat,CGFloat),(CGFloat,CGFloat,CGFloat))] = [
        ("complex_bg_1",(62,63,64),(181,182,182)),
        ("complex_bg_2",(54,59,51),(162,156,132)),
        ("complex_bg_3",(52,55,46),(144,149,120)),
        ("complex_bg_4",(53,48,44),(145,131,111)),
        ("complex_bg_5",(207,208,209),(112,117,121)),
        ("parchment1",(52,49,42),(150,123,89))
    ]
    func colorComponent() ->ReaderColorComponent{
        switch self {
        case .pure_1,.pure_2,.pure_3,.pure_4,.pure_5,.pure_6,.pure_7,.pure_8,.pure_9,.pure_10,.pure_11,.pure_12:
            
            let index = ReaderTheme.pureThemeArray.indexOf(self)!
            
            let color = ReaderTheme.pureColorScheme[index]
            
            let colorComponent:ReaderColorComponent = ReaderColorComponent(backgroundColor: UIColor.RGB(color.0), textColor: UIColor.RGB(color.1), headerFooterColor: UIColor.RGB(color.2))
            
            return colorComponent
        case .complex_1,.complex_2,.complex_3,.complex_4,.complex_5,.complex_default:
            let index = ReaderTheme.complexThemeArray.indexOf(self)!
            
            let color = ReaderTheme.complexColorScheme[index]
            
            let colorComponent:ReaderColorComponent = ReaderColorComponent(backgroundColor: UIColor.Image(color.0), textColor: UIColor.RGB(color.1), headerFooterColor: UIColor.RGB(color.2))
            
            return colorComponent
        }
    }
}

extension UIColor{
    class func RGB(rgb:(CGFloat,CGFloat,CGFloat)) ->UIColor{
        return UIColor(red: rgb.0/255, green: rgb.1/255, blue: rgb.2/255, alpha: 1.0)
    }
    
    class func Image(pattern:String) ->UIColor{
        return UIColor(patternImage: UIImage(named: pattern)!)
    }
}

extension WWMemory{
    func renderTheme(){
        NSNotificationCenter.defaultCenter().postNotificationName(kChangeTextColorNotification, object: nil)
        switch theme! {
        case .pure_1,.pure_2,.pure_3,.pure_4,.pure_5,.pure_6,.pure_7,.pure_8,.pure_9,.pure_10,.pure_11,.pure_12:
            drawPureBg()
        case .complex_1,.complex_2,.complex_3,.complex_4,.complex_5:
            drawComplexBg()
        default:
            drawDefaultBg()
        }
    }
    
    func drawPureBg() ->Void{
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let color = self.theme!.colorComponent().backgroundColor
            let rect = UIScreen.mainScreen().bounds
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
            let ctx = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(ctx, color.CGColor)
            CGContextFillRect(ctx, rect)
            self.bgImage = UIGraphicsGetImageFromCurrentImageContext()
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(kChangeBGLayerNotificaton, object: nil)
            })
            UIGraphicsEndImageContext()
        }
    }
    
    func drawComplexBg() ->Void{
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let index = ReaderTheme.complexThemeArray.indexOf(self.theme!)!
            let imName = ReaderTheme.complexColorScheme[index].0
            let im = UIImage(named: imName)!
            let rect = UIScreen.mainScreen().bounds
            let imRect = CGRectMake(0, 0, im.size.width, im.size.height)
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
            let ctx = UIGraphicsGetCurrentContext()
            CGContextDrawTiledImage(ctx, imRect, im.CGImage)
            self.bgImage = UIGraphicsGetImageFromCurrentImageContext()
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(kChangeBGLayerNotificaton, object: nil)
            })
            UIGraphicsEndImageContext()
        }
    }
    
    func drawDefaultBg() ->Void{
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let rect = UIScreen.mainScreen().bounds
            let border = UIImage(named: "border")!
            let p1 = UIImage(named: "parchment1")!
            let p2 = UIImage(named: "parchment2")!
            let p3 = UIImage(named: "parchment3")!
            
            let imageHeight = p1.size.height
            let imageWidth = p1.size.width
            
            let images:[UIImage] = [p1,p2,p3]
            
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
            let ctx = UIGraphicsGetCurrentContext()
            
            var j:Int = 0
            var jHeight:CGFloat = 0
            while jHeight<rect.size.height {
                var i:Int = 0
                var iWidth:CGFloat = 0
                while iWidth<rect.size.width {
                    let randomIndex = Int(arc4random()%3)
                    let tempRect = CGRectMake(CGFloat(i)*imageWidth, CGFloat(j)*imageHeight, imageWidth, imageHeight)
                    CGContextDrawImage(ctx, tempRect, images[randomIndex].CGImage)
                    i += 1
                    iWidth += imageWidth
                }
                j += 1
                jHeight += imageHeight
            }
            CGContextDrawImage(ctx, rect, border.CGImage)
            self.bgImage = UIGraphicsGetImageFromCurrentImageContext()
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(kChangeBGLayerNotificaton, object: nil)
            })
            UIGraphicsEndImageContext()
        }
    }
}

