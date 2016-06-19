//
//  WWMemory.swift
//  CAWReader
//
//  Created by wbuntu on 16/5/6.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit

class WWMemory: NSObject, NSCoding {
    var userId:String?
    var userName:String?
    var userEmail:String?
    var userPasswd:String?
    var isLogin:Bool!
    var userShelf:[bookModel]?
    var bookmarks:[String:String]?
    var theme:ReaderTheme?
    var fontSize:Int?
    var firstHeadIndent:Int?
    var lineSpacing:Int?
    var paragraphSpacing:Int?
    var bgImage:UIImage!
    static let filePath:String = {
        let doc = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let path = doc+"/data"
        return path
    }()
    static let shared:WWMemory = {
        let manager = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(WWMemory.filePath){
            let temp = NSKeyedUnarchiver.unarchiveObjectWithFile(WWMemory.filePath) as! WWMemory
            temp.renderTheme()
            return temp
        }else{
            let temp = WWMemory()
            temp.renderTheme()
            return temp
        }
    }()
    
    func save() -> Void{
        NSKeyedArchiver.archiveRootObject(self, toFile: WWMemory.filePath)
    }
    
    func reset() -> Void{
        userId = nil
        userName = nil
        userEmail = nil
        userPasswd = nil
        isLogin = false
        userShelf = [bookModel]()
        bookmarks = [String:String]()
        theme = ReaderTheme.complex_default
        fontSize = 16
        firstHeadIndent = 1
        lineSpacing = 0
        paragraphSpacing = 0
        renderTheme()
        let manager = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(WWMemory.filePath){
            
            do{
                try manager.removeItemAtPath(WWMemory.filePath)
            }catch(let error){
                print(error)
            }
        }
    }
    
    
    override init() {
        super.init()
        userShelf = [bookModel]()
        bookmarks = [String:String]()
        isLogin = false
        theme = ReaderTheme.complex_default
        fontSize = 16
        firstHeadIndent = 1
        lineSpacing = 0
        paragraphSpacing = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        userId = aDecoder.decodeObjectForKey("userId") as? String
        userName = aDecoder.decodeObjectForKey("userName") as? String
        userEmail = aDecoder.decodeObjectForKey("userEmail") as? String
        userPasswd = aDecoder.decodeObjectForKey("userPasswd") as? String
        userShelf = aDecoder.decodeObjectForKey("userShelf") as? [bookModel]
        isLogin = aDecoder.decodeBoolForKey("isLogin")
        bookmarks = aDecoder.decodeObjectForKey("bookmarks") as? [String:String]
        theme = ReaderTheme(rawValue: aDecoder.decodeIntegerForKey("theme"))
        fontSize = aDecoder.decodeIntegerForKey("fontSize")
        firstHeadIndent = aDecoder.decodeIntegerForKey("firstHeadIndent")
        lineSpacing = aDecoder.decodeIntegerForKey("lineSpacing")
        paragraphSpacing = aDecoder.decodeIntegerForKey("paragraphSpacing")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(userId, forKey: "userId")
        aCoder.encodeObject(userName, forKey: "userName")
        aCoder.encodeObject(userEmail, forKey: "userEmail")
        aCoder.encodeObject(userPasswd, forKey: "userPasswd")
        aCoder.encodeObject(userShelf, forKey: "userShelf")
        aCoder.encodeBool(isLogin, forKey: "isLogin")
        aCoder.encodeObject(bookmarks, forKey: "bookmarks")
        aCoder.encodeInteger(theme!.rawValue, forKey: "theme")
        aCoder.encodeInteger(fontSize!, forKey: "fontSize")
        aCoder.encodeInteger(firstHeadIndent!, forKey: "firstHeadIndent")
        aCoder.encodeInteger(lineSpacing!, forKey: "lineSpacing")
        aCoder.encodeInteger(paragraphSpacing!, forKey: "paragraphSpacing")
    }
}
