//
//  HomeViewController.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/15.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit
import Alamofire
import STPopup

class HomeViewController: UITabBarController {
    
    //弹出填写个人信息窗口
    var popupVC: STPopupController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.tintColor = UIColor(red: 34.0/255.0, green: 189.0/255.0, blue: 246.0/255.0, alpha: 1)
        
        let tabbarViewControllers = self.viewControllers
        for item in tabbarViewControllers! {
            
            if let item1 = item as? UINavigationController {
                
                item1.navigationBar.barTintColor = UIColor(red: 34.0/255.0, green: 189.0/255.0, blue: 246.0/255.0, alpha: 1)
                item1.navigationBar.tintColor = UIColor.whiteColor()
                let navigationTitleAttribute: NSDictionary = NSDictionary(object: UIColor.whiteColor(), forKey: NSForegroundColorAttributeName)
                item1.navigationBar.titleTextAttributes = navigationTitleAttribute as? [String : AnyObject]
            }
        }
        
        //网络变化通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
        
        //检查客户是否填写了姓名和单位名称
        checkCustomerInfo()
//        Tools.sharedInstance.getCustomerInfoFromNet()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkCustomerInfo() {
        
        URLConnector.request(Router.needRegistUserInfo, successCallBack: { value in
            if let status = value["status"].bool {
                if status {
                    let presentedVC = self.storyboard?.instantiateViewControllerWithIdentifier("RegisterCustomerInfoViewController") as! RegisterCustomerInfoViewController
                    
                    presentedVC.title = "请填写个人信息"
                    let width = UIApplication.sharedApplication().keyWindow?.frame.size.width
                    presentedVC.contentSizeInPopup = CGSizeMake(width!, 300)
                    presentedVC.landscapeContentSizeInPopup = CGSizeMake(400, 200)
                    presentedVC.navigationItem.hidesBackButton = true
                    
                    self.popupVC = STPopupController(rootViewController: presentedVC)
                    self.popupVC.style = .FormSheet
                    self.popupVC.presentInViewController(self)
                } else {
                    print("个人信息已完善")
                    Tools.sharedInstance.updateDeviceToken()
                }
            }
        })
    }
    
    func reachabilityChanged(notification: NSNotification) {
        
        if let curReach = notification.object as? Reachability {
            updateInterfaceWithReachability(curReach)
        }
    }
    
    func updateInterfaceWithReachability(reachability: Reachability) {
        let netStatus = reachability.currentReachabilityStatus()
        switch(netStatus) {
        case NotReachable:
            break
        case ReachableViaWiFi, ReachableViaWWAN:
            checkCustomerInfo()
            Tools.sharedInstance.getCustomerInfoFromNet()
        default:
            break
        }
    }

}
