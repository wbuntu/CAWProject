//
//  CAWUtility.swift
//  CAWReader
//
//  Created by wbuntu on 4/3/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit
import CryptoSwift
//let CAWApiAddress:String = "http://127.0.0.1:5000"
//let CAWResourceAddress:String = "http://127.0.0.1:8888"
let CAWApiAddress:String = "http://192.168.2.1:5000"
let CAWResourceAddress:String = "http://192.168.2.1:8888"
let screenWidth:CGFloat  = UIScreen.mainScreen().bounds.width
let screenHeight:CGFloat = UIScreen.mainScreen().bounds.height
let tabBarHeight:CGFloat = 49.0
let naviBarHeight:CGFloat = 64.0
let collectionViewHeight = screenHeight - tabBarHeight - naviBarHeight
let showLibraryNofification = "kShowLibraryNofification"
let commonTintColor:UIColor = UIColor(red: 41/255.0, green: 128/255.0, blue: 185/255.0, alpha: 1.0)
let commonBackgroundColor:UIColor = UIColor(white: 0.95, alpha: 1.0)
let libraryItemWidth:CGFloat = (UIScreen.mainScreen().bounds.width-10*4)/3
let libraryItemCoverHeiht:CGFloat = libraryItemWidth*1.5
let libraryItemHeight:CGFloat = libraryItemCoverHeiht+4+2+14+4
let commonPlaceHolder:UIImage = UIImage(named:"default")!
let kLoginAgainNotification:String = "kLoginAgainNotification"
let kModifyShelfNotification:String = "kModifyShelfNotification"
let kModifyCollectListNotification:String = "kModifyCollectListNotification"
let kChangeTextColorNotification:String = "kChangeTextColorNotification"
let kChangeBGLayerNotificaton:String = "kChangeBGLayerNotificaton"
//class CAWUtility: NSObject {
//
//}
extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let divisor = CGFloat(255)
        let red     = CGFloat((hex & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(red: UInt, green: UInt, blue: UInt, a: CGFloat = 1) {
        
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0,
                  blue: CGFloat(blue)/255.0, alpha: a)
    }
}

func encodeString(input:String) ->String{
    let resultStr = try! input.encrypt(AES(key: "dXi5OjprsnyjU2ZJ", iv:"bmaZYHZuuNjeC0OH")).toBase64()!
    return resultStr
}

func encodeDictionary(dic:Dictionary<String,String>) ->String{
    let data = try! NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
    let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
    let resultStr = try! str.encrypt(AES(key: "dXi5OjprsnyjU2ZJ", iv:"bmaZYHZuuNjeC0OH")).toBase64()!
    return resultStr
}

func decodeData(input:NSData) ->NSData{
    let data = input
    let deBase64Data = NSData(base64EncodedData: data, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
    let resultData = try! deBase64Data?.decrypt(AES(key: "dXi5OjprsnyjU2ZJ", iv:"bmaZYHZuuNjeC0OH"))
    return resultData!
}


