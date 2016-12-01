//
//  AppDelegate.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/13.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire
import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //注册通知
        addObserverForNotificationCenter()
        
        //检查登录状态，并跳转到相应界面
        checkLogin()
        
        //注册远程通知
        registerForRemoteNotifications()
        
        //启动网络检查
        startNetworkCheck()
        
        //通过push通知启动应用后获取paload
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
            NSLog("payload: %@", userInfo)
            UITools.sharedInstance.pushToDetailPage(userInfo)
        }
        
        //下载并解析更新xml文件
        Tools.sharedInstance.loadAndParseUpdateInfoXML(1)
        
        //应用角标归零
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    //检查是否已登录
    func checkLogin() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        
        //判断是否已登录
        let flag = NSUserDefaults.standardUserDefaults().boolForKey("isLogin")
        if(flag) {
            let homeVC: HomeViewController! = storyboard.instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController
            window?.rootViewController = homeVC
        } else {
            let loginVC: LoginViewController! = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
            window?.rootViewController = loginVC
        }
        window?.makeKeyAndVisible()
    }
    
    //注册远程通知
    func registerForRemoteNotifications() {
        //注册Push Notification
        if UIApplication.sharedApplication().currentUserNotificationSettings()?.types != UIUserNotificationType.None {
            
        } else {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    //为通知中心添加观察者
    func addObserverForNotificationCenter() {
        //检测网络可用性通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
        //检查更新通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showUpdateTip(_:)), name: Constant.DidParserUpdateInfoXMLNotification, object: nil)
    }
    
    //网络检查
    func startNetworkCheck() {
        let internetReachability = Reachability.reachabilityForInternetConnection()
        internetReachability.startNotifier()
        updateInterfaceWithReachability(internetReachability)
    }
    
    //更新
    func showUpdateTip(notification: NSNotification) {
        Tools.sharedInstance.showUpdateTip(notification)
    }
    
    //注册push成功并获取道deviceToken
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        NSLog("new deviceToken: %@", deviceToken)
        
        let newDeviceToken = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        print("new token: \(newDeviceToken)")
        Tools.sharedInstance.setNewDeviceToken(newDeviceToken)
        
        //上传token
        Tools.sharedInstance.updateDeviceToken()
    }
    
    //注册push失败
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("Fail To Register For Remote Notifications. Error: %@", error)
    }
    
    //应用处于启动状态时，收到push后调用此方法
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        print("Remote Notification userInfo: \(userInfo)")
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constant.DidReceiveRemoteNotification, object: nil, userInfo: userInfo)
        
        if UIApplication.sharedApplication().applicationState == .Active {
            
            //播放声音
            AudioServicesPlaySystemSound(1007)
            
            let aps = userInfo["aps"] as! NSDictionary
            let alert = aps["alert"] as! String
            let alertController = UIAlertController(title: "新消息", message: alert, preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "取消", style: .Default, handler: nil)
            let ok = UIAlertAction(title: "查看", style: .Default) { alertAction in
                UITools.sharedInstance.pushToDetailPage(userInfo)
            }
            alertController.addAction(cancel)
            alertController.addAction(ok)
            if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                
                rootViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            UITools.sharedInstance.pushToDetailPage(userInfo)
        }
    }
    
    func reachabilityChanged(notification: NSNotification) {
        
        if let curReach = notification.object as? Reachability {
            updateInterfaceWithReachability(curReach)
        } else {
            NSLog("is not Reachability")
        }
    }
    
    func updateInterfaceWithReachability(reachability: Reachability) {
        let netStatus = reachability.currentReachabilityStatus()
        switch(netStatus) {
        case NotReachable:
            NSLog("====当前网络不可达====")
            UITools.sharedInstance.showAlertForNoNetwork()
        case ReachableViaWiFi:
            NSLog("====当前网络状态为：Wi-Fi====")
        case ReachableViaWWAN:
            NSLog("====当前网络状态为：3G====")
        default:
            NSLog("====default====")
            break
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

