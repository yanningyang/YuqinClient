//
//  LoginViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/15.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var validationCodeTextField: UITextField!
    @IBOutlet weak var getSMSCodeBtn: UIButton!
    
    var timer: NSTimer?
    var count = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapBackgroundView(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func onTapBackgroundView(sender: UITapGestureRecognizer) {
        phoneNumberTextField.resignFirstResponder()
        validationCodeTextField.resignFirstResponder()
    }
    
    @IBAction func getSMSCodeBtnAction(sender: AnyObject) {
        getSMSCode()
    }
    
    @IBAction func loginBtnAction(sender: UIButton) {
        login()
    }
    
    func getSMSCode() {
        
        let phoneNumber = phoneNumberTextField.text
        if phoneNumber == nil || phoneNumber!.isEmpty {
            UITools.sharedInstance.toast("请输入手机号码")
            
            UITools.sharedInstance.shakeView(phoneNumberTextField)
            return
        }
        if phoneNumber!.characters.count != 11 {
            UITools.sharedInstance.toast("手机号码应为11位数字")
            return
        }
        
        URLConnector.request(Router.getSMSCode(phoneNumber: phoneNumber!), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    self.getSMSCodeBtn.enabled = false
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
                } else {
                    UITools.sharedInstance.toast("获取验证码失败，请重试。。。")
                }
            }
        })
    }
    
    //倒计时
    func counter() {
        if count == 0 {
            count = 60
            timer?.invalidate()
            getSMSCodeBtn.enabled = true
            getSMSCodeBtn.setTitle("获取验证码", forState: UIControlState.Normal)
        } else {
            
            getSMSCodeBtn.titleLabel?.text = "\(count)秒"
            getSMSCodeBtn.setTitle("\(count)秒", forState: UIControlState.Normal)
            count -= 1
        }
    }
    
    func login() {
        
        let phoneNumber = phoneNumberTextField.text
        let validationCode = validationCodeTextField.text
        if phoneNumber == nil || phoneNumber!.isEmpty {
            UITools.sharedInstance.toast("请输入手机号码")
            
            UITools.sharedInstance.shakeView(phoneNumberTextField)
            return
        }
        if phoneNumber!.characters.count != 11 {
            UITools.sharedInstance.toast("手机号码应为11位数字")
            return
        }
        if validationCode == nil || validationCode!.isEmpty {
            UITools.sharedInstance.toast("请输入验证码")
            
            UITools.sharedInstance.shakeView(validationCodeTextField)
            return
        }
        
        URLConnector.request(Router.login(phoneNumber: phoneNumber!, validationCode: validationCode!.md5!), showLoadingAnimation: true, successCallBack: { value in
                if let status = value["status"].bool {
                    if status {
                        
                        print("登录成功")
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setObject(phoneNumber, forKey: "phoneNumber")
                        userDefaults.setObject(validationCode!.md5, forKey: "validationCode")
                        userDefaults.setBool(true, forKey: "isLogin")
                        userDefaults.synchronize()
                        
                        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                        let window = UIApplication.sharedApplication().keyWindow
                        window?.rootViewController = homeVC
                        
                        //上传token
                        //Tools.sharedInstance.updateDeviceToken()
                    } else {
                        UITools.sharedInstance.toast("用户名或密码错误")
                    }
                }
        })
    }

}
