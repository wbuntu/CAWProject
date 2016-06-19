//
//  PerfectHandlers.swift
//  URL Routing
//
//  Created by Kyle Jessup on 2015-12-15.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import MySQL
import Foundation
import CryptoSwift
// This is the function which all Perfect Server modules must expose.
// The system will load the module and call this function.
// In here, register any handlers or perform any one-time tasks.
let HOST = "127.0.0.1"
let USER = "test"
let PASSWORD = "1234567"
let SCHEMA = "test"

public func PerfectServerModuleInit() {
	
	// Install the built-in routing handler.
	// Using this system is optional and you could install your own system if desired.
    
	Routing.Handler.registerGlobally()
	
    Routing.Routes["GET","/index"] = {_ in return wIndex()}
    Routing.Routes["GET","/discover"] = {_ in return wDiscover()}
    Routing.Routes["GET","/search"] = {_ in return wSearch()}
    Routing.Routes["GET","/sort"] = {_ in return wSort()}
    Routing.Routes["GET","/sectionSort"] = {_ in return wSectionSort()}
    Routing.Routes["GET","/login"] = {_ in return wLogin()}
    Routing.Routes["GET","/collect"] = {_ in return wCollect()}
}
//done
class wIndex: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        let resultDic = fetchLiabraryIndex()
        let str = try! resultDic.jsonEncodedString()
        let resultStr = encodeString(str)
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}
//done return encoded
class wDiscover: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        let start:Int = Int(arc4random()%26300)
        let resp:Dictionary<String,Any> = fetchList(start)
        let str = try! resp.jsonEncodedString()
        let resultStr = encodeString(str)
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}
//done receive encoded return encoded
class wSearch: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        let dic = decodeString(request.param("req")!)
        let type:Int = Int(dic["type"]!)!
        let keyword:String = dic["keyword"]!
        let resp:Dictionary<String,Any> = searchWithParam(type, keyword: keyword)
        let str = try! resp.jsonEncodedString()
        let resultStr = encodeString(str)
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}
//done receive encoded return encoded
class wSort: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        let dic = decodeString(request.param("req")!)
        let sort:String = dic["sort"]!
        let location:Int = Int(dic["location"]!)!
        let resp:Dictionary<String,Any> = fetchListWithSort(location, sort: sort)
        let str = try! resp.jsonEncodedString()
        let resultStr = encodeString(str)
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}

//done receive encoded return encoded
class wSectionSort: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        let dic = decodeString(request.param("req")!)
        let location:Int = Int(dic["location"]!)!
        let resp:Dictionary<String,Any> = fetchList(location)
        let str = try! resp.jsonEncodedString()
        let resultStr = encodeString(str)
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}
//done
class wLogin: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        let dic = decodeString(request.param("req")!)
        let userEmail:String = dic["userEmail"]!
        let userPasswd:String = dic["userPasswd"]!
        
        var resp:Dictionary<String,Any> = Dictionary<String,Any>()
        resp["msg"] = "ok"
        resp["code"] = "200"
        if let userDic = fetchUser(userEmail, userPasswd: userPasswd){
            var tempDic = Dictionary<String,Any>()
            tempDic["loginSuccess"] = "YES"
            tempDic["userId"] = userDic["userId"]
            tempDic["userName"] = userDic["userName"]
            tempDic["userEmail"] = userDic["userEmail"]
            tempDic["userPasswd"] = userDic["userPasswd"]
            tempDic["userShelf"] = fetchShelfList(userDic["userShelf"]!)
            resp["data"] = tempDic
        }else{
            var tempDic = Dictionary<String,Any>()
            tempDic["loginSuccess"] = "NO"
            tempDic["userId"] = ""
            tempDic["userName"] = ""
            tempDic["userEmail"] = ""
            tempDic["userPasswd"] = ""
            tempDic["userShelf"] = [Dictionary<String, String>]()
            resp["data"] = tempDic
        }
        let str = try! resp.jsonEncodedString()
        let resultStr = encodeString(str)
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}
class wCollect: RequestHandler {
    func handleRequest(request: WebRequest, response: WebResponse) {
        let dic = decodeString(request.param("req")!)
        let method:String = dic["method"]!
        let userId:String = dic["userId"]!
        let bookId:String = dic["bookId"]!
        var resp:Dictionary<String,Any>!
        if method == "add"{
            resp = addBook(userId, bookId: bookId)
        }else{
            resp = removeBook(userId, bookId: bookId)
        }
        let str = try! resp.jsonEncodedString()
        let resultStr = encodeString(str)
        response.appendBodyString(resultStr)
        response.requestCompletedCallback()
    }
}

func fetchList(start:Int) -> Dictionary<String,Any> {
    let mysql = MySQL()
    mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8mb4")
    mysql.setOption(.MYSQL_OPT_RECONNECT, true)
    mysql.setOption(.MYSQL_OPT_LOCAL_INFILE)
    mysql.setOption(.MYSQL_OPT_CONNECT_TIMEOUT, 5)
    mysql.connect(HOST, user: USER, password: PASSWORD)
    mysql.selectDatabase(SCHEMA)
    let queryStr = "SELECT * FROM book WHERE bookid >=\(start) and bookid< \(start+10)"
    mysql.query(queryStr)
    
    let results = mysql.storeResults()!
    var dicArray: [Dictionary<String, String>] = []
    while let row = results.next() {
        var dic:Dictionary<String,String> = Dictionary()
        dic["bookid"]=row[0]
        dic["sfid"]=row[1]
        dic["title"]=row[2]
        dic["rating"]=row[3]
        dic["sort"]=row[4]
        dic["status"]=row[5]
        dic["author"]=row[6]
        dic["wordcount"]=row[7]
        dic["clickcount"]=row[8]
        dic["updatetime"]=row[9]
        dic["intro"]=row[10]
        dic["tags"]=row[11]
        dic["cover"]=row[12]
        dicArray.append(dic)
    }
    
    mysql.close()   
    var resp = Dictionary<String,Any>()
    resp["msg"] = "ok"
    resp["code"] = "200"
    resp["data"] = dicArray
    return resp
}
// without adding code and msg

func fetchLiabraryIndex() ->Dictionary<String,Any>{
    let locations:[(String,UInt32)] = [("hot",6000),("recommend",12000),("complete",18000)]
    var resultDic:Dictionary<String,[Dictionary<String, String>]> = Dictionary<String,[Dictionary<String, String>]>()
    for (key,base) in locations{
        let start:Int = Int(arc4random()%base+1)
        let resp:[Dictionary<String, String>] = fetchPureList(start)
        resultDic[key] = resp
    }
    var resp = Dictionary<String,Any>()
    resp["msg"] = "ok"
    resp["code"] = "200"
    resp["data"] = resultDic
    return resp
}

func fetchPureList(start:Int) -> [Dictionary<String, String>] {
    let mysql = MySQL()
    mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8mb4")
    mysql.setOption(.MYSQL_OPT_RECONNECT, true)
    mysql.setOption(.MYSQL_OPT_LOCAL_INFILE)
    mysql.setOption(.MYSQL_OPT_CONNECT_TIMEOUT, 5)
    mysql.connect(HOST, user: USER, password: PASSWORD)
    mysql.selectDatabase(SCHEMA)
    let queryStr = "SELECT * FROM book WHERE bookid >=\(start) and bookid< \(start+9)"
    mysql.query(queryStr)
    
    let results = mysql.storeResults()!
    var dicArray: [Dictionary<String, String>] = []
    while let row = results.next() {
        var dic:Dictionary<String,String> = Dictionary()
        dic["bookid"]=row[0]
        dic["sfid"]=row[1]
        dic["title"]=row[2]
        dic["rating"]=row[3]
        dic["sort"]=row[4]
        dic["status"]=row[5]
        dic["author"]=row[6]
        dic["wordcount"]=row[7]
        dic["clickcount"]=row[8]
        dic["updatetime"]=row[9]
        dic["intro"]=row[10]
        dic["tags"]=row[11]
        dic["cover"]=row[12]
        dicArray.append(dic)
    }
    
    mysql.close()
    return dicArray
}

func searchWithParam(type:Int, keyword:String) -> Dictionary<String,Any>{
    let mysql = MySQL()
    mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8mb4")
    mysql.setOption(.MYSQL_OPT_RECONNECT, true)
    mysql.setOption(.MYSQL_OPT_LOCAL_INFILE)
    mysql.setOption(.MYSQL_OPT_CONNECT_TIMEOUT, 5)
    mysql.connect(HOST, user: USER, password: PASSWORD)
    mysql.selectDatabase(SCHEMA)
    let queryStr:NSString
    
    if type == 0 {
        queryStr = NSString(format: "SELECT * FROM book WHERE title like '%@%%'", keyword)
    }else{
        queryStr = NSString(format: "SELECT * FROM book WHERE author like '%@%%'", keyword)
    }
    
    mysql.query(queryStr as String)
    
    let results = mysql.storeResults()!
    var dicArray: [Dictionary<String, String>] = []
    while let row = results.next() {
        var dic:Dictionary<String,String> = Dictionary()
        dic["bookid"]=row[0]
        dic["sfid"]=row[1]
        dic["title"]=row[2]
        dic["rating"]=row[3]
        dic["sort"]=row[4]
        dic["status"]=row[5]
        dic["author"]=row[6]
        dic["wordcount"]=row[7]
        dic["clickcount"]=row[8]
        dic["updatetime"]=row[9]
        dic["intro"]=row[10]
        dic["tags"]=row[11]
        dic["cover"]=row[12]
        dicArray.append(dic)
    }
    
    mysql.close()
    var resp = Dictionary<String,Any>()
    resp["msg"] = "ok"
    resp["code"] = "200"
    resp["data"] = dicArray
    return resp
}

func fetchListWithSort(start:Int, sort:String) -> Dictionary<String,Any>{
    let mysql = MySQL()
    mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8mb4")
    mysql.setOption(.MYSQL_OPT_RECONNECT, true)
    mysql.setOption(.MYSQL_OPT_LOCAL_INFILE)
    mysql.setOption(.MYSQL_OPT_CONNECT_TIMEOUT, 5)
    mysql.connect(HOST, user: USER, password: PASSWORD)
    mysql.selectDatabase(SCHEMA)
    
    let queryStr:NSString = NSString(format: "SELECT * FROM book WHERE sort='%@' ORDER BY bookid LIMIT %d,10", sort,start)
    
    mysql.query(queryStr as String)
    
    let results = mysql.storeResults()!
    var dicArray: [Dictionary<String, String>] = []
    while let row = results.next() {
        var dic:Dictionary<String,String> = Dictionary()
        dic["bookid"]=row[0]
        dic["sfid"]=row[1]
        dic["title"]=row[2]
        dic["rating"]=row[3]
        dic["sort"]=row[4]
        dic["status"]=row[5]
        dic["author"]=row[6]
        dic["wordcount"]=row[7]
        dic["clickcount"]=row[8]
        dic["updatetime"]=row[9]
        dic["intro"]=row[10]
        dic["tags"]=row[11]
        dic["cover"]=row[12]
        dicArray.append(dic)
    }
    
    mysql.close()
    var resp = Dictionary<String,Any>()
    resp["msg"] = "ok"
    resp["code"] = "200"
    resp["data"] = dicArray
    return resp
}

func fetchUser(userEmail:String,userPasswd:String) ->Dictionary<String,String>?{
    let mysql = MySQL()
    mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8mb4")
    mysql.setOption(.MYSQL_OPT_RECONNECT, true)
    mysql.setOption(.MYSQL_OPT_LOCAL_INFILE)
    mysql.setOption(.MYSQL_OPT_CONNECT_TIMEOUT, 5)
    mysql.connect(HOST, user: USER, password: PASSWORD)
    mysql.selectDatabase(SCHEMA)
    let queryStr:String = NSString(format: "SELECT * FROM user WHERE userEmail='%@' and userPasswd='%@'", userEmail,userPasswd) as String
    
    mysql.query(queryStr)
    var resultDic:Dictionary<String,String>?
    if let results = mysql.storeResults(){
        if let row = results.next(){
            resultDic = Dictionary<String,String>()
            resultDic!["userId"] = row[0]
            resultDic!["userName"] = row[1]
            resultDic!["userEmail"] = row[2]
            resultDic!["userPasswd"] = row[3]
            resultDic!["userShelf"] = row[4]
        }
    }
    mysql.close()
    return resultDic
}

func fetchShelfList(shelf:String) ->[Dictionary<String, String>]{
    let mysql = MySQL()
    mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8mb4")
    mysql.setOption(.MYSQL_OPT_RECONNECT, true)
    mysql.setOption(.MYSQL_OPT_LOCAL_INFILE)
    mysql.setOption(.MYSQL_OPT_CONNECT_TIMEOUT, 5)
    mysql.connect(HOST, user: USER, password: PASSWORD)
    mysql.selectDatabase(SCHEMA)
    
    let queryStr:NSString = NSString(format: "SELECT * FROM book WHERE bookid in (%@)", shelf)
    
    mysql.query(queryStr as String)
    
    let results = mysql.storeResults()!
    var dicArray: [Dictionary<String, String>] = []
    while let row = results.next() {
        var dic:Dictionary<String,String> = Dictionary()
        dic["bookid"]=row[0]
        dic["sfid"]=row[1]
        dic["title"]=row[2]
        dic["rating"]=row[3]
        dic["sort"]=row[4]
        dic["status"]=row[5]
        dic["author"]=row[6]
        dic["wordcount"]=row[7]
        dic["clickcount"]=row[8]
        dic["updatetime"]=row[9]
        dic["intro"]=row[10]
        dic["tags"]=row[11]
        dic["cover"]=row[12]
        dicArray.append(dic)
    }
    
    mysql.close()
    return dicArray
}

func addBook(userId:String, bookId:String) ->Dictionary<String,Any>{
    let mysql = MySQL()
    mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8mb4")
    mysql.setOption(.MYSQL_OPT_RECONNECT, true)
    mysql.setOption(.MYSQL_OPT_LOCAL_INFILE)
    mysql.setOption(.MYSQL_OPT_CONNECT_TIMEOUT, 5)
    mysql.connect(HOST, user: USER, password: PASSWORD)
    mysql.selectDatabase(SCHEMA)
    
    let queryStr:NSString = NSString(format: "SELECT userShelf FROM user WHERE userId='%@'", userId)
    mysql.query(queryStr as String)
    let results = mysql.storeResults()!
    let row = results.next()
    let userShelf:String = row![0]
    let newUserShelf = userShelf+","+bookId
    let updateString:NSString = NSString(format: "UPDATE user SET userShelf='%@' WHERE userId='%@'", newUserShelf,userId)
    var resp = Dictionary<String,Any>()
    resp["msg"] = "ok"
    resp["code"] = "200"

    if mysql.query(updateString as String){
        resp["data"] = "YES"
    }else{
        resp["data"] = "NO"
    }
    mysql.close()
    return resp
}

func removeBook(userId:String, bookId:String) ->Dictionary<String,Any>{
    let mysql = MySQL()
    mysql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8mb4")
    mysql.setOption(.MYSQL_OPT_RECONNECT, true)
    mysql.setOption(.MYSQL_OPT_LOCAL_INFILE)
    mysql.setOption(.MYSQL_OPT_CONNECT_TIMEOUT, 5)
    mysql.connect(HOST, user: USER, password: PASSWORD)
    mysql.selectDatabase(SCHEMA)
    
    let queryStr:NSString = NSString(format: "SELECT userShelf FROM user WHERE userId='%@'", userId)
    mysql.query(queryStr as String)
    let results = mysql.storeResults()!
    let row = results.next()
    let userShelf:String = row![0]
    var books:[String] = userShelf.componentsSeparatedByString(",")
    if let index = books.indexOf(bookId){
        books.removeAtIndex(index)
    }
    let newUserShelf = books.joinWithSeparator(",")
    let updateString:NSString = NSString(format: "UPDATE user SET userShelf='%@' WHERE userId='%@'", newUserShelf,userId)
    
    var resp = Dictionary<String,Any>()
    resp["msg"] = "ok"
    resp["code"] = "200"
    
    if mysql.query(updateString as String){
        resp["data"] = "YES"
    }else{
        resp["data"] = "NO"
    }
    mysql.close()
    return resp
}

func encodeString(input:String) ->String{
    let resultStr = try! input.encrypt(AES(key: "dXi5OjprsnyjU2ZJ", iv:"bmaZYHZuuNjeC0OH")).toBase64()!
    return resultStr
}

func decodeString(input:String) ->Dictionary<String,String>{
    let data = input.dataUsingEncoding(NSUTF8StringEncoding)
    let deBase64Data = NSData(base64EncodedData: data!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
    let resultData = try! deBase64Data?.decrypt(AES(key: "dXi5OjprsnyjU2ZJ", iv:"bmaZYHZuuNjeC0OH"))
    let resultDic = try! NSJSONSerialization.JSONObjectWithData(resultData!, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String,String>
    return resultDic
}

