//
//  Util.swift
//  YuQinClient
//
//  Created by ksn_cn on 2016/11/2.
//  Copyright © 2016年 CQU. All rights reserved.
//

import Foundation

public class Util {
    
    static let sharedInstance = Util()
    //私有化init方法，保证单例
    private init(){}
    
    //获取登录用户的帐号密码
    public func getUserInfo() ->(phoneNumber: String?, validationCode: String?) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let phoneNumber = userDefault.stringForKey("phoneNumber")
        let validationCode = userDefault.stringForKey("validationCode")
        return (phoneNumber: phoneNumber, validationCode: validationCode)
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
    
//    public func getImage(from color: UIColor) -> UIImage? {
//        var image: UIImage?
//        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        UIGraphicsBeginImageContext(rect.size)
//        if let ctx = UIGraphicsGetCurrentContext() {
//            ctx.setFillColor(color.cgColor)
//            ctx.fill(rect)
//            image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//        }
//        return image
//    }
    
    
}
