//
//  Tools.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/17.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation
import Alamofire

public class Tools {
    
    static let sharedInstance = Tools()
    //私有化init方法，保证单例
    private init(){}
    
    //获取Baidu资源路径
    public func getBaiduMapBundlePath(filename: String) ->String? {
        var ret: String?
        let myBundlePath: String = (NSBundle.mainBundle().resourcePath?.stringByAppendingString("/" + Constant.MYBUNDLE_NAME))!
        let libBundle: NSBundle = NSBundle(path: myBundlePath)!
        if !filename.isEmpty {
            ret = (libBundle.resourcePath?.stringByAppendingString("/" + filename))!
        }
        return ret
    }
    
    //获取登录用户的帐号密码
    public func getUserInfo() ->(String?, String?)? {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let phoneNumber = userDefault.objectForKey("phoneNumber") as? String
        let validationCode = userDefault.objectForKey("validationCode") as? String
        return (phoneNumber, validationCode)
    }
    
    //获取旧deviceToken
    public func getOldDeviceToken() -> String? {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let deviceToken = userDefault.stringForKey("oldDeviceToken")
        return deviceToken
    }
    
    //获取新deviceToken
    public func getNewDeviceToken() -> String? {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let deviceToken = userDefault.stringForKey("newDeviceToken")
        return deviceToken
    }
    
    //保存deviceToken
    public func setOldDeviceToken(deviceToken: String) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(deviceToken, forKey: "oldDeviceToken")
    }
    
    //保存deviceToken
    public func setNewDeviceToken(deviceToken: String) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(deviceToken, forKey: "newDeviceToken")
    }
    
//    //注销
//    public func logout(withToast isToast: Bool) {
//        
//        let userDefaults = NSUserDefaults.standardUserDefaults()
//        userDefaults.setObject(nil, forKey: "phoneNumber")
//        userDefaults.setObject(nil, forKey: "validationCode")
//        userDefaults.setBool(false, forKey: "isLogin")
//        userDefaults.synchronize()
//        
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let window: UIWindow = UIApplication.sharedApplication().keyWindow!
//        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
//        window.rootViewController = loginVC
//        window.makeKeyAndVisible()
//        
//        if isToast {
//            UITools.sharedInstance.toast("用户名密码失效，请重新登录")
//        }
//    }
    
    //注销
    public func logout(storyboard:UIStoryboard, withToast isToast: Bool) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "phoneNumber")
        userDefaults.setObject(nil, forKey: "validationCode")
        userDefaults.setBool(false, forKey: "isLogin")
        userDefaults.synchronize()
        
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let window: UIWindow = UIApplication.sharedApplication().keyWindow!
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        window.rootViewController = loginVC
        window.makeKeyAndVisible()
        
        if isToast {
            UITools.sharedInstance.toast("用户名密码失效，请重新登录")
        }
    }
    
//    //注销
//    public func logoutAndRemoveDeviceToken() {
//        
//        guard let (userName1, password1) = getUserInfo(), userName = userName1, password = password1 where !userName.isEmpty && !password.isEmpty else {
//            return
//        }
//        
//        let newDeviceToken = ""
//        
//        //等待动画
//        let HUD = UITools.sharedInstance.showLoadingAnimation()
//        
//        let parameters = ["username" : userName, "pwd" : password, "deviceToken" : newDeviceToken]
//        let url = Constant.HOST_PATH + "/user_updateDeviceToken.action"
//        Alamofire.request(.GET, url, parameters: parameters)
//            .responseJSON { response in
//                
//                //取消等待动画
//                HUD.hide(true)
//                
//                print(response.result.value)
//                //处理结果
//                switch (response.result) {
//                case .Success(let value):
//                    if let status = value["status"] as? Bool where status {
//                        
//                        self.logout(withToast: false)
//                        
//                    } else {
//                        
//                    }
//                case .Failure(let error):
//                    NSLog("Error: %@", error)
//                }
//        }
//    }
    
    func getCustomerInfoFromNet() {
        
        guard let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            return
        }
        //url和参数
        let url = Constant.HOST_PATH + "/OrderApp_getCustomerInfo.action"
        let parameters = ["phoneNumber" : phoneNumber, "validationCode" : validationCode, "keyword" : ""]
        
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
                
                switch (response.result) {
                case .Success(let value):
                    print("get user info result: \(value)")
                    
                    if let status = value["status"] as? String {
                        if status == UNAUTHORIZED {
                            NSLog("\(url) 无权限")
                        } else if status == BAD_PARAMETER {
                            NSLog("\(url) 参数错误")
                        }
                        
                    } else if let dict = value as? NSDictionary {
                        
                        let name = dict["name"] as! String
                        let organizationName = dict["organizationName"] as! String
                        let gender = dict["gender"] as! String
                        
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setObject(name, forKey: Constant.KeyForCustomerName)
                        userDefaults.setObject(organizationName, forKey: Constant.KeyForCustomerOrganizationName)
                        userDefaults.setObject(gender == "male" ? "男" : "女", forKey: Constant.KeyForCustomerGender)
                        userDefaults.synchronize()
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(Constant.DidGetCustomerInfoNofification, object: nil, userInfo: ["name" : name, "organizationName" : organizationName, "gender" : gender, ])
                    }
                    
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }
    
    //检查更新Info并解析
    func loadAndParseUpdateInfoXML(checkUpdateType: Int) {
        
        let url = Constant.CheckUpdateUrl
        
        Alamofire.request(.GET, url)
            .responseData() {response in
                
                print("Check Update Request: ", response.request)
                
                switch (response.result) {
                case .Success(let value):
                    
//                    print("Check Update Success value: \(value)")
//                    if let data = response.data {
//                        UpdateInfoXmlParser.sharedInstance.start(data, checkUpdateType: checkUpdateType)
//                    }
                    UpdateInfoXmlParser.sharedInstance.start(value, checkUpdateType: checkUpdateType)
                    
                case .Failure(let error):
                    
                    NSLog("Check Update Fail Error: %@", error)
                }
        }
    }
    
    //弹出更新提示
    func showUpdateTip(notification: NSNotification) {
        
        guard let updateInfo = notification.object as? UpdateInfo else {
            return
        }
        
        guard let localVersion = getLocalVersion() else {
            return
        }
        
        if Double(localVersion) < Double(updateInfo.version!) {
            
            popUpdateAlerView(localVersion, newVersion: updateInfo.version!, appId: updateInfo.appId!)
        } else if updateInfo.checkUpdateType == 2 {
            UITools.sharedInstance.toast("已是最新版本")
        }
    }
    
    //获取本地版本
    func getLocalVersion() ->String? {
        
        guard let infoDict = NSBundle.mainBundle().infoDictionary else {
            NSLog("获取本地版本失败")
            return nil
        }
        
        let appName = infoDict["CFBundleDisplayName"] as! String
        let appVersion = infoDict["CFBundleShortVersionString"] as! String
        let appBuild = infoDict["CFBundleVersion"] as! String
        
        NSLog("appName:%@, appVersion:%@, appBuild:%@", appName, appVersion, appBuild)
        
        return appVersion
    }
    //弹出更新Alert
    func popUpdateAlerView(oldVersion: String, newVersion: String, appId: String) {
        
        let alertController = UIAlertController(title: "更新提醒", message: "当前的版本是:\(oldVersion)，发现新版本:\(newVersion)，是否更新？", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "现在更新", style: UIAlertActionStyle.Default) { alertAction in
            
            //跳转到iTunes
            if let url = NSURL(string: "https://itunes.apple.com/cn/app/id\(appId)?mt=8") {
                
                UIApplication.sharedApplication().openURL(url)
            }
        }
        let cancel = UIAlertAction(title: "下次再说", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            rootViewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //上传token
    func updateDeviceToken() {
        
//        let oldDeviceToken = Tools.sharedInstance.getOldDeviceToken()
        let newDeviceToken = Tools.sharedInstance.getNewDeviceToken()
        
        if newDeviceToken == nil {
            return
        }
//        if oldDeviceToken != nil && newDeviceToken != nil && oldDeviceToken == newDeviceToken {
//            return
//        }
        
        if !(NSUserDefaults.standardUserDefaults().boolForKey("isRegisteredCustomerInfo")) {
            return
        }
        
        guard let (phoneNumber1, validationCode1) = Tools.sharedInstance.getUserInfo(), phoneNumber = phoneNumber1, validationCode = validationCode1 where !phoneNumber.isEmpty && !validationCode.isEmpty else {
            return
        }
        
        let parameters = ["phoneNumber" : phoneNumber, "validationCode" : validationCode, "deviceType" : "ios", "deviceToken" : newDeviceToken!]
        let url = Constant.HOST_PATH + "/OrderApp_updateDeviceToken.action"
        Alamofire.request(.GET, url, parameters: parameters)
            .responseJSON { response in
                
                print("OrderApp_updateDeviceToken.action request:\(response.request)")
                print("Update Device Token result: \(response.result.value)")
                //处理结果
                switch (response.result) {
                case .Success(let value):
                    if let status = value["status"] as? Bool where status {
                        Tools.sharedInstance.setOldDeviceToken(newDeviceToken!)
                    } else {
                        print("Update Device Token Failed")
                    }
                case .Failure(let error):
                    NSLog("Error: %@", error)
                }
        }
    }
}