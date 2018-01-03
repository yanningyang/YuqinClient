//
//  PersonalInfoViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/22.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire

class PersonalInfoViewController: UIViewController {

    @IBOutlet weak var rightBarBtn: UIBarButtonItem!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var organizationTextField: UITextField!
    @IBOutlet weak var validationCodeTextField: UITextField!
    @IBOutlet weak var getValidationCodeBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    var newGender = "male"
    
    var timer: NSTimer?
    var count = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITools.sharedInstance.addBorderTo(logoutBtn, color: nil)
        logoutBtn.setBackgroundImage(UIImage.init(named: "BtnNormal"), forState: .Highlighted)
        maleBtn.tintColor = UITools.sharedInstance.getDefaultColor()
        
        //注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setCustomerInfo), name: Constant.DidGetCustomerInfoNofification, object: nil)
        
        Tools.sharedInstance.getCustomerInfoFromNet()
//        setCustomerInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func rightBarBtnAction(sender: UIBarButtonItem) {
        updateCustomerInfo()
    }
    
    @IBAction func getValidationBtnAction(sender: UIButton) {
        getSMSCode()
    }
    
    @IBAction func genderBtnAction(sender: UIButton) {
        selecteGender(sender)
        newGender = sender.tag == 1 ? "male" : "female"
    }
    
    @IBAction func logoutBtnAction(sender: UIButton) {
        let alertController = UIAlertController(title: "确定退出？", message: "", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "取消", style: .Default, handler: nil)
        let ok = UIAlertAction(title: "确定", style: .Default) { alertAction in
            Tools.sharedInstance.logout(self.storyboard!, withToast: false)
        }
        alertController.addAction(cancel)
        alertController.addAction(ok)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func selecteGender(button: UIButton) {
        
        button.setTitleColor(UITools.sharedInstance.getDefaultColor(), forState: .Normal)
        
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let color1 = CGColorCreate(colorSpaceRef, [34.0/255.0, 189.0/255.0, 246.0/255.0, 1])
        let color2 = CGColorCreate(colorSpaceRef, [51.0/255.0, 51.0/255.0, 51.0/255.0, 1])
        UITools.sharedInstance.addBorderTo(button, color: color1)
        
        if button == maleBtn {
            UITools.sharedInstance.addBorderTo(femaleBtn, color: color2)
            femaleBtn.setTitleColor(UITools.sharedInstance.getDefaultTextColor(), forState: .Normal)
        } else {
            UITools.sharedInstance.addBorderTo(maleBtn, color: color2)
            maleBtn.setTitleColor(UITools.sharedInstance.getDefaultTextColor(), forState: .Normal)
        }
    }
    
    func setCustomerInfo() {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let name = userDefault.stringForKey(Constant.KeyForCustomerName) {
            nameTextField.text = name
        }
        if var phoneNumber = userDefault.stringForKey(Constant.KeyForPhoneNumber) {
            if !phoneNumber.isEmpty && phoneNumber.characters.count == 11 {
                phoneNumber = phoneNumber.stringByReplacingCharactersInRange(Range(phoneNumber.startIndex.advancedBy(3)..<phoneNumber.startIndex.advancedBy(7)), withString: "****")
            }
            phoneNumLabel.text = phoneNumber
        }
        if let organization = userDefault.stringForKey(Constant.KeyForCustomerOrganizationName) {
            organizationTextField.text = organization
        }
        if let gender = userDefault.stringForKey(Constant.KeyForCustomerGender) {
            if gender == "男" {
                selecteGender(maleBtn)
            } else {
                selecteGender(femaleBtn)
            }
        }
    }
    
    func getSMSCode() {
        
        let userInfo = Util.sharedInstance.getUserInfo()
        guard let phoneNumber = userInfo.0, validationCode = userInfo.1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            print("从本地获取登录信息失败!")
            return
        }
        URLConnector.request(Router.getSMSCode(phoneNumber: phoneNumber), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    self.getValidationCodeBtn.enabled = false
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setBool(false, forKey: "isLogin")
                    userDefaults.synchronize()
                } else {
                    UITools.sharedInstance.toast("获取验证码失败，请重新获取")
                }
            }
        })
    }
    
    //倒计时
    func counter() {
        if count == 0 {
            count = 60
            timer?.invalidate()
            getValidationCodeBtn.enabled = true
            getValidationCodeBtn.setTitle("获取验证码", forState: UIControlState.Normal)
        } else {
            
            getValidationCodeBtn.titleLabel?.text = "\(count)秒"
            getValidationCodeBtn.setTitle("\(count)秒", forState: UIControlState.Normal)
            count -= 1
        }
    }
    
    func updateCustomerInfo() {
        
        let newCustomerName = nameTextField.text
        let newCustomerOrganizationName = organizationTextField.text
        let validationCode = validationCodeTextField.text
        if newCustomerName == nil || newCustomerName!.isEmpty {
            UITools.sharedInstance.toast("请输入姓名")
            
            UITools.sharedInstance.shakeView(nameTextField)
            return
        }
        if newCustomerOrganizationName == nil || newCustomerOrganizationName!.isEmpty {
            UITools.sharedInstance.toast("请输入单位名称")
            
            UITools.sharedInstance.shakeView(organizationTextField)
            return
        }
        if validationCode == nil || validationCode!.isEmpty {
            UITools.sharedInstance.toast("请输入验证码")
            
            UITools.sharedInstance.shakeView(validationCodeTextField)
            return
        }
        
        let parameters: [String : String] = ["validationCode" : validationCode!.md5,
                          "newCustomerName" : newCustomerName!,
                          "newCustomerOrganizationName" : newCustomerOrganizationName!,
                          "newGender" : newGender]
        URLConnector.request(Router.updateCustomerInfo(params: parameters), successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(validationCode!.md5, forKey: Constant.KeyForValidationCode)
                    userDefaults.synchronize()
                    
                    Tools.sharedInstance.getCustomerInfoFromNet()
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    UITools.sharedInstance.toast("更新用户信息失败，请重试")
                }
            }
        })
    }
}
