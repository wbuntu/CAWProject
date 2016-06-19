//
//  LoginController.swift
//  CAWReader
//
//  Created by wbuntu on 16/5/5.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

import UIKit
import WSProgressHUD
import Alamofire
class LoginController: UIViewController {
    
    weak var tabController:TabController?
    
    lazy var hud: WSProgressHUD = {
        let tempHud:WSProgressHUD = WSProgressHUD(view: self.view)
        self.view.addSubview(tempHud)
        return tempHud
    }()
    
    let visualEffectView:UIVisualEffectView = {
        let view = UIVisualEffectView(frame: UIScreen.mainScreen().bounds)
        view.effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        return view
    }()
    let scrollView:UIScrollView = UIScrollView(frame:UIScreen.mainScreen().bounds)
    
    //    let nameFiled:UITextField = {
    //        let tempField = UITextField()
    //        tempField.tintColor = UIColor.whiteColor()
    //        tempField.font = UIFont.systemFontOfSize(17)
    //        tempField.backgroundColor = UIColor.clearColor()
    //        tempField.textColor = UIColor.whiteColor()
    //        tempField.attributedPlaceholder = NSAttributedString(string: "请输入昵称", attributes: [NSForegroundColorAttributeName:UIColor(white: 0.8, alpha: 0.7)])
    //        return tempField
    //    }()
    
    let mailFiled:UITextField = {
        let tempField = UITextField()
        tempField.tintColor = UIColor.whiteColor()
        tempField.font = UIFont.systemFontOfSize(17)
        tempField.backgroundColor = UIColor.clearColor()
        tempField.textColor = UIColor.whiteColor()
        tempField.attributedPlaceholder = NSAttributedString(string: "请输入邮箱", attributes: [NSForegroundColorAttributeName:UIColor(white: 0.8, alpha: 0.7)])
        return tempField
    }()
    
    let passwdFiled:UITextField = {
        let tempField = UITextField()
        tempField.tintColor = UIColor.whiteColor()
        tempField.secureTextEntry  = true
        tempField.font = UIFont.systemFontOfSize(17)
        tempField.backgroundColor = UIColor.clearColor()
        tempField.textColor = UIColor.whiteColor()
        tempField.attributedPlaceholder = NSAttributedString(string: "请输入密码", attributes: [NSForegroundColorAttributeName:UIColor(white: 0.8, alpha: 0.7)])
        return tempField
    }()
    
    
    let loginButton:UIButton = {
        let btn = UIButton(type:UIButtonType.System)
        btn.backgroundColor = UIColor.clearColor()
        btn.setTitle("登录", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.whiteColor().CGColor
        btn.layer.cornerRadius = 4.0
        return btn
    }()
    //    let registerButton:UIButton = {
    //        let btn = UIButton(type:UIButtonType.System)
    //        btn.backgroundColor = UIColor.clearColor()
    //        btn.setTitle("注册", forState: .Normal)
    //        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    //        btn.layer.borderWidth = 0.5
    //        btn.layer.borderColor = UIColor.whiteColor().CGColor
    //        btn.layer.cornerRadius = 4.0
    //        return btn
    //    }()
    let padding:CGFloat = 15
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = commonBackgroundColor
        let backgroundController = UIStoryboard(name: "Launch Screen", bundle: nil).instantiateViewControllerWithIdentifier("SpalshController")
        self.view.addSubview(backgroundController.view)
        self.view.addSubview(visualEffectView)
        visualEffectView.contentView.addSubview(scrollView)
        
        layoutViews()
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self
            , action: #selector(self.tapBackgroundToHideKeyboard))
        self.scrollView.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //        nameFiled.addTarget(self, action: #selector(textFiledDidChange(_:)), forControlEvents: .EditingChanged)
        mailFiled.addTarget(self, action: #selector(textFiledDidChange(_:)), forControlEvents: .EditingChanged)
        passwdFiled.addTarget(self, action: #selector(textFiledDidChange(_:)), forControlEvents: .EditingChanged)
        
        loginButton.addTarget(self, action: #selector(loginAccount), forControlEvents: .TouchUpInside)
        loginButton.enabled = false
        loginButton.alpha = 0.3
        
        //        registerButton.addTarget(self, action: #selector(registerAcccount), forControlEvents: .TouchUpInside)
        //        registerButton.enabled = false
        //        registerButton.alpha = 0.6
        WWMemory.shared.reset()
        
    }
    
    func tapBackgroundToHideKeyboard() -> Void{
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(info:NSNotification) -> Void{
        let rect:CGRect =  (info.userInfo?[UIKeyboardFrameEndUserInfoKey])!.CGRectValue
        
        if self.view.height - loginButton.bottom < (rect.size.height + 8) {
            let y = (rect.size.height + 8) - (self.view.height - self.loginButton.bottom)
            scrollView.setContentOffset(CGPointMake(0, y), animated: true)
        }
    }
    
    func keyboardWillHide(info:NSNotification) ->Void{
        if scrollView.contentOffsetY != 0 {
            scrollView.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    func textFiledDidChange(textFiled:UITextField) ->Void{
        
        if passwdFiled.text?.characters.count>0 && mailFiled.text?.characters.count > 0 /*&& nameFiled.text?.characters.count > 0*/{
            self.loginButton.enabled = true
            self.loginButton.alpha = 1.0
        }else{
            self.loginButton.enabled = false
            self.loginButton.alpha = 0.3
        }
    }
    
    //    func registerAcccount() -> Void{
    //
    //    }
    
    func loginAccount() -> Void{
        scrollView.endEditing(true)
        self.hud.show()
        self.view.userInteractionEnabled = false
        let email = mailFiled.text!
        let passwd = passwdFiled.text!
        let resultStr = encodeDictionary(["userEmail":email,"userPasswd":passwd])
        Alamofire.request(.GET, CAWApiAddress+"/login", parameters: ["req":resultStr], encoding: .URL, headers: nil).responseData {[weak self] response in
            if let strongSelf = self{
                strongSelf.view.userInteractionEnabled = true
                switch response.result {
                case .Success:
                    let data = decodeData(response.data!)
                    let resp:LoginResponse = try! LoginResponse(data: data)
                    let loginInfo:LoginData = resp.data
                    if loginInfo.loginSuccess{
                        strongSelf.hud.showImage(nil, status: "登录成功")
                        UIView.animateWithDuration(0.4, animations: { 
                            strongSelf.visualEffectView.alpha = 0
                            }, completion: { (finished) in
                                if finished{
                                    strongSelf.handleLoginResult(loginInfo)
                                }
                        })
                    }else{
                        strongSelf.hud.showImage(nil, status: "帐号不存在")
                    }
                case .Failure(let error):
                    let description = error.localizedDescription
                    strongSelf.hud.showErrorWithString(description)
                }
            }
        }
    }
    
    func handleLoginResult(data:LoginData) ->Void{
        WWMemory.shared.userId = data.userId
        WWMemory.shared.userName = data.userName
        WWMemory.shared.userEmail = data.userEmail
        WWMemory.shared.userPasswd = data.userPasswd
        WWMemory.shared.userShelf = data.userShelf as? [bookModel]
        WWMemory.shared.isLogin = true
        WWMemory.shared.save()
        if tabController != nil{
            NSNotificationCenter.defaultCenter().postNotificationName(kLoginAgainNotification, object: nil)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            let controller:TabController = TabController()
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func layoutViews() -> Void{
        
        //        let nameContainer = UIView()
        //        nameContainer.layer.borderColor = UIColor.whiteColor().CGColor
        //        nameContainer.layer.borderWidth = 0.5
        //        nameContainer.layer.cornerRadius = 4.0
        //        scrollView.addSubview(nameContainer)
        //        nameContainer.snp_makeConstraints { (make) in
        //            make.width.equalTo(self.view.width-padding*2)
        //            make.left.equalTo(padding)
        //            make.height.equalTo(48)
        //            make.top.equalTo(scrollView).offset(60)
        //        }
        //
        //        nameContainer.addSubview(nameFiled)
        //        nameFiled.snp_makeConstraints { (make) in
        //            make.left.equalTo(nameContainer).offset(padding)
        //            make.right.equalTo(nameContainer).offset(-padding)
        //            make.height.equalTo(40)
        //            make.centerY.equalTo(nameContainer)
        //        }
        
        let mailContainer = UIView()
        mailContainer.layer.borderColor = UIColor.whiteColor().CGColor
        mailContainer.layer.borderWidth = 0.5
        mailContainer.layer.cornerRadius = 4.0
        self.scrollView.addSubview(mailContainer)
        mailContainer.snp_makeConstraints { (make) in
            make.width.equalTo(self.view.width-padding*2)
            make.left.equalTo(padding)
            make.height.equalTo(48)
            make.centerY.equalTo(scrollView).offset(-70)
        }
        
        mailContainer.addSubview(mailFiled)
        mailFiled.snp_makeConstraints { (make) in
            make.left.equalTo(mailContainer).offset(padding)
            make.right.equalTo(mailContainer).offset(-padding)
            make.height.equalTo(40)
            make.centerY.equalTo(mailContainer)
        }
        
        let passwdContainer = UIView()
        passwdContainer.layer.borderColor = UIColor.whiteColor().CGColor
        passwdContainer.layer.borderWidth = 0.5
        passwdContainer.layer.cornerRadius = 4.0
        self.scrollView.addSubview(passwdContainer)
        passwdContainer.snp_makeConstraints { (make) in
            make.width.equalTo(self.view.width-padding*2)
            make.height.equalTo(48)
            make.left.equalTo(padding)
            make.top.equalTo(mailContainer.snp_bottom).offset(10)
        }
        
        passwdContainer.addSubview(passwdFiled)
        self.passwdFiled.snp_makeConstraints { (make) in
            make.left.equalTo(passwdContainer).offset(padding)
            make.right.equalTo(passwdContainer).offset(-padding)
            make.height.equalTo(40)
            make.centerY.equalTo(passwdContainer)
        }
        
        scrollView.addSubview(loginButton)
        loginButton.snp_makeConstraints { (make) in
            make.width.equalTo(self.view.width-padding*2)
            make.height.equalTo(48)
            make.left.equalTo(self.padding)
            make.top.equalTo(passwdContainer.snp_bottom).offset(20)
        }
        
        //        scrollView.addSubview(registerButton)
        //        registerButton.snp_makeConstraints { (make) in
        //            make.width.equalTo(self.view.width-padding*2)
        //            make.height.equalTo(48)
        //            make.left.equalTo(self.padding)
        //            make.top.equalTo(loginButton.snp_bottom).offset(20)
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
